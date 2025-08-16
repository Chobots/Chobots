package com.kavalok.transactions;

import org.hibernate.Session;
import org.hibernate.Transaction;

import com.kavalok.utils.HibernateUtil;

public class DefaultTransactionStrategy implements ITransactionStrategy {

  private Session session;

  private Transaction transaction;

  public Session getSession() {
    return session;
  }

  @Override
  public void afterCall() {
    if (session.isOpen()) {
      if (session.isDirty()) {
        session.flush();
      }
      transaction.commit();
      session.close();
    }
  }

  @Override
  public void beforeCall() {
    session = HibernateUtil.getSessionFactory().openSession();
    transaction = session.beginTransaction();
  }

  @Override
  public void afterError(Throwable e) {
    transaction.rollback();
    session.close();
  }
}
