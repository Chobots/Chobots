package com.kavalok.xmlrpc;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Hashtable;

import org.apache.xmlrpc.XmlRpcException;
import org.apache.xmlrpc.XmlRpcRequest;
import org.apache.xmlrpc.client.XmlRpcClient;
import org.apache.xmlrpc.client.XmlRpcClientConfigImpl;
import org.apache.xmlrpc.client.XmlRpcClientException;
import org.apache.xmlrpc.client.XmlRpcCommonsTransport;
import org.apache.xmlrpc.client.XmlRpcCommonsTransportFactory;
import org.apache.xmlrpc.client.XmlRpcTransport;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.db.Server;

public class ClientBase {

  private static final String URL_FORMAT = "http://%1$s:5080/%2$s/xmlrpc";

  private static final Logger logger = Red5LoggerFactory.getLogger(ClientBase.class);

  protected XmlRpcClient xmlRpcClient;

  private String serverURL;

  protected void createXmlRpc(Server currentServer) {
    if (currentServer != null) {
      createXmlRpc(currentServer.getXMLRPCHost(), currentServer.getContextPath());
    }
  }

  protected void createXmlRpc(String ip, String contextPath) {
    try {
      XmlRpcClientConfigImpl config = new XmlRpcClientConfigImpl();
      serverURL = String.format(URL_FORMAT, ip, contextPath);
      config.setServerURL(new URL(serverURL));
      config.setEnabledForExtensions(true);
      config.setConnectionTimeout(500);
      config.setReplyTimeout(500 * 1000);
      xmlRpcClient = new XmlRpcClient();
      xmlRpcClient.setTransportFactory(
          new XmlRpcCommonsTransportFactory(xmlRpcClient) {
            @Override
            public XmlRpcTransport getTransport() {
              return new XmlRpcCommonsTransport(this) {
                @Override
                protected void initHttpHeaders(XmlRpcRequest request)
                    throws XmlRpcClientException {
                  super.initHttpHeaders(request);
                  String secret = System.getenv("KAVALOK_SECRET_KEY");
                  if (secret != null && !secret.isEmpty()) {
                    // Add shared secret header for server-to-server auth
                    this.method.addRequestHeader("X-Kavalok-Secret", secret);
                  }
                }
              };
            }
          });
      xmlRpcClient.setConfig(config);
    } catch (MalformedURLException e) {
      logger.info(e.getMessage(), e);
    }
  }

  protected Object invoke(final String rpcMethodName) {
    return invoke(rpcMethodName, new Object[0]);
  }

  protected void invokeInNewThread(final String rpcMethodName, Object[] parameters) {
    RpcThread rpcThread = new RpcThread(this, rpcMethodName, parameters);
    Thread thread = new Thread(rpcThread);
    thread.start();
  }

  @SuppressWarnings("unchecked")
  public Object invoke(final String rpcMethodName, Object[] parameters) {
    if (xmlRpcClient == null) return null;

    try {
      Object result = xmlRpcClient.execute(rpcMethodName, parameters);
      if (result instanceof Hashtable) {
        Hashtable<String, Object> fault = (Hashtable<String, Object>) result;
        int faultCode = ((Integer) fault.get("faultCode")).intValue();
        System.out.println(
            "Unable to connect to device via XML-RPC. \nFault Code: "
                + faultCode
                + "\nFault Message: "
                + (String) fault.get("faultString"));
        throw new RuntimeException(
            "Unable to connect to device via XML-RPC. \nFault Code: "
                + faultCode
                + "\nFault Message: "
                + (String) fault.get("faultString"));
      }
      return result;
    } catch (XmlRpcException e) {
      logger.info(e.getMessage(), e);
      e.printStackTrace();
      System.err.println("Error on server: " + serverURL);
      System.err.println("rpcMethodName: " + rpcMethodName);
      System.err.println("parameters: " + parameters);
      return null;
    }
  }
}
