package com.kavalok.services;

import java.util.List;

import com.kavalok.dao.ServerDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.db.Server;
import com.kavalok.dto.ServerTO;
import com.kavalok.services.common.DataServiceNotTransactionBase;
import com.kavalok.utils.ReflectUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ServerService extends DataServiceNotTransactionBase {

  private static final Logger logger = LoggerFactory.getLogger(ServerService.class);

  public String getServerAddress(String name) {
    Server server = new ServerDAO(getSession()).findByName(name);
    if (server == null) {
      logger.warn("Server not found for name: {}", name);
      return null;
    }
    
    // Determine protocol based on TLS setting
    String protocol = server.isTls() ? "rtmps" : "rtmp";
    
    // Get hostname, default to localhost if remoteHost is null
    String hostname = server.getRemoteHost() != null ? server.getRemoteHost() : "localhost";
    
    // Get port, default to 8935 if not set
    int port = server.getRtmpPort() != null ? server.getRtmpPort() : 8935;
    
    // Build the full URL
    String url = protocol + "://" + hostname + ":" + port + "/kavalok";
    
    logger.info("Server {} (ID: {}) - Returning RTMP URL: {} (hostname: {}, port: {}, tls: {})", 
        name, server.getId(), url, hostname, port, server.isTls());
    
    return url;
  }

  @SuppressWarnings("unchecked")
  public List<ServerTO> getAllServers() {
    List<Server> servers = new ServerDAO(getSession()).findAll();
    List<ServerTO> tos = ReflectUtil.convertBeansByConstructor(servers, ServerTO.class);
    fillTos(servers, tos);
    return tos;
  }

  private void fillTos(List<Server> servers, List<ServerTO> tos) {
    UserServerDAO usDAO = new UserServerDAO(getSession());
    for (int i = 0; i < servers.size(); i++) {
      Server server = servers.get(i);
      ServerTO to = tos.get(i);
      to.setLoad(usDAO.countByServer(server).intValue());
    }
  }

  @SuppressWarnings("unchecked")
  public List<ServerTO> getServers() {
    List<Server> servers = new ServerDAO(getSession()).findAvailable();
    List<ServerTO> tos = ReflectUtil.convertBeansByConstructor(servers, ServerTO.class);
    fillTos(servers, tos);
    return tos;
  }
}
