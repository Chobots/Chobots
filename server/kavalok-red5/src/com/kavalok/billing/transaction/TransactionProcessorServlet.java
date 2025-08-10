package com.kavalok.billing.transaction;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.red5.logging.Red5LoggerFactory;
import org.slf4j.Logger;

import com.kavalok.utils.HttpUtil;

public class TransactionProcessorServlet extends HttpServlet {

  /** */
  private static final long serialVersionUID = 9166772327665369872L;

  private static Logger logger =
      Red5LoggerFactory.getLogger(TransactionProcessorServlet.class);

  @Override
  protected void service(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    logger.info("TransactionProcessorServlet service called.\n URI: " + request.getRequestURI());

    Map<String, String> params = HttpUtil.normalizeRequestParameteres(request.getParameterMap());
    String content = params.get("t");
    Long pass = new Long(params.get("p"));
    response.setStatus(HttpServletResponse.SC_OK);

    boolean isRobotTx = false;

    Long transactionId;
    try {
      transactionId = new Long(content);
    } catch (Exception e) {
      isRobotTx = true;
      transactionId = new Long(content.substring(1));
    }

    if (pass.longValue() - transactionId.longValue() != 100) {
      response.getWriter().write("NAHUJ!");
    } else {
      Thread thread;
      if (isRobotTx) {
        thread = new Thread(new RobotTransactionProcessor(transactionId));
      } else {
        thread = new Thread(new TransactionProcessor(transactionId));
      }
      thread.start();
      response.getWriter().write("processed " + transactionId);
    }
  }
}
