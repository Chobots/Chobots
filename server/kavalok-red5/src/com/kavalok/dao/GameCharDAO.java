package com.kavalok.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.Session;

import com.kavalok.dao.common.DAO;
import com.kavalok.db.GameChar;
import com.kavalok.db.StuffItem;
import com.kavalok.dto.CharTOCache;

public class GameCharDAO extends DAO<GameChar> {

  public GameCharDAO(Session session) {
    super(session);
  }

  public List<String> getUsedClothes(GameChar gameChar) {

    ArrayList<String> result = new ArrayList<String>();

    for (StuffItem item : gameChar.getStuffItems()) {
      if (item.isUsed()) {
        try {
          result.add(item.getType().getFileName());
        } catch (org.hibernate.ObjectNotFoundException e) {
          // Race condition: StuffType was deleted from database after StuffItem was loaded
          // Log this at debug level since it's expected in some cases
          continue;
        }
      }
    }

    return result;
  }

  @Override
  public GameChar makePersistent(GameChar entity) {
    CharTOCache.getInstance().removeCharTO(entity.getId());
    CharTOCache.getInstance().removeCharTO(entity.getLogin());
    return super.makePersistent(entity);
  }

  // update GameChar g, User u set g.userId=u.id where gameChar_id = g.id;

  public GameChar findByUserId(Long userId) {
    return findByParameter("userId", userId);
  }
}
