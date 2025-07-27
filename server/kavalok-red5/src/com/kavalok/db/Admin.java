package com.kavalok.db;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Transient;

import com.kavalok.permissions.AccessAdmin;

@Entity
public class Admin extends LoginModelBase {
  private Integer permissionLevel = 0;
  private String salt;

  @SuppressWarnings("unchecked")
  @Override
  @Transient
  public Class getAccessType() {
    return AccessAdmin.class;
  }

  public Integer getPermissionLevel() {
    return permissionLevel;
  }

  public void setPermissionLevel(Integer permissionLevel) {
    this.permissionLevel = permissionLevel == null ? 0 : permissionLevel;
  }

  @Column(length = 64)
  public String getSalt() {
    return salt;
  }
  public void setSalt(String salt) {
    this.salt = salt;
  }
}
