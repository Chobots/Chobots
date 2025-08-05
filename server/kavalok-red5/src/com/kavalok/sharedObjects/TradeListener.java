package com.kavalok.sharedObjects;

import java.util.ArrayList;
import java.util.HashMap;

import org.hibernate.Session;

import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.StuffItemDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.db.GameChar;
import com.kavalok.db.StuffItem;
import com.kavalok.db.User;
import com.kavalok.dto.stuff.StuffItemLightTO;
import com.kavalok.transactions.ISessionDependent;
import com.kavalok.transactions.TransactionUtil;

public class TradeListener extends SOListener implements ISessionDependent {

  private HashMap<Long, ArrayList<Integer>> items = new HashMap<Long, ArrayList<Integer>>();
  private ArrayList<Long> acceptedChars = new ArrayList<Long>();
  private Session session;

  public TradeListener() {
    super();
  }

  @Override
  public void setSession(Session session) {
    this.session = session;
  }

  public boolean rRemoveItem(String owner, StuffItemLightTO item) {
    if (acceptedChars.size() > 0 || !hasItem(item)) return true;
    Long userId = getUserId();
    ArrayList<Integer> charItems = items.get(userId);
    charItems.remove(Integer.valueOf(item.getId().intValue()));
    return false;
  }

  public boolean rAddItem(String owner, StuffItemLightTO item) {

    if (acceptedChars.size() > 0 || hasItem(item)) return true;

    Long userId = getUserId();
    if (items.get(userId) == null) {
      items.put(userId, new ArrayList<Integer>());
    }
    ArrayList<Integer> charItems = items.get(userId);
    charItems.add(item.getId().intValue());
    return false;
  }

  public boolean rAccept(String charId) {
    Long userIdCurr = getUserId();
    if (acceptedChars.contains(userIdCurr))
      throw new IllegalStateException("User " + userIdCurr + " is trying to hack the trade");

    acceptedChars.add(userIdCurr);
    if (acceptedChars.size() == 2) {
      processTrade();
    }
    return false;
  }

  private boolean hasItem(StuffItemLightTO item) {
    for (ArrayList<Integer> list : items.values()) {
      for (int id : list) {
        if (id == item.getId().intValue()) return true;
      }
    }
    return false;
  }

  private void processTrade() {
    TransactionUtil.callTransaction(this, "doProcessTrade", new ArrayList<Object>());
  }

  public void doProcessTrade() {
    UserDAO userDAO = new UserDAO(session);
    for (Long userId : acceptedChars) {
      User user = userDAO.findById(userId);
      for (Long traderUserId : items.keySet()) {
        if (!traderUserId.equals(userId)) {
          User trader = userDAO.findById(traderUserId);
          ArrayList<Integer> traderItems = items.get(traderUserId);
          moveItems(user.getGameChar(), trader.getGameChar(), traderItems);
        }
      }
    }
  }

  private void moveItems(GameChar to, GameChar from, ArrayList<Integer> ids) {
    StuffItemDAO stuffItemDAO = new StuffItemDAO(session);
    for (Integer id : ids) {
      boolean processed = false;
      for (StuffItem item : from.getStuffItems()) {
        if (item.getId().intValue() == id) {
          item.setGameChar(to);
          stuffItemDAO.makePersistent(item);
          processed = true;
        }
      }
      if (!processed)
        throw new IllegalStateException(
            "user " + from.getLogin() + " doesnt have the item with id " + id);
    }
    GameCharDAO dao = new GameCharDAO(session);
    dao.makePersistent(to);
    dao.makePersistent(from);
  }
}
