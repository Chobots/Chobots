package com.kavalok.utils;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

/**
 * ThreadLocal session manager for proper transaction handling.
 * This ensures that all database operations within a transaction context
 * use the same session instance.
 */
public class SessionManager {
    
    private static final Logger logger = Red5LoggerFactory.getLogger(SessionManager.class);
    private static final ThreadLocal<Session> sessionHolder = new ThreadLocal<>();
    private static final ThreadLocal<Transaction> transactionHolder = new ThreadLocal<>();
    
    /**
     * Get the current session for this thread.
     * Creates a new session if none exists.
     */
    public static Session getCurrentSession() {
        Session session = sessionHolder.get();
        if (session == null || !session.isOpen()) {
            session = HibernateUtil.getSessionFactory().openSession();
            sessionHolder.set(session);
            logger.debug("Created new session for thread: {}", Thread.currentThread().getName());
        }
        return session;
    }
    
    /**
     * Get the current transaction for this thread.
     */
    public static Transaction getCurrentTransaction() {
        return transactionHolder.get();
    }
    
    /**
     * Begin a new transaction for the current session.
     */
    public static void beginTransaction() {
        Session session = getCurrentSession();
        Transaction transaction = session.beginTransaction();
        transactionHolder.set(transaction);
        logger.debug("Began transaction for thread: {}", Thread.currentThread().getName());
    }
    
    /**
     * Commit the current transaction.
     */
    public static void commitTransaction() {
        Transaction transaction = getCurrentTransaction();
        if (transaction != null) {
            transaction.commit();
            transactionHolder.remove();
            logger.debug("Committed transaction for thread: {}", Thread.currentThread().getName());
        }
    }
    
    /**
     * Rollback the current transaction.
     */
    public static void rollbackTransaction() {
        Transaction transaction = getCurrentTransaction();
        if (transaction != null) {
            try {
                transaction.rollback();
                logger.debug("Rolled back transaction for thread: {}", Thread.currentThread().getName());
            } catch (Exception e) {
                logger.error("Error rolling back transaction", e);
            } finally {
                transactionHolder.remove();
            }
        }
    }
    
    /**
     * Close the current session and clean up ThreadLocal storage.
     */
    public static void closeCurrentSession() {
        Session session = sessionHolder.get();
        if (session != null && session.isOpen()) {
            try {
                session.close();
                logger.debug("Closed session for thread: {}", Thread.currentThread().getName());
            } catch (Exception e) {
                logger.error("Error closing session", e);
            } finally {
                sessionHolder.remove();
                transactionHolder.remove();
            }
        }
    }
    
    /**
     * Check if there's an active session for this thread.
     */
    public static boolean hasActiveSession() {
        Session session = sessionHolder.get();
        return session != null && session.isOpen();
    }
    
    /**
     * Check if there's an active transaction for this thread.
     */
    public static boolean hasActiveTransaction() {
        Transaction transaction = transactionHolder.get();
        return transaction != null;
    }
}
