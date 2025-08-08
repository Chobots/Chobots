package com.kavalok.db;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Transient;
import javax.validation.constraints.NotNull;

@Entity
public class Server extends ModelBase {

  private String scopeName;

  private String remoteHost;

  private boolean available;

  private boolean running;

  @NotNull
  @Column(unique = true)
  public String getScopeName() {
    return scopeName;
  }

  public void setScopeName(String scopeName) {
    this.scopeName = scopeName;
  }

  @Column
  public String getRemoteHost() {
    return remoteHost;
  }

  public void setRemoteHost(String remoteHost) {
    this.remoteHost = remoteHost;
  }

  @NotNull
  @Column(columnDefinition = "boolean default false")
  public boolean isAvailable() {
    return available;
  }

  public void setAvailable(boolean available) {
    this.available = available;
  }

  @Transient
  public String getContextPath() {
    return getScopeName();
  }

  @Transient
  public String getXMLRPCHost() {
    return remoteHost != null ? remoteHost : "127.0.0.1";
  }

  @Transient
  public String getName() {
    return "Serv" + getId();
  }

  public Server() {
    super();
  }

  @NotNull
  @Column(columnDefinition = "boolean default false")
  public boolean isRunning() {
    return running;
  }

  public void setRunning(boolean running) {
    this.running = running;
  }
}
