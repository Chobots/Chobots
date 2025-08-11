package com.kavalok.services;

import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.kavalok.dao.ShopDAO;
import com.kavalok.db.Shop;
import com.kavalok.dto.shop.ShopAdminTO;
import com.kavalok.services.common.DataServiceBase;
import com.kavalok.utils.ReflectUtil;

public class ShopService extends DataServiceBase {

  public ShopService() {
    super();
  }

  public List<ShopAdminTO> getShops() {
    ShopDAO dao = new ShopDAO(getSession());
    List<Shop> shopList = dao.findAll();
    List<ShopAdminTO> toList = ReflectUtil.convertBeansByConstructor(shopList, ShopAdminTO.class);
    return toList;
  }

  public String saveShop(ShopAdminTO item) {
    if (StringUtils.isBlank(item.getName())) {
      return null;
    }

    ShopDAO shopDAO = new ShopDAO(getSession());
    Shop shop = new Shop();
    if (item.getId() != null && item.getId() > 0) {
      shop = shopDAO.findById(item.getId());
    }

    shop.setName(item.getName());

    if (item.getRequiredPermission() != null && !item.getRequiredPermission().isEmpty()) {
      try {
        com.kavalok.db.UserPermission permission =
            com.kavalok.db.UserPermission.valueOf(item.getRequiredPermission());
        shop.setRequiredPermission(permission);
      } catch (IllegalArgumentException e) {
        // Invalid permission value, ignore
      }
    } else {
      // Default to PUBLIC if no permission is specified
      shop.setRequiredPermission(com.kavalok.db.UserPermission.PUBLIC);
    }

    shopDAO.makePersistent(shop);
    String shopId = shop.getId().toString();
    return shopId;
  }
}
