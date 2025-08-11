package com.kavalok.sharedObjects;

import java.util.ArrayList;

import org.red5.io.utils.ObjectMap;
import org.red5.server.api.so.ISharedObjectBase;

import com.kavalok.dto.CharTO;
import com.kavalok.dto.robot.CombatActionTO;
import com.kavalok.dto.robot.CombatResultTO;
import com.kavalok.dto.robot.RobotItemTO;
import com.kavalok.dto.robot.RobotTO;
import com.kavalok.dto.robot.RobotWrapper;
import com.kavalok.robots.CombatPlayer;
import com.kavalok.robots.CombatUtil;
import com.kavalok.robots.RobotUtil;
import com.kavalok.services.CharService;
import com.kavalok.services.RobotService;
import com.kavalok.services.RobotServiceNT;
import com.kavalok.utils.timer.TimerUtil;

public class CombatListener extends SOListener {

  public static final int NUM_PLAYERS = 2;
  public static final String REMOTE_PREFIX = "combat|";
  public static final String CLIENT_ID = "C";

  private static final String STATE_CREATION = "creation";
  private static final String STATE_INITIALIZATION = "initialization";
  private static final String STATE_ACTION_START = "actionStart";
  private static final String STATE_ACTION_COMPLETE = "actionComplete";
  private static final String STATE_DEACTIVATED = "deactivated";

  private ObjectMap<Long, CombatPlayer> players;

  private String combatState;

  public CombatListener() {
    super();

    players = new ObjectMap<Long, CombatPlayer>();
    combatState = STATE_CREATION;
  }

  @Override
  public void onSharedObjectConnect(ISharedObjectBase sharedObject) {
    super.onSharedObjectConnect(sharedObject);

    if (combatState.equals(STATE_CREATION)) {
      Long userId = getUserId();
      players.put(userId, new CombatPlayer(userId));
      if (players.size() == NUM_PLAYERS) {
        initializeCombat();
        TimerUtil.callAfter(this, "sendInitialize", 100);
      }
    }
  }

  @Override
  public void onSharedObjectDisconnect(ISharedObjectBase sharedObject) {
    super.onSharedObjectDisconnect(sharedObject);

    if (combatState.equals(STATE_ACTION_START) || combatState.equals(STATE_ACTION_COMPLETE)) {
      combatState = STATE_DEACTIVATED;

      Long userId = getUserId();

      CombatPlayer player = players.get(userId);
      CombatResultTO result = player.getResult();
      RobotWrapper robot = player.getRobot();
      result.setLevel(robot.getLevel());
      result.setExperience(robot.getExperience());
      result.setEnergy(robot.getEnergy());
      saveResult(robot.getId(), result, false, player.getUsedItems());
    }
  };

  public void initializeCombat() {
    for (CombatPlayer player : players.values()) {
      RobotTO robotTO = getRobotTO(player.getUserId());
      CharTO chartTO = getCharTO(player.getUserId());
      player.setUser(chartTO);
      player.setRobot(new RobotWrapper(robotTO));
    }
    combatState = STATE_INITIALIZATION;
  }

  @SuppressWarnings("unused")
  public void sendInitialize() {
    callClient(CLIENT_ID, "rInitialize");
  }

  @SuppressWarnings("unused")
  public boolean svReady() {
    if (combatState.equals(STATE_INITIALIZATION)) {
      CombatPlayer player = players.get(getUserId());
      player.setReady(true);
      if (isPlayersReady()) startAction();
    }
    return true;
  }

  private void startAction() {
    combatState = STATE_ACTION_START;
    callClient(CLIENT_ID, "rStartAction");
  }

  public boolean svPlayerAction(CombatActionTO action) {

    if (combatState.equals(STATE_ACTION_START)) {
      CombatPlayer player = players.get(getUserId());
      player.setAction(action);
      if (isActionReady()) processAction();
    }

    return true;
  }

  private void processAction() {
    CombatPlayer[] playersArray = players.values().toArray(new CombatPlayer[0]);

    CombatPlayer player1 = playersArray[0];
    CombatPlayer player2 = playersArray[1];

    CombatUtil.applyCombat(player1, player2);
    CombatUtil.applyCombat(player2, player1);

    CombatUtil.applyEnergy(player1, player2);
    CombatUtil.applyEnergy(player2, player1);

    if (player1.getRobot().getEnergy() == 0 || player2.getRobot().getEnergy() == 0) {
      checkResult(player1, player2);
      combatState = STATE_DEACTIVATED;
    } else {
      combatState = STATE_ACTION_COMPLETE;
    }

    ArrayList<CombatResultTO> result = new ArrayList<CombatResultTO>();
    result.add(player1.getResult());
    result.add(player2.getResult());

    callClient(CLIENT_ID, "rActionResult", result);
  }

  private void checkResult(CombatPlayer player1, CombatPlayer player2) {

    RobotWrapper robot1 = player1.getRobot();
    RobotWrapper robot2 = player2.getRobot();
    boolean winner1 = false;
    boolean winner2 = false;

    player1.setTotalDamage(Math.min(player1.getTotalDamage(), robot2.getMaxEnergy()));
    player2.setTotalDamage(Math.min(player2.getTotalDamage(), robot1.getMaxEnergy()));

    if (robot1.getEnergy() > 0 && robot2.getEnergy() == 0) {
      winner1 = true;
      setWinner(player1, player2);
      setLooser(player2);
    } else if (robot2.getEnergy() > 0 && robot1.getEnergy() == 0) {
      winner2 = true;
      setWinner(player2, player1);
      setLooser(player1);
    } else if (robot1.getEnergy() == 0 && robot2.getEnergy() == 0) {
      setLooser(player1);
      setLooser(player2);
    }
    saveResult(robot1.getId(), player1.getResult(), winner1, player1.getUsedItems());
    saveResult(robot2.getId(), player2.getResult(), winner2, player2.getUsedItems());
  }

  private void setLooser(CombatPlayer player) {
    CombatResultTO result = player.getResult();
    RobotWrapper robot = player.getRobot();
    int earnedExp; // = Math.max(RobotUtil.getEarnedExp(player.getTotalDamage()) / 2, 1);
    earnedExp = 1;

    result.setFinished(true);
    result.setLevel(robot.getLevel());
    result.setExperience(robot.getExperience() + earnedExp);
    result.setEnergy(robot.getEnergy());

    int nextExp = RobotUtil.getExperience(robot.getLevel() + 1);
    if (result.getExperience() >= nextExp) {
      result.setLevel(robot.getLevel() + 1);
    }
  }

  private void setWinner(CombatPlayer player, CombatPlayer opponent) {

    CombatResultTO result = player.getResult();
    RobotWrapper robot = player.getRobot();
    int earnedExp; // = RobotUtil.getEarnedExp(player.getTotalDamage());
    int level1 = player.getRobot().getLevel().intValue();
    int level2 = opponent.getRobot().getLevel().intValue();
    if (level1 > level2) {
      earnedExp = 2;
    } else if (level1 == level2) {
      earnedExp = 6;
    } else {
      earnedExp = 8;
    }

    result.setFinished(true);
    result.setLevel(robot.getLevel());
    result.setExperience(robot.getExperience() + earnedExp);
    result.setEnergy(robot.getMaxEnergy());

    int nextExp = RobotUtil.getExperience(robot.getLevel() + 1);
    if (result.getExperience() >= nextExp) {
      result.setLevel(robot.getLevel() + 1);
    }
  }

  @SuppressWarnings("unused")
  public boolean svComplete() {
    if (combatState.equals(STATE_ACTION_COMPLETE)) {
      CombatPlayer player = players.get(getUserId());
      player.setAction(null);
      if (isActionComplete()) startAction();
    }
    return true;
  }

  private boolean isActionReady() {
    for (CombatPlayer player : players.values()) {
      if (player.getAction() == null) {
        return false;
      }
    }
    return true;
  }

  private boolean isPlayersReady() {
    for (CombatPlayer player : players.values()) {
      if (!player.isReady()) {
        return false;
      }
    }
    return true;
  }

  private boolean isActionComplete() {
    for (CombatPlayer player : players.values()) {
      if (player.getAction() != null) {
        return false;
      }
    }
    return true;
  }

  private void saveResult(
      Long robotId,
      CombatResultTO result,
      boolean winner,
      ObjectMap<Integer, RobotItemTO> usedItems) {
    RobotService service = new RobotService();
    service.beforeCall();
    service.saveCombatResult(robotId, result, winner, usedItems);
    service.afterCall();
  }

  private RobotTO getRobotTO(Long userId) {
    RobotServiceNT service = new RobotServiceNT();
    service.beforeCall();
    RobotTO result = service.getCharRobot(toInteger(userId));
    service.afterCall();
    return result;
  }

  private CharTO getCharTO(Long userId) {
    CharService service = new CharService();
    service.beforeCall();
    CharTO result = service.getCharView(toInteger(userId));
    service.afterCall();
    return result;
  }

  private Integer toInteger(Long value) {
    return new Integer(value.intValue());
  }

  public void onSharedObjectDestroy(ISharedObjectBase so) {}

  public ObjectMap<Long, CombatPlayer> getPlayers() {
    return players;
  }
}
