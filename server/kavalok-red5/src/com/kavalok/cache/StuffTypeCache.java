package com.kavalok.cache;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.kavalok.db.Shop;
import com.kavalok.db.StuffType;

public class StuffTypeCache {

  private static StuffTypeCache instance = new StuffTypeCache();

  private Map<Long, StuffTypeWrapper> stuffTypeMap = new HashMap<Long, StuffTypeWrapper>();

  private Map<String, List<StuffTypeWrapper>> stuffTypesMap =
      new HashMap<String, List<StuffTypeWrapper>>();

  public static StuffTypeCache getInstance() {
    return instance;
  }

  public void clear() {
    stuffTypeMap.clear();
    stuffTypesMap.clear();
  }

  public StuffTypeWrapper putStuffType(StuffType stuffType) {
    StuffTypeWrapper stuffTypeWrapper = new StuffTypeWrapper(stuffType);
    stuffTypeMap.put(stuffType.getId(), stuffTypeWrapper);
    return stuffTypeWrapper;
  }

  public StuffTypeWrapper getStuffType(Long id) {
    return stuffTypeMap.get(id);
  }

  private String getTypesKey(Integer groupNum, Shop shop) {
    return shop.getId() + "|" + groupNum;
  }

  private String getTypesKey(Shop shop) {
    return shop.getId() + "|";
  }

  public List<StuffTypeWrapper> putStuffTypes(
      Integer groupNum, Shop shop, List<StuffType> stuffTypes) {
    List<StuffTypeWrapper> result = new ArrayList<StuffTypeWrapper>();
    for (int i = 0; i < stuffTypes.size(); i++) {
      StuffTypeWrapper stuffTypeWrapper = new StuffTypeWrapper(stuffTypes.get(i));
      result.add(stuffTypeWrapper);
    }
    stuffTypesMap.put(getTypesKey(groupNum, shop), result);
    return result;
  }

  public List<StuffTypeWrapper> getStuffTypes(Integer groupNum, Shop shop) {
    List<StuffTypeWrapper> result = stuffTypesMap.get(getTypesKey(groupNum, shop));

    return result;
  }

  public List<StuffTypeWrapper> putStuffTypes(Shop shop, List<StuffType> stuffTypes) {
    List<StuffTypeWrapper> result = new ArrayList<StuffTypeWrapper>();
    for (int i = 0; i < stuffTypes.size(); i++) {
      StuffTypeWrapper stuffTypeWrapper = new StuffTypeWrapper(stuffTypes.get(i));
      result.add(stuffTypeWrapper);
    }
    stuffTypesMap.put(getTypesKey(shop), result);
    return result;
  }

  public List<StuffTypeWrapper> getStuffTypes(Shop shop) {
    List<StuffTypeWrapper> result = stuffTypesMap.get(getTypesKey(shop));

    return result;
  }
}
