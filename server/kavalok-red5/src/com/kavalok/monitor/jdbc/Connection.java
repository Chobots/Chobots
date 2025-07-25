package com.kavalok.monitor.jdbc;

import java.sql.Array;
import java.sql.Blob;
import java.sql.CallableStatement;
import java.sql.Clob;
import java.sql.DatabaseMetaData;
import java.sql.NClob;
import java.sql.PreparedStatement;
import java.sql.SQLClientInfoException;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.SQLXML;
import java.sql.Savepoint;
import java.sql.Statement;
import java.sql.Struct;
import java.util.Map;
import java.util.Properties;

import org.red5.threadmonitoring.ThreadMonitorServices;

public class Connection implements java.sql.Connection {
  private java.sql.Connection wrapper;

  public Connection(java.sql.Connection wrapperConnection) {
    this.wrapper = wrapperConnection;
  }

  public void clearWarnings() throws SQLException {
    wrapper.clearWarnings();
  }

  public void close() throws SQLException {
    wrapper.close();
  }

  public void commit() throws SQLException {
    ThreadMonitorServices.setJobDetails("Connection.commit");
    wrapper.commit();
  }

  public Array createArrayOf(String typeName, Object[] elements) throws SQLException {
    return wrapper.createArrayOf(typeName, elements);
  }

  public Blob createBlob() throws SQLException {
    return wrapper.createBlob();
  }

  public Clob createClob() throws SQLException {
    return wrapper.createClob();
  }

  public NClob createNClob() throws SQLException {
    return wrapper.createNClob();
  }

  public SQLXML createSQLXML() throws SQLException {
    return wrapper.createSQLXML();
  }

  public Statement createStatement() throws SQLException {
    return new com.kavalok.monitor.jdbc.Statement(wrapper.createStatement());
  }

  public Statement createStatement(
      int resultSetType, int resultSetConcurrency, int resultSetHoldability) throws SQLException {
    return new com.kavalok.monitor.jdbc.Statement(
        wrapper.createStatement(resultSetType, resultSetConcurrency, resultSetHoldability));
  }

  public Statement createStatement(int resultSetType, int resultSetConcurrency)
      throws SQLException {
    return new com.kavalok.monitor.jdbc.Statement(
        wrapper.createStatement(resultSetType, resultSetConcurrency));
  }

  public Struct createStruct(String typeName, Object[] attributes) throws SQLException {
    return wrapper.createStruct(typeName, attributes);
  }

  public boolean getAutoCommit() throws SQLException {
    return wrapper.getAutoCommit();
  }

  public String getCatalog() throws SQLException {
    return wrapper.getCatalog();
  }

  public Properties getClientInfo() throws SQLException {
    return wrapper.getClientInfo();
  }

  public String getClientInfo(String name) throws SQLException {
    return wrapper.getClientInfo(name);
  }

  public int getHoldability() throws SQLException {
    return wrapper.getHoldability();
  }

  public DatabaseMetaData getMetaData() throws SQLException {
    return wrapper.getMetaData();
  }

  public int getTransactionIsolation() throws SQLException {
    return wrapper.getTransactionIsolation();
  }

  public Map<String, Class<?>> getTypeMap() throws SQLException {
    return wrapper.getTypeMap();
  }

  public SQLWarning getWarnings() throws SQLException {
    return wrapper.getWarnings();
  }

  public boolean isClosed() throws SQLException {
    return wrapper.isClosed();
  }

  public boolean isReadOnly() throws SQLException {
    return wrapper.isReadOnly();
  }

  public boolean isValid(int timeout) throws SQLException {
    return wrapper.isValid(timeout);
  }

  public boolean isWrapperFor(Class<?> iface) throws SQLException {
    return wrapper.isWrapperFor(iface);
  }

  public String nativeSQL(String sql) throws SQLException {
    return wrapper.nativeSQL(sql);
  }

  public CallableStatement prepareCall(
      String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability)
      throws SQLException {
    return wrapper.prepareCall(sql, resultSetType, resultSetConcurrency, resultSetHoldability);
  }

  public CallableStatement prepareCall(String sql, int resultSetType, int resultSetConcurrency)
      throws SQLException {
    return wrapper.prepareCall(sql, resultSetType, resultSetConcurrency);
  }

  public CallableStatement prepareCall(String sql) throws SQLException {
    return wrapper.prepareCall(sql);
  }

  public PreparedStatement prepareStatement(
      String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability)
      throws SQLException {
    return new com.kavalok.monitor.jdbc.PreparedStatement(
        sql,
        wrapper.prepareStatement(sql, resultSetType, resultSetConcurrency, resultSetHoldability));
  }

  public PreparedStatement prepareStatement(String sql, int resultSetType, int resultSetConcurrency)
      throws SQLException {
    return new com.kavalok.monitor.jdbc.PreparedStatement(
        sql, wrapper.prepareStatement(sql, resultSetType, resultSetConcurrency));
  }

  public PreparedStatement prepareStatement(String sql, int autoGeneratedKeys) throws SQLException {
    return new com.kavalok.monitor.jdbc.PreparedStatement(
        sql, wrapper.prepareStatement(sql, autoGeneratedKeys));
  }

  public PreparedStatement prepareStatement(String sql, int[] columnIndexes) throws SQLException {
    return new com.kavalok.monitor.jdbc.PreparedStatement(
        sql, wrapper.prepareStatement(sql, columnIndexes));
  }

  public PreparedStatement prepareStatement(String sql, String[] columnNames) throws SQLException {
    return new com.kavalok.monitor.jdbc.PreparedStatement(
        sql, wrapper.prepareStatement(sql, columnNames));
  }

  public PreparedStatement prepareStatement(String sql) throws SQLException {
    return new com.kavalok.monitor.jdbc.PreparedStatement(sql, wrapper.prepareStatement(sql));
  }

  public void releaseSavepoint(Savepoint savepoint) throws SQLException {
    wrapper.releaseSavepoint(savepoint);
  }

  public void rollback() throws SQLException {
    ThreadMonitorServices.setJobDetails("Connection.rollback");
    wrapper.rollback();
  }

  public void rollback(Savepoint savepoint) throws SQLException {
    ThreadMonitorServices.setJobDetails("Connection.rollback(Savepoint savepoint {0})", savepoint);
    wrapper.rollback(savepoint);
  }

  public void setAutoCommit(boolean autoCommit) throws SQLException {
    ThreadMonitorServices.setJobDetails(
        "Connection.setAutoCommit(boolean autoCommit {0})", autoCommit);
    wrapper.setAutoCommit(autoCommit);
  }

  public void setCatalog(String catalog) throws SQLException {
    wrapper.setCatalog(catalog);
  }

  public void setClientInfo(Properties properties) throws SQLClientInfoException {
    wrapper.setClientInfo(properties);
  }

  public void setClientInfo(String name, String value) throws SQLClientInfoException {
    wrapper.setClientInfo(name, value);
  }

  public void setHoldability(int holdability) throws SQLException {
    wrapper.setHoldability(holdability);
  }

  public void setReadOnly(boolean readOnly) throws SQLException {
    wrapper.setReadOnly(readOnly);
  }

  public Savepoint setSavepoint() throws SQLException {
    return wrapper.setSavepoint();
  }

  public Savepoint setSavepoint(String name) throws SQLException {
    return wrapper.setSavepoint(name);
  }

  public void setTransactionIsolation(int level) throws SQLException {
    wrapper.setTransactionIsolation(level);
  }

  public void setTypeMap(Map<String, Class<?>> map) throws SQLException {
    wrapper.setTypeMap(map);
  }

  public <T> T unwrap(Class<T> iface) throws SQLException {
    return wrapper.unwrap(iface);
  }

  // Methods added in Java 7
  public void setNetworkTimeout(java.util.concurrent.Executor executor, int milliseconds)
      throws SQLException {
    wrapper.setNetworkTimeout(executor, milliseconds);
  }

  public int getNetworkTimeout() throws SQLException {
    return wrapper.getNetworkTimeout();
  }

  // Method added in Java 9
  public void abort(java.util.concurrent.Executor executor) throws SQLException {
    wrapper.abort(executor);
  }

  // Methods added in Java 7
  public String getSchema() throws SQLException {
    return wrapper.getSchema();
  }

  public void setSchema(String schema) throws SQLException {
    wrapper.setSchema(schema);
  }
}
