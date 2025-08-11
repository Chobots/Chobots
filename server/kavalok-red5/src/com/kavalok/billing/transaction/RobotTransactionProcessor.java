package com.kavalok.billing.transaction;

import org.hibernate.Session;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.dao.RobotTransactionDAO;
import com.kavalok.db.RobotTransaction;
import com.kavalok.db.User;
import com.kavalok.transactions.DefaultTransactionStrategy;
import com.kavalok.user.UserUtil;

public class RobotTransactionProcessor implements Runnable {
  private static Logger logger = Red5LoggerFactory.getLogger(RobotTransactionProcessor.class);

  private Long transactionId;

  public RobotTransactionProcessor(Long transactionId) {
    this.transactionId = transactionId;
  }

  @Override
  public void run() {
    processTransaction();
  }

  private void processTransaction() {
    synchronized (RobotTransactionProcessor.class) {
      DefaultTransactionStrategy dts = new DefaultTransactionStrategy();
      try {
        dts.beforeCall();

        RobotTransactionDAO dao = new RobotTransactionDAO(dts.getSession());
        RobotTransaction transaction = dao.findById(transactionId, false);

        logger.info("Processing transaction id: " + transaction.getId());

        logger.info("Transaction state: " + transaction.getState());
        if (!TransactionConstants.STATE_DONE.equals(transaction.getState())) {
          doProcess(dts.getSession(), dao, transaction);
        }
        logger.info("Transaction state: " + transaction.getState());

        dts.afterCall();
      } catch (Exception e) {
        dts.afterError(e);
        logger.error("Error processing transaction", e);
      }
    }
  }

  private void doProcess(Session session, RobotTransactionDAO dao, RobotTransaction transaction)
      throws Exception {
    transaction.setState(TransactionConstants.STATE_DONE);

    User user = transaction.getUser();
    logger.info(
        String.format(
            "Bying membership for userId: %1s, login: %2s", user.getId(), user.getLogin()));
    UserUtil.buyRobotItem(session, transaction);

    dao.makePersistent(transaction);

    logger.info("TransactionProcessor doProcess Transaction state: " + transaction.getState());
  }
}
