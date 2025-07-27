package com.kavalok.services;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.HashSet;
import java.util.Arrays;
import java.util.Set;

import com.kavalok.dao.StuffItemDAO;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.db.GameChar;
import com.kavalok.db.StuffItem;
import com.kavalok.db.StuffType;
import com.kavalok.dto.CharTOCache;
import com.kavalok.dto.stuff.StuffItemLightTO;
import com.kavalok.dto.stuff.StuffTypeTO;
import com.kavalok.services.common.DataServiceNotTransactionBase;
import com.kavalok.services.stuff.DefaultShopProcessor;
import com.kavalok.services.stuff.ExchangeShopProcessor;
import com.kavalok.services.stuff.IShopProcessor;
import com.kavalok.services.stuff.PayedShopProcessor;
import com.kavalok.services.stuff.RobotShopProcessor;
import com.kavalok.services.stuff.UniqueItemsProcessor;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;

public class StuffServiceNT extends DataServiceNotTransactionBase {

  private HashMap<String, IShopProcessor> shopProcessors = new HashMap<String, IShopProcessor>();

  private static final SimpleDateFormat ITEM_OF_THE_MONTH_FORMAT = new SimpleDateFormat("yyyyMM");

  private static final Set<String> ALLOWED_QUEST_ITEMS = new HashSet<String>(
      Arrays.asList("globus", "glasses_professor")
  );

  public StuffServiceNT() {
    super();
    shopProcessors.put("citizenHousesShop", new UniqueItemsProcessor());
    shopProcessors.put("petGameShop", new UniqueItemsProcessor());
    shopProcessors.put("petRestShop", new UniqueItemsProcessor());
    shopProcessors.put("robots", new RobotShopProcessor());
    shopProcessors.put("robotStuffs", new RobotShopProcessor());
    shopProcessors.put("robotItems", new RobotShopProcessor());
    shopProcessors.put("payedItems", new PayedShopProcessor());
    shopProcessors.put("magicPayedShop", new PayedShopProcessor());
    shopProcessors.put("exchange", new ExchangeShopProcessor());
  }

  public StuffItemLightTO getItem(Integer itemId) {
    StuffItem item = new StuffItemDAO(getSession()).findById(itemId.longValue());
    return new StuffItemLightTO(item);
  }

  public Integer removeItem(Integer itemId) {
    StuffItemDAO itemDAO = new StuffItemDAO(getSession());
    itemDAO.makeTransient(itemId.longValue());
    return itemId;
  }

  public StuffItemLightTO retriveItemWithColor(String fileName, Integer color) {
    // SECURITY CHECK: Only allow retrieval of permitted quest items
    if (!ALLOWED_QUEST_ITEMS.contains(fileName.toLowerCase())) {
        throw new SecurityException("Unauthorized item retrieval: " + fileName);
    }
    StuffItemDAO stuffItemDAO = new StuffItemDAO(getSession());
    StuffItem item = createItem(fileName, stuffItemDAO);
    item.setColor(color);
    stuffItemDAO.makePersistent(item);
    return new StuffItemLightTO(item);
  }

  public StuffItemLightTO retriveItem(String fileName) {
    // SECURITY CHECK: Only allow retrieval of permitted quest items
    if (!ALLOWED_QUEST_ITEMS.contains(fileName.toLowerCase())) {
        throw new SecurityException("Unauthorized item retrieval: " + fileName);
    }
    StuffItemDAO stuffItemDAO = new StuffItemDAO(getSession());
    StuffItem item = createItem(fileName, stuffItemDAO);
    stuffItemDAO.makePersistent(item);
    return new StuffItemLightTO(item);
  }

  public StuffItemLightTO retriveItemByIdWithColor(Integer id, Integer color) {
    StuffItemDAO stuffItemDAO = new StuffItemDAO(getSession());
    StuffItem item = createItem(id, stuffItemDAO);
    item.setColor(color);
    stuffItemDAO.makePersistent(item);
    return new StuffItemLightTO(item);
  }

  public StuffItemLightTO retriveItemById(Integer id) {
    StuffItemDAO stuffItemDAO = new StuffItemDAO(getSession());
    StuffItem item = createItem(id, stuffItemDAO);
    stuffItemDAO.makePersistent(item);

    return new StuffItemLightTO(item);
  }

  private StuffItem createItem(String fileName, StuffItemDAO itemDao) {
    GameChar gameChar = UserManager.getInstance().getCurrentUser().getChar(getSession());
    StuffType type = new StuffTypeDAO(getSession()).findByFileName(fileName);
    StuffItem item = null;
    if (type.getRainable()) {
      List<StuffItem> items = itemDao.findItems(type, gameChar);
      if (items.size() > 1) {
        item = items.get(0);
      }
    }
    if (item == null) item = new StuffItem(type);

    item.setGameChar(gameChar);
    return item;
  }

  public StuffTypeTO getStuffType(String fileName) {
    StuffType type = new StuffTypeDAO(getSession()).findByFileName(fileName);
    StuffTypeTO result = new StuffTypeTO(type);
    return result;
  }

  private StuffItem createItem(Integer id, StuffItemDAO itemDao) {
    UserAdapter currentUser = UserManager.getInstance().getCurrentUser();
    GameChar gameChar = currentUser.getChar(getSession());
    StuffType type = new StuffTypeDAO(getSession()).findById(id.longValue());
    StuffItem item = null;
    if (type.getRainable()) {
      List<StuffItem> items = itemDao.findItems(type, gameChar);
      if (items.size() > 1) {
        item = items.get(0);
      }
    }
    if (item == null) item = new StuffItem(type);

    item.setGameChar(gameChar);
    CharTOCache.getInstance().removeCharTO(currentUser.getUserId());
    CharTOCache.getInstance().removeCharTO(currentUser.getLogin());
    return item;
  }

  public void updateStuffItem(StuffItemLightTO item) {
    StuffItemDAO stuffItemDAO = new StuffItemDAO(getSession());
    StuffItem stuffItem = stuffItemDAO.findById(item.getId().longValue());
    stuffItem.setLevel(item.getLevel());
    stuffItem.setUsed(item.getUsed());
    stuffItem.setX(item.getX());
    stuffItem.setY(item.getY());
    stuffItem.setColor(item.getColor());
    stuffItem.setRotation(item.getRotation());
    stuffItemDAO.makePersistent(stuffItem);
  }

  public List<StuffTypeTO> getItemOfTheMonthType() {
    List<StuffTypeTO> result = new ArrayList<StuffTypeTO>();
    StuffTypeDAO stDAO = new StuffTypeDAO(getSession());
    StuffType type = stDAO.findByItemOfTheMonth(ITEM_OF_THE_MONTH_FORMAT.format(new Date()) + "1");
    result.add(type != null ? new StuffTypeTO(type) : null);
    type = stDAO.findByItemOfTheMonth(ITEM_OF_THE_MONTH_FORMAT.format(new Date()) + "6");
    result.add(type != null ? new StuffTypeTO(type) : null);
    type = stDAO.findByItemOfTheMonth(ITEM_OF_THE_MONTH_FORMAT.format(new Date()) + "12");
    result.add(type != null ? new StuffTypeTO(type) : null);

    return result;
  }

  public List<StuffTypeTO> getStuffTypes(String shopName) {
    long now = System.currentTimeMillis();

    IShopProcessor processor = new DefaultShopProcessor();

    if (shopProcessors.containsKey(shopName) && getAdapter().getPersistent())
      processor = shopProcessors.get(shopName);

    List<StuffTypeTO> result = processor.getStuffTypes(getSession(), shopName);
    System.err.println(
        "getStuffTypes shopName: " + shopName + ", time: " + (System.currentTimeMillis() - now));
    return result;
  }

  public List<StuffTypeTO> getStuffTypes(String shopName, Integer pageNum, Integer itemsPerPage) {
    long now = System.currentTimeMillis();

    IShopProcessor processor = new DefaultShopProcessor();

    if (shopProcessors.containsKey(shopName) && getAdapter().getPersistent())
      processor = shopProcessors.get(shopName);

    List<StuffTypeTO> result = processor.getStuffTypes(getSession(), shopName);
    if (pageNum == 0 && result.size() > 0) {
      result.get(0).setCount(itemsPerPage);
    }
    System.err.println(
        "getStuffTypes shopName: " + shopName + ", time: " + (System.currentTimeMillis() - now));
    return result;
  }
}
