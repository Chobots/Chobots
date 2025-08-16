package com.kavalok.transactions;

import org.hibernate.Session;
import org.hibernate.Transaction;

import com.kavalok.utils.SessionManager;

/**
 * Default transaction strategy using ThreadLocal session management.
 * This ensures proper transaction handling across all database operations.
 */
public class DefaultTransactionStrategy implements ITransactionStrategy {

  public Session getSession() {
    return SessionManager.getCurrentSession();
  }

  @Override
  public void afterCall() {
    Session session = SessionManager.getCurrentSession();
    if (session != null && session.isOpen()) {
      if (session.isDirty()) {
        session.flush();
      }
      SessionManager.commitTransaction();
      SessionManager.closeCurrentSession();
    }
  }

  @Override
  public void beforeCall() {
    SessionManager.beginTransaction();
  }

  @Override
  public void afterError(Throwable e) {
    SessionManager.rollbackTransaction();
    SessionManager.closeCurrentSession();
  }
}
