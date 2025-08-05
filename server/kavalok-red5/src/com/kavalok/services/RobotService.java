package com.kavalok.services;

import java.util.Date;
import java.util.LinkedHashMap;

import org.red5.io.utils.ObjectMap;

import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.RobotDAO;
import com.kavalok.dao.RobotItemDAO;
import com.kavalok.dao.RobotTeamDAO;
import com.kavalok.dao.RobotTypeDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.db.GameChar;
import com.kavalok.db.Robot;
import com.kavalok.db.RobotItem;
import com.kavalok.db.RobotTeam;
import com.kavalok.db.RobotType;
import com.kavalok.db.User;
import com.kavalok.dto.CharTOCache;
import com.kavalok.dto.robot.CombatResultTO;
import com.kavalok.dto.robot.RobotItemSaveTO;
import com.kavalok.dto.robot.RobotItemTO;
import com.kavalok.dto.robot.RobotSaveTO;
import com.kavalok.dto.robot.RobotTO;
import com.kavalok.dto.robot.RobotWrapper;
import com.kavalok.robots.RobotConstants;
import com.kavalok.robots.RobotSaveCommand;
import com.kavalok.robots.RobotUtil;
import com.kavalok.robots.TeamUtil;
import com.kavalok.services.common.DataServiceBase;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.utils.ShopAccessUtil;

public class RobotService extends DataServiceBase {

  public void createTeam(Integer color) {
    new TeamUtil(getSession()).createTeam(color);
    getAdapter().addMoney(getSession(), -RobotConstants.TEAM_PRICE, "team creation");
  }

  public void addToTeam(Integer ownerId) {
    new TeamUtil(getSession()).addToTeam(ownerId);
  }

  public void removeFromTeam(Integer userId) {
    new TeamUtil(getSession()).removeFromTeam(userId);
  }

  public void repairRobot(Integer robotId) {
    UserAdapter adapter = getAdapter();
    RobotDAO robotDAO = new RobotDAO(getSession());
    Robot robot = robotDAO.findById(new Long(robotId));
    if (adapter.getUserId().equals(robot.getUser_id())) {

      GameChar gameChar = new GameCharDAO(getSession()).findByUserId(adapter.getUserId());
      int price = RobotUtil.getRepairCost(robot.getLevel());

      if (gameChar.getMoney() < price) {
        throw new IllegalStateException("Char doesn't have enough money");
      }
      adapter.addMoney(getSession(), -price, "robot repair");

      RobotTO robotTO = new RobotTO(robot, RobotUtil.getRobotItems(getSession(), robot));
      int maxEnergy = new RobotWrapper(robotTO).getMaxEnergy();
      robot.setEnergy(maxEnergy);
      robotDAO.makePersistent(robot);
    }
  }

  public void saveCombatResult(
      Long robotId,
      CombatResultTO result,
      boolean winner,
      ObjectMap<Integer, RobotItemTO> usedItems) {

    RobotDAO dao = new RobotDAO(getSession());
    Robot robot = dao.findById(robotId);
    int earnedExp = result.getExperience() - robot.getExperience();
    robot.setExperience(result.getExperience());
    robot.setEnergy(result.getEnergy());
    robot.setLevel(result.getLevel());
    robot.setNumCombats(robot.getNumCombats() + 1);
    if (winner) {
      robot.setNumWin(robot.getNumWin() + 1);
    }
    dao.makePersistent(robot);

    RobotItemDAO itemDAO = new RobotItemDAO(getSession());
    for (RobotItemTO itemTO : usedItems.values()) {
      RobotItem item = itemDAO.findById(itemTO.getId());
      item.setRemains(Math.max(itemTO.getRemains(), 0));
      itemDAO.makePersistent(item);
    }

    // update team
    User user = new UserDAO(getSession()).findById(robot.getUser_id());
    RobotTeam team = user.getRobotTeam();
    if (team != null) {
      team.setNumCombats(team.getNumCombats() + 1);
      team.setExperience(team.getExperience() + earnedExp);
      if (winner) {
        team.setNumWin(team.getNumWin() + 1);
      }
      new RobotTeamDAO(getSession()).makePersistent(team);
    }
  }

  public RobotTO saveRobots(
      LinkedHashMap<Integer, RobotSaveTO> robotsData,
      LinkedHashMap<Integer, RobotItemSaveTO> itemsData) {

    new RobotSaveCommand(getSession(), robotsData.values(), itemsData.values()).execute();
    return RobotUtil.getCharRobot(getSession(), getAdapter().getUserId().intValue());
  }

  public void buyItem(Integer typeId, Integer color) {
    UserAdapter adapter = getAdapter();
    User user = new UserDAO(getSession()).findById(adapter.getUserId());
    Long robotTypeId = typeId.longValue();
    RobotType type = new RobotTypeDAO(getSession()).findById(robotTypeId);
    
    // Check if user has access to buy from this catalog
    ShopAccessUtil.checkShopAccess(getSession(), type.getCatalog());
    
    if (type.getPrice() == 0) {
      throw new IllegalStateException("Char cannot buy payed item");
    }
    buyItem(user, type, color, true);

    adapter.addMoney(getSession(), -type.getPrice(), "stuff bought");
  }

  public RobotItem buyItem(User user, RobotType type, Integer color, boolean checkCharMoney) {
    if (checkCharMoney) {
      GameChar gameChar = user.getGameChar();
      if (gameChar.getMoney() < type.getPrice()) {
        throw new IllegalStateException("Char doesn't have enough money");
      }
    }

    RobotItem item = new RobotItem();
    item.setUser(user);
    item.setType(type);
    item.setColor(color);
    item.setRemains(type.getUseCount());

    if (type.getLifeTime() > 0) {
      Date expirationDate =
          new Date(new Date().getTime() + 1000 * 60 * 60 * 24 * type.getLifeTime());
      item.setExpirationDate(expirationDate);
    }

    if ("#".equals(type.getPlacement())) { // Robot body

      RobotDAO robotDAO = new RobotDAO(getSession());
      Boolean robotExists = robotDAO.robotExists(user);

      Robot robot = new Robot();
      robot.setUser(user);
      robot.setUserLogin(user.getLogin());
      robot.setName(type.getName());
      robot.setEnergy(type.getEnergy());
      robot.setLevel(1);
      robot.setActive(!robotExists);
      new RobotDAO(getSession()).makePersistent(robot);
      CharTOCache.getInstance().removeCharTO(user.getId());
      CharTOCache.getInstance().removeCharTO(user.getLogin());

      item.setRobot(robot);
    }

    new RobotItemDAO(getSession()).makePersistent(item);
    return item;
  }
}
