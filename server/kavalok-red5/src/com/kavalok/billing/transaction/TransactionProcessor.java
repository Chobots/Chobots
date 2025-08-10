package com.kavalok.billing.transaction;

import org.hibernate.Session;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.dao.TransactionDAO;
import com.kavalok.db.SKU;
import com.kavalok.db.StuffType;
import com.kavalok.db.Transaction;
import com.kavalok.db.User;
import com.kavalok.transactions.DefaultTransactionStrategy;
import com.kavalok.user.UserUtil;

public class TransactionProcessor implements Runnable {
  private static Logger logger = Red5LoggerFactory.getLogger(TransactionProcessor.class);

  private Long transactionId;

  public TransactionProcessor(Long transactionId) {
    this.transactionId = transactionId;
  }

  @Override
  public void run() {
    processTransaction();
  }

  private void processTransaction() {
    synchronized (TransactionProcessor.class) {
      DefaultTransactionStrategy dts = new DefaultTransactionStrategy();
      try {
        dts.beforeCall();

        TransactionDAO dao = new TransactionDAO(dts.getSession());
        Transaction transaction = dao.findById(transactionId, false);

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

  private void doProcess(Session session, TransactionDAO dao, Transaction transaction)
      throws Exception {
    transaction.setState(TransactionConstants.STATE_DONE);

    processTransactionMembership(session, transaction);

    dao.makePersistent(transaction);

    logger.info("TransactionProcessor doProcess Transaction state: " + transaction.getState());
  }

  private void processTransactionMembership(Session session, Transaction transaction) {
    User user = transaction.getUser();
    logger.info(
        String.format(
            "Bying membership for userId: %1s, login: %2s", user.getId(), user.getLogin()));
    SKU sku = transaction.getSku();
    if (!SKU.TYPE_STUFF.equals(sku.getType())) {
      UserUtil.buyCitizenship(session, user, transaction, sku.getTerm());
    } else {
      StuffType type = new StuffTypeDAO(session).findById(sku.getItemTypeId(), false);
      if ("M".equals(type.getType())) {
        UserUtil.buyBugs(session, transaction.getUser().getId(), type, sku.getBugsBonus());
      } else {
        UserUtil.buyPayedStuff(session, transaction.getUser().getId(), type);
      }
    }
  }
}
