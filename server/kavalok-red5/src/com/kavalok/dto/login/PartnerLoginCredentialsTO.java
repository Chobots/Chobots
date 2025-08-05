package com.kavalok.dto.login;

public class PartnerLoginCredentialsTO {

  private String login;
  private Boolean needRegistartion;
  private Integer userId;

  public PartnerLoginCredentialsTO(Integer userId, String login, Boolean needRegistartion) {
    super();
    this.userId = userId;
    this.login = login;
    this.needRegistartion = needRegistartion;
  }

  public String getLogin() {
    return login;
  }

  public void setLogin(String login) {
    this.login = login;
  }

  public Boolean getNeedRegistartion() {
    return needRegistartion;
  }

  public void setNeedRegistartion(Boolean needRegistartion) {
    this.needRegistartion = needRegistartion;
  }

  public Integer getUserId() {
    return userId;
  }

  public void setUserId(Integer userId) {
    this.userId = userId;
  }
}
