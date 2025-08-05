package com.kavalok.dto.shop;

import com.kavalok.db.Shop;

public class ShopAdminTO {

  private Long id;
  private String name;
  private String requiredPermission;

  public ShopAdminTO() {
    super();
  }

  public ShopAdminTO(Shop shop) {
    this.id = shop.getId();
    this.name = shop.getName();
    this.requiredPermission = shop.getRequiredPermission().name();
  }

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getRequiredPermission() {
    return requiredPermission;
  }

  public void setRequiredPermission(String requiredPermission) {
    this.requiredPermission = requiredPermission;
  }
} 