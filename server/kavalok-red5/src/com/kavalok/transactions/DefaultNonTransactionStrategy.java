package com.kavalok.transactions;

import org.hibernate.Session;

import com.kavalok.utils.SessionManager;

/**
 * Default non-transaction strategy using ThreadLocal session management.
 * This ensures proper session handling for read-only operations.
 */
public class DefaultNonTransactionStrategy implements ITransactionStrategy {

  public Session getSession() {
    return SessionManager.getCurrentSession();
  }

  @Override
  public void afterCall() {
    Session session = SessionManager.getCurrentSession();
    if (session != null && session.isOpen()) {
      session.flush();
      SessionManager.closeCurrentSession();
    }
  }

  @Override
  public void beforeCall() {
    // Just ensure we have a session, no transaction needed
    SessionManager.getCurrentSession();
  }

  @Override
  public void afterError(Throwable e) {
    SessionManager.closeCurrentSession();
  }
}
