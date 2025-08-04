package com.kavalok.dto.login;

public class LoginResultTO {

  private Boolean success;

  private Boolean active;

  private String reason;

  private Long age;

  private String loginToken;

  public LoginResultTO(Boolean success, Boolean active, long age, String reason) {
    super();
    this.success = success;
    this.active = active;
    this.reason = reason;
    this.age = age;
  }

  public LoginResultTO() {
    // TODO Auto-generated constructor stub
  }

  public Boolean getSuccess() {
    return success;
  }

  public void setSuccess(Boolean success) {
    this.success = success;
  }

  public Boolean getActive() {
    return active;
  }

  public void setActive(Boolean active) {
    this.active = active;
  }

  public String getReason() {
    return reason;
  }

  public void setReason(String reason) {
    this.reason = reason;
  }

  public Long getAge() {
    return age;
  }

  public void setAge(Long age) {
    this.age = age;
  }

  public String getLoginToken() {
    return loginToken;
  }

  public void setLoginToken(String loginToken) {
    this.loginToken = loginToken;
  }
}
