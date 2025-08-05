package com.kavalok.services;

import java.util.ArrayList;
import java.util.List;

import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.StuffItemDAO;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.db.GameChar;
import com.kavalok.db.StuffItem;
import com.kavalok.db.StuffType;
import com.kavalok.db.User;
import com.kavalok.dto.stuff.StuffItemLightTO;
import com.kavalok.services.common.DataServiceBase;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.utils.ShopAccessUtil;

public class StuffService extends DataServiceBase {

  private static final List<String> SUPERUSER_SHOPS = new ArrayList<String>();

  static {
    SUPERUSER_SHOPS.add("emptyShop");
    SUPERUSER_SHOPS.add("futureShop");
  }

  public List<StuffItemLightTO> buyItem(Integer id, Integer count, Integer color) {

    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    GameChar gameChar = new GameCharDAO(getSession()).findByUserId(adapter.getUserId());
    StuffType type = new StuffTypeDAO(getSession()).findById(Long.valueOf(id), false);

    // Check if user has access to buy from this shop
    ShopAccessUtil.checkShopAccessForBuy(getSession(), type.getShop());

    if (SUPERUSER_SHOPS.contains(type.getShop().getName())) {
      User user = new UserDAO(getSession()).findById(adapter.getUserId());
      if (!Boolean.TRUE.equals(user.getSuperUser())) {
        throw new IllegalStateException("Stop HACKING! Your IP address was logged.");
      }
    }
    ArrayList<StuffItemLightTO> result = new ArrayList<StuffItemLightTO>();

    if (gameChar.getMoney() < count * type.getPrice()) {
      throw new IllegalStateException("Char doesn't have enough money");
    }

    adapter.addMoney(getSession(), -count * type.getPrice(), "stuff bought");

    // User user = new UserDAO(getSession()).findById(adapter.getUserId());
    StuffItemDAO stuffItemDAO = new StuffItemDAO(getSession());

    for (int i = 0; i < count; i++) {
      StuffItem item = new StuffItem(type);
      item.setColor(color);
      item.setGameChar(gameChar);
      stuffItemDAO.makePersistent(item);

      result.add(new StuffItemLightTO(item));
      new GameCharDAO(getSession()).makePersistent(gameChar);
    }

    return result;
  }
}
