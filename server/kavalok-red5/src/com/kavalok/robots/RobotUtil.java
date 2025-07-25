package com.kavalok.robots;

import java.util.List;

import org.hibernate.Session;

import com.kavalok.dao.RobotDAO;
import com.kavalok.dao.RobotItemDAO;
import com.kavalok.db.Robot;
import com.kavalok.db.RobotItem;
import com.kavalok.db.User;
import com.kavalok.dto.robot.RobotItemTO;
import com.kavalok.dto.robot.RobotTO;
import com.kavalok.utils.ReflectUtil;

public class RobotUtil {

  public static int getEnergy(int level) {
    return 5 * (level - 1);
  }

  public static int getExperience(int level) {
    int L = level - 1;
    return 3 * L * L * L + 10 * L * L + 5 * L;
  }

  public static int getEarnedExp(int targetDamage) {
    return Math.max((int) (0.1 * targetDamage), 1);
  }

  public static int getRepairCost(int level) {
    return level * 100;
  }

  public static int getEarnedMoney(int level) {
    return (int) (0.5 * getRepairCost(level));
  }

  public static RobotTO getCharRobot(Session session, Integer userId) {
    User user = new User(new Long(userId.intValue()));
    Robot robot = new RobotDAO(session).getActiveRobot(user);
    if (robot != null) {
      RobotTO result = new RobotTO(robot, getRobotItems(session, robot));
      return result;
    } else {
      return null;
    }
  }

  @SuppressWarnings("unchecked")
  public static List<RobotItemTO> getRobotItems(Session session, Robot robot) {
    List<RobotItem> items = new RobotItemDAO(session).findByRobot(robot);
    List<RobotItemTO> result = ReflectUtil.convertBeansByConstructor(items, RobotItemTO.class);
    return result;
  }
}
