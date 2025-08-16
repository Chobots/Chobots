package com.kavalok.dto;

import com.kavalok.db.Server;

public class ServerTO {

  private int id;

  private String url = "kavalok";

  private String name;

  private int load;

  private boolean available;

  private boolean running;

  private Integer rtmpPort;

  private boolean tls;

  public ServerTO(Server server) {
    super();
    id = server.getId().intValue();
    name = server.getName();
    available = server.isAvailable();
    running = server.isRunning();
    rtmpPort = server.getRtmpPort();
    tls = server.isTls();
  }

  public ServerTO() {
    super();
  }

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public String getUrl() {
    return url;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public int getLoad() {
    return load;
  }

  public void setLoad(int load) {
    this.load = load;
  }

  public boolean isAvailable() {
    return available;
  }

  public void setAvailable(boolean available) {
    this.available = available;
  }

  public boolean isRunning() {
    return running;
  }

  public void setRunning(boolean running) {
    this.running = running;
  }

  public Integer getRtmpPort() {
    return rtmpPort;
  }

  public void setRtmpPort(Integer rtmpPort) {
    this.rtmpPort = rtmpPort;
  }

  public boolean isTls() {
    return tls;
  }

  public void setTls(boolean tls) {
    this.tls = tls;
  }
}
