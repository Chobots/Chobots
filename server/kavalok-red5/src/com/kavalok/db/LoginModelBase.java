package com.kavalok.db;

import javax.persistence.Column;
import javax.persistence.MappedSuperclass;
import javax.persistence.Transient;
import javax.validation.constraints.NotNull;

@MappedSuperclass
public class LoginModelBase extends ModelBase {

  private String login;

  private String password;

  @NotNull
  @Column(unique = true)
  public String getLogin() {
    return login;
  }

  public void setLogin(String login) {
    this.login = login;
  }

  @NotNull
  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  public boolean checkPassword(String inputPassword, String salt) {
    if (salt == null) {
      // Legacy: compare plaintext
      return password != null && password.equals(inputPassword);
    } else {
      // Salted hash
      String hashed = com.kavalok.utils.StringUtil.hashPassword(inputPassword, salt);
      return password != null && password.equals(hashed);
    }
  }

  @SuppressWarnings("unchecked")
  @Transient
  public Class getAccessType() {
    throw new UnsupportedOperationException();
  }
}
