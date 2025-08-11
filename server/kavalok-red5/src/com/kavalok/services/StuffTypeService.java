package com.kavalok.services;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.kavalok.cache.StuffTypeWrapper;
import com.kavalok.dao.ServerDAO;
import com.kavalok.dao.ShopDAO;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.db.Server;
import com.kavalok.db.Shop;
import com.kavalok.db.StuffType;
import com.kavalok.dto.stuff.StuffTypeAdminTO;
import com.kavalok.services.common.DataServiceBase;
import com.kavalok.utils.ReflectUtil;
import com.kavalok.utils.ShopAccessUtil;
import com.kavalok.xmlrpc.RemoteClient;

public class StuffTypeService extends DataServiceBase {

  public StuffTypeService() {
    super();
  }

  @SuppressWarnings("unchecked")
  public List<StuffTypeAdminTO> getStuffList() {
    StuffTypeDAO dao = new StuffTypeDAO(getSession());
    List<StuffType> typeList = (List<StuffType>) dao.findAll();
    List<StuffTypeAdminTO> toList =
        ReflectUtil.convertBeansByConstructor(typeList, StuffTypeAdminTO.class);
    return toList;
  }

  @SuppressWarnings("unchecked")
  public List<StuffTypeAdminTO> getStuffListByShop(String shopName) {
    // Check if user has access to this shop
    ShopAccessUtil.checkShopAccess(getSession(), shopName);

    StuffTypeDAO dao = new StuffTypeDAO(getSession());
    List<StuffTypeWrapper> typeList = dao.findByShopName(shopName);
    List<StuffTypeAdminTO> toList =
        ReflectUtil.convertBeansByConstructor(typeList, StuffTypeAdminTO.class);
    return toList;
  }

  public List<String> getShops() {
    ShopDAO dao = new ShopDAO(getSession());
    List<Shop> shops = dao.findAll();
    List<String> result = new ArrayList<String>();
    for (Shop shop : shops) {
      // Check if user has access to each shop before adding it to the list
      try {
        ShopAccessUtil.checkShopAccess(getSession(), shop.getName());
        result.add(shop.getName());
      } catch (SecurityException e) {
        // Skip shops the user doesn't have access to
        continue;
      }
    }
    return result;
  }

  public void saveItem(StuffTypeAdminTO item) {
    if (StringUtils.isBlank(item.getFileName())
        || StringUtils.isBlank(item.getShopName())
        || StringUtils.isBlank(item.getType())) {
      return;
    }

    // Check if user has access to the shop before saving
    ShopAccessUtil.checkShopAccess(getSession(), item.getShopName());

    StuffTypeDAO stuffDAO = new StuffTypeDAO(getSession());
    StuffType stuff = new StuffType();
    if (item.getId() != null && item.getId() > 0) stuff = stuffDAO.findById(item.getId());

    ShopDAO shopDAO = new ShopDAO(getSession());
    Shop shop = shopDAO.findByName(item.getShopName());

    stuff.setPremium(item.getPremium());
    stuff.setHasColor(item.getHasColor());
    stuff.setGiftable(item.getGiftable());
    stuff.setRainable(item.getRainable());
    stuff.setPrice(item.getPrice());
    stuff.setShop(shop);
    stuff.setPlacement(item.getPlacement());
    stuff.setInfo(item.getInfo());
    stuff.setItemOfTheMonth(item.getItemOfTheMonth());
    stuff.setGroupNum(item.getGroupNum());
    stuff.setName(item.getName());
    stuff.setFileName(item.getFileName());
    stuff.setType(item.getType());
    stuffDAO.makePersistent(stuff);

    List<Server> servers = new ServerDAO(getSession()).findRunning();
    for (Server server : servers) {
      try {
        new RemoteClient(server).refreshStuffTypeCache();
      } catch (Exception e) {

      }
    }
  }
}
