package com.kavalok.services;

import java.util.Date;
import java.util.List;

import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.StuffItemDAO;
import com.kavalok.db.GameChar;
import com.kavalok.db.StuffItem;
import com.kavalok.db.StuffType;
import com.kavalok.services.common.DataServiceNotTransactionBase;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.services.RainCommandService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MagicServiceNT extends DataServiceNotTransactionBase {

  private static final Logger logger = LoggerFactory.getLogger(MagicServiceNT.class);

  public Integer getMagicPeriod() {
    Long userId = getAdapter().getUserId();
    GameChar gameChar = new GameCharDAO(getSession()).findByUserId(userId);
    return getPeriod(gameChar.getMagicDate());
  }

  public void updateMagicDate() {
    Long userId = getAdapter().getUserId();
    GameCharDAO charDAO = new GameCharDAO(getSession());
    GameChar gameChar = charDAO.findByUserId(userId);
    gameChar.setMagicDate(new Date());
    charDAO.makePersistent(gameChar);
  }

  /**
   * Handles magic rain when user clicks the magic button.
   * Verifies the user has the appropriate magic item equipped and executes the rain command.
   */
  public void executeMagicRain() {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    GameChar gameChar = userAdapter.getChar(getSession());
    
    // Find the magic item the user is wearing
    StuffItemDAO stuffItemDAO = new StuffItemDAO(getSession());
    List<StuffItem> equippedItems = stuffItemDAO.findByGameCharAndUsed(gameChar, true);
    
    for (StuffItem item : equippedItems) {
      StuffType itemType = item.getType();
      String info = itemType.getInfo();
      
      if (info != null && info.contains("command=MagicStuffItemRain")) {
        // Parse the rain command from the item's info field
        String[] parts = info.split(";");
        String fName = null;
        Integer count = null;
        
        for (String part : parts) {
          if (part.startsWith("fName=")) {
            fName = part.substring(6);
          } else if (part.startsWith("count=")) {
            count = Integer.parseInt(part.substring(6));
          }
        }
        
        if (fName != null && count != null) {
          RainCommandService.triggerRainEvent(getSession(), fName, count, "magic");
          
          // Update magic date to prevent spam
          updateMagicDate();
          return;
        }
      }
    }
  }

  private Integer getPeriod(Date date) {
    Long result;
    if (date != null) {
      result = (new Date().getTime() - date.getTime()) / 1000;
    } else {
      result = -1L;
    }
    return result.intValue();
  }
}
