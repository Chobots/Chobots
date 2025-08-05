package com.kavalok.db;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.validation.constraints.NotNull;

@Entity
public class Shop extends ModelBase {

  private String name;
  private UserPermission requiredPermission = UserPermission.PUBLIC;

  @NotNull
  @Column(unique = true)
  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  @Enumerated(EnumType.STRING)
  @Column(columnDefinition = "varchar(20) default 'PUBLIC'")
  public UserPermission getRequiredPermission() {
    return requiredPermission;
  }

  public void setRequiredPermission(UserPermission requiredPermission) {
    this.requiredPermission = requiredPermission;
  }
}
