package com.kavalok.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;

import com.kavalok.cache.StuffTypeCache;
import com.kavalok.cache.StuffTypeWrapper;
import com.kavalok.dao.common.DAO;
import com.kavalok.db.Shop;
import com.kavalok.db.StuffType;
import com.kavalok.dto.stuff.StuffTypeTO;
import com.kavalok.utils.ReflectUtil;

public class StuffTypeDAO extends DAO<StuffType> {

  private Map<String, Long> SHOP_CACHE = new HashMap<String, Long>();

  public StuffTypeDAO(Session session) {
    super(session);
  }

  public List<StuffTypeWrapper> findByShopName(String shopName) {
    Shop shop = getShop(shopName);
    return findByShop(shop);
  }

  private Shop getShop(String shopName) {
    Long shopId = SHOP_CACHE.get(shopName);
    if (shopId == null) {
      shopId = new ShopDAO(getSession()).findByName(shopName).getId();
      SHOP_CACHE.put(shopName, shopId);
    }
    Shop result = new Shop();
    result.setId(shopId);
    result.setName(shopName);
    return result;
  }

  @SuppressWarnings("unchecked")
  public List<StuffTypeWrapper> findByShopName(String shopName, Integer groupNum) {
    long now = System.currentTimeMillis();
    Shop shop = getShop(shopName);

    now = System.currentTimeMillis();
    List result = StuffTypeCache.getInstance().getStuffTypes(groupNum, shop);
    if (result == null) {
      Criteria criteria = createCriteria();
      criteria.add(
          Restrictions.or(Restrictions.eq("groupNum", 0), Restrictions.eq("groupNum", groupNum)));
      criteria.add(Restrictions.eq("shop", shop));
      criteria.addOrder(Order.asc("premium"));
      criteria.addOrder(Order.desc("id"));

      List stuffs = criteria.list();
      result = StuffTypeCache.getInstance().putStuffTypes(groupNum, shop, stuffs);
    }

    return result;
  }

  @SuppressWarnings("unchecked")
  public List<StuffTypeWrapper> findByShopNamePaged(
      String shopName, Integer groupNum, Integer pageNum, Integer itemsPerPage) {
    long now = System.currentTimeMillis();
    Shop shop = getShop(shopName);

    now = System.currentTimeMillis();
    List result;
    List stuffs = StuffTypeCache.getInstance().getStuffTypes(groupNum, shop);
    if (stuffs != null) {
      result = stuffs.subList(pageNum * itemsPerPage, pageNum * itemsPerPage + itemsPerPage);
    } else {
      Criteria criteria = createCriteria();
      criteria.add(
          Restrictions.or(Restrictions.eq("groupNum", 0), Restrictions.eq("groupNum", groupNum)));
      criteria.add(Restrictions.eq("shop", shop));
      criteria.addOrder(Order.asc("premium"));
      criteria.addOrder(Order.desc("id"));

      stuffs = criteria.list();
      result =
          StuffTypeCache.getInstance()
              .putStuffTypes(groupNum, shop, stuffs)
              .subList(pageNum * itemsPerPage, pageNum * itemsPerPage + itemsPerPage);
    }

    return result;
  }

  public Integer findByShopNameCount(String shopName, Integer groupNum) {
    Shop shop = getShop(shopName);
    List<StuffTypeWrapper> stuffs = StuffTypeCache.getInstance().getStuffTypes(groupNum, shop);
    if (stuffs == null) {
      stuffs = findByShopName(shopName, groupNum);
    }
    Integer result = stuffs.size();
    return result;
  }

  @SuppressWarnings("unchecked")
  public List<StuffTypeWrapper> findByShop(Shop shop) {

    long now = System.currentTimeMillis();
    List result = StuffTypeCache.getInstance().getStuffTypes(shop);
    if (result == null) {
      Criteria criteria = createCriteria();
      criteria.add(Restrictions.eq("shop", shop));
      criteria.addOrder(Order.asc("premium"));
      criteria.addOrder(Order.desc("id"));

      List stuffs = criteria.list();
      result = StuffTypeCache.getInstance().putStuffTypes(shop, stuffs);
    }

    return result;
  }

  private static final Map<String, StuffType> STUFF_TYPES_BY_NAME =
      new HashMap<String, StuffType>();

  public StuffType findByFileName(String fileName) {
    StuffType result = STUFF_TYPES_BY_NAME.get(fileName);
    if (result == null) {
      result = findByParameter("fileName", fileName);
      if (result != null) {
        STUFF_TYPES_BY_NAME.put(fileName, result);
      }
    }
    return result;
  }

  public List<StuffType> findByFileNames(Object[] fileNames) {
    return findAllByParameterValues("fileName", fileNames);
  }

  public StuffType findByItemOfTheMonth(String itemOfTheMonth) {
    return findByParameter("itemOfTheMonth", itemOfTheMonth);
  }

  @SuppressWarnings("unchecked")
  public List<StuffTypeTO> getRainableStuffs() {
    Criteria criteria = createCriteria();
    criteria.add(Restrictions.eq("rainable", true));
    criteria.addOrder(Order.asc("type"));
    criteria.addOrder(Order.asc("fileName"));
    List<StuffType> types = criteria.list();
    return ReflectUtil.convertBeansByConstructor(types, StuffTypeTO.class);
  }
}
