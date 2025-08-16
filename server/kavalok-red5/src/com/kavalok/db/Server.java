package com.kavalok.db;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Transient;
import javax.validation.constraints.NotNull;

@Entity
public class Server extends ModelBase {
  private String remoteHost;
  private String lanHost;

  private boolean available;

  private boolean running;

  private Integer rtmpPort;

  private boolean tls;

  @Column
  public String getRemoteHost() {
    return remoteHost;
  }

  public void setRemoteHost(String remoteHost) {
    this.remoteHost = remoteHost;
  }

  @Column
  public String getLanHost() {
    return lanHost;
  }

  public void setLanHost(String lanHost) {
    this.lanHost = lanHost;
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
  public String getXMLRPCHost() {
    return lanHost != null ? lanHost : (remoteHost != null ? remoteHost : "127.0.0.1");
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

  @Column(columnDefinition = "integer default 8935")
  public Integer getRtmpPort() {
    return rtmpPort;
  }

  public void setRtmpPort(Integer rtmpPort) {
    this.rtmpPort = rtmpPort;
  }

  @NotNull
  @Column(columnDefinition = "boolean default false")
  public boolean isTls() {
    return tls;
  }

  public void setTls(boolean tls) {
    this.tls = tls;
  }
}
