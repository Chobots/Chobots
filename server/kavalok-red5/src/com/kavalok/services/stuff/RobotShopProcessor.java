package com.kavalok.services.stuff;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.Session;
import org.red5.io.utils.ObjectMap;

import com.kavalok.dao.RobotDAO;
import com.kavalok.dao.RobotSKUDAO;
import com.kavalok.dao.RobotTypeDAO;
import com.kavalok.db.Robot;
import com.kavalok.db.RobotSKU;
import com.kavalok.db.RobotType;
import com.kavalok.db.User;
import com.kavalok.dto.robot.RobotTipes;
import com.kavalok.dto.stuff.StuffTypeTO;
import com.kavalok.user.UserManager;

public class RobotShopProcessor implements IShopProcessor {

  @SuppressWarnings("unchecked")
  @Override
  public List<StuffTypeTO> getStuffTypes(Session session, String shopName) {
    // Robot catalogs are filtered via RobotType.catalog and do not rely on Shop

    ObjectMap<String, Integer> robotLevels = getRobotLevels(session);
    List<RobotType> types = new RobotTypeDAO(session).findByCatalog(shopName);
    List<StuffTypeTO> result = new ArrayList<StuffTypeTO>();

    for (RobotType robotType : types) {
      String robotName = robotType.getRobotName();
      StuffTypeTO typeTO = new StuffTypeTO(robotType);
      Boolean enabled =
          robotLevels.containsKey(robotName)
                  && robotLevels.get(robotName).intValue() >= robotType.getLevel().intValue()
              || robotType.getPlacement().equals(RobotTipes.BODY);

      typeTO.setEnabled(enabled);
      typeTO.setRobotInfo(getRobotInfo(robotType));

      if (typeTO.getPrice() == 0) {
        RobotSKU sku = new RobotSKUDAO(session).findActiveSKU(robotType);
        typeTO.setSkuInfo(getSKUInfo(sku));
      }

      if (robotType.getPlacement().equals(RobotTipes.BODY)
          && robotLevels.containsKey(robotType.getName())) {
        typeTO.setEnabled(false);
      }

      result.add(typeTO);
    }

    return result;
  }

  private ObjectMap<String, Object> getSKUInfo(RobotSKU sku) {
    ObjectMap<String, Object> result = null;
    if (sku != null) {
      result = new ObjectMap<String, Object>();
      result.put("id", sku.getId());
      result.put("price", sku.getPriceStr());
      result.put("sign", sku.getCurrencySign());
    }
    return result;
  }

  private ObjectMap<String, Object> getRobotInfo(RobotType robotType) {
    ObjectMap<String, Object> result = new ObjectMap<String, Object>();

    result.put("percent", robotType.getPercent());
    result.put("level", robotType.getLevel());
    result.put("placement", robotType.getPlacement());
    if (robotType.getEnergy() > 0) {
      result.put("energy", robotType.getEnergy());
    }
    if (robotType.getAttack() > 0) {
      result.put("attack", robotType.getAttack());
    }
    if (robotType.getDefence() > 0) {
      result.put("defence", robotType.getDefence());
    }
    if (robotType.getAccuracy() > 0) {
      result.put("accuracy", robotType.getAccuracy());
    }
    if (robotType.getMobility() > 0) {
      result.put("mobility", robotType.getMobility());
    }
    if (robotType.getUseCount() > 0) {
      result.put("useCount", robotType.getUseCount());
    }
    if (robotType.getLifeTime() > 0) {
      result.put("lifeTime", robotType.getLifeTime());
    }

    return result;
  }

  private ObjectMap<String, Integer> getRobotLevels(Session session) {
    User user = new User();
    user.setId(UserManager.getInstance().getCurrentUser().getUserId());
    List<Robot> robots = new RobotDAO(session).findByUser(user);
    Integer maxLevel = 0;

    ObjectMap<String, Integer> result = new ObjectMap<String, Integer>();
    for (Robot robot : robots) {
      String robotName = robot.getName();
      if (!result.containsKey(robotName)
          || robot.getLevel().intValue() > result.get(robotName).intValue()) {
        result.put(robotName, robot.getLevel());
      }

      if (robot.getLevel().intValue() > maxLevel.intValue()) {
        maxLevel = robot.getLevel();
      }
    }

    result.put("*", maxLevel);

    return result;
  }

  @Override
  public Integer getStuffTypesCount(Session session, String shopName) {
    // Count robot items by catalog via RobotType
    return new RobotTypeDAO(session).findByCatalog(shopName).size();
  }
}
