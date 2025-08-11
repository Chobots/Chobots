package com.kavalok.billing.paypal;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.lang.reflect.InvocationTargetException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.Iterator;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.billing.transaction.BillingTransactionUtil;
import com.kavalok.billing.transaction.TransactionProcessor;
import com.kavalok.db.Transaction;
import com.kavalok.transactions.DefaultTransactionStrategy;

public class PayPalUtil {

  //  private static boolean useTest = false && "true".equals(System.getProperty("isTestServer"));
  //
  //  private static String strSandbox = "https://www.sandbox.paypal.com/cgi-bin/webscr";

  private static String strLive = "https://www.paypal.com/cgi-bin/webscr";

  private static String currServ = strLive;

  // useTest ? strSandbox : strLive;

  private static Logger logger = Red5LoggerFactory.getLogger(PayPalUtil.class);

  // the function filters junk off acquired parameters
  private static String getValue(Map<String, String> params, String name) {
    String value = params.get(name);
    // String result = (value != null) ? value.trim().replaceAll("<.+?>", "") :
    // "";
    // return (result.length() > 250) ? value.substring(0, 250) : value;
    return value;
  }

  @SuppressWarnings("deprecation")
  public static String processResultRequest(Map<String, String> requestParams)
      throws IllegalAccessException, InvocationTargetException, IOException {

    logger.info("Got params: " + requestParams);

    PayPalRequestParams requestParamsXML = new PayPalRequestParams();

    BeanUtils.populate(requestParamsXML, requestParams);

    // {item_number=AK-1234, residence_country=US,
    // verify_sign=ArB5YWtMBotpGBcSC-PICtTnPMBeAPKkYV5kzoIQT-JllvSql1IzmSjQ,
    // address_country=United States, address_city=San Jose,
    // address_status=confirmed, payment_status=Completed,
    // business=seller@paypalsandbox.com, payer_id=TESTBUYERID01,
    // first_name=John, shipping=3.04, payer_email=buyer@paypalsandbox.com,
    // mc_fee=0.44, txn_id=151211143, quantity=1,
    // receiver_email=seller@paypalsandbox.com, notify_version=2.1,
    // txn_type=web_accept, test_ipn=1, payer_status=verified, mc_currency=USD,
    // mc_gross=12.34, custom=xyz123, payment_date=06:03:15 Dec. 11, 2008 PST,
    // charset=windows-1252, address_country_code=US, address_zip=95131,
    // mc_gross1=9.34, address_state=CA, tax=2.02, item_name=something,
    // address_name=John Smith, last_name=Smith, payment_type=instant,
    // address_street=123, any street, receiver_id=TESTSELLERID1}

    // collecting required data
    // String item_number = getValue(requestParams, "item_number");
    // String residence_country = getValue(requestParams, "residence_country");
    // String verify_sign = getValue(requestParams, "verify_sign");
    // String prefix = getValue(requestParams, "prefix");
    // String address_country = getValue(requestParams, "address_country");
    // String address_city = getValue(requestParams, "address_city");
    // String address_status = getValue(requestParams, "address_status");
    String payment_status = getValue(requestParams, "payment_status");
    // String business = getValue(requestParams, "business");
    // String payer_id = getValue(requestParams, "payer_id");
    // String first_name = getValue(requestParams, "first_name");
    // String shipping = getValue(requestParams, "shipping");
    String payer_email = getValue(requestParams, "payer_email");
    // String mc_fee = getValue(requestParams, "mc_fee");
    // String txn_id = getValue(requestParams, "txn_id");
    // String quantity = getValue(requestParams, "quantity");
    // String receiver_email = getValue(requestParams, "receiver_email");
    // String notify_version = getValue(requestParams, "notify_version");
    // String txn_type = getValue(requestParams, "txn_type");
    // String test_ipn = getValue(requestParams, "test_ipn");
    // String payer_status = getValue(requestParams, "payer_status");
    // String mc_currency = getValue(requestParams, "mc_currency");
    // String mc_gross = getValue(requestParams, "mc_gross");// payed amount
    String custom = getValue(requestParams, "custom"); // our transaction id
    // String payment_date = getValue(requestParams, "payment_date");
    // String charset = getValue(requestParams, "charset");
    // String address_country_code = getValue(requestParams,
    // "address_country_code");
    // String address_zip = getValue(requestParams, "address_zip");
    // String mc_gross1 = getValue(requestParams, "mc_gross1");
    // String address_state = getValue(requestParams, "address_state");
    // String tax = getValue(requestParams, "tax");
    // String item_name = getValue(requestParams, "item_name");
    // String address_name = getValue(requestParams, "address_name");
    // String last_name = getValue(requestParams, "last_name");
    // String payment_type = getValue(requestParams, "payment_type");
    // String address_street = getValue(requestParams, "address_street");
    // String receiver_id = getValue(requestParams, "receiver_id");

    // read post from PayPal system and add 'cmd'
    Iterator<String> names = requestParams.keySet().iterator();
    String str = "cmd=_notify-validate";
    while (names.hasNext()) {
      String paramName = names.next();
      String paramValue = requestParams.get(paramName);
      str = str + "&" + paramName + "=" + URLEncoder.encode(paramValue);
    }

    // post back to PayPal system to validate
    // NOTE: change http: to https: in the following URL to verify using SSL
    // (for increased security).
    // using HTTPS requires either Java 1.4 or greater, or Java Secure Socket
    // Extension (JSSE)
    // and configured for older versions.
    // URL u = new URL("https://www.paypal.com/cgi-bin/webscr");
    URL u = new URL(currServ);
    URLConnection uc = u.openConnection();
    uc.setDoOutput(true);
    uc.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
    PrintWriter pw = new PrintWriter(uc.getOutputStream());
    pw.println(str);
    pw.close();

    BufferedReader in = new BufferedReader(new InputStreamReader(uc.getInputStream()));
    String res = in.readLine();
    in.close();

    // check notification validation
    if ("VERIFIED".equals(res)) {
      // check that paymentStatus=Completed
      // check that txnId has not been previously processed
      // check that receiverEmail is your Primary PayPal email
      // check that paymentAmount/paymentCurrency are correct
      // process payment
      if ("Completed".equals(payment_status)) {
        logger.info(
            String.format(
                "Processing PayPal IPN request for buyer email: %1s, transaction: %2s",
                payer_email, custom));
        return processTransaction(custom, requestParamsXML);
      }
    } else if (res.equals("INVALID")) {
      logger.warn("IPN request was incorrect. Parameters: " + requestParams);
    } else {
      logger.warn("IPN request error: " + res);
    }

    return "";
  }

  private static String processTransaction(
      String content, PayPalRequestParams payPalRequestParams) {
    // String transIdPrefix = prefix + " " + transitId + " ";
    // String transIdStr = content.substring(transIdPrefix.length() + 1);
    Long transactionId = new Long(content.toString());
    Transaction trans;

    DefaultTransactionStrategy dts = new DefaultTransactionStrategy();
    try {
      dts.beforeCall();
      trans =
          BillingTransactionUtil.setProcessingState(
              dts.getSession(),
              transactionId,
              payPalRequestParams,
              payPalRequestParams.getMc_gross(),
              payPalRequestParams.getMc_currency());
      dts.afterCall();
    } catch (Exception e) {
      dts.afterError(e);
      logger.error("Error processing transaction", e);
      throw new IllegalStateException("Error calling PayPalUtils.processTransaction", e);
    }

    Thread thread = new Thread(new TransactionProcessor(transactionId));
    thread.start();
    return trans.getSuccessMessage();
  }

  public static Logger getLogger() {
    return logger;
  }
}
