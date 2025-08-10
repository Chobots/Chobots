package com.kavalok.user;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.TimerTask;

import org.red5.server.api.IClient;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.ServerDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.db.Server;
import com.kavalok.db.UserServer;
import com.kavalok.dto.CharTOCache;
import com.kavalok.messages.UsersCache;
import com.kavalok.transactions.DefaultTransactionStrategy;
import com.kavalok.utils.DateUtil;

public class OnlineUsersCleaner extends TimerTask {

  public static final int DELAY = 30 * 60 * 1000;

  public static Logger logger = Red5LoggerFactory.getLogger(OnlineUsersCleaner.class);

  @Override
  public void run() {
    DefaultTransactionStrategy strategy = new DefaultTransactionStrategy();
    try {
      strategy.beforeCall();
      logger.debug("Online users processor start");
      String path = KavalokApplication.getInstance().getCurrentServerPath();
      Server server = new ServerDAO(strategy.getSession()).findByScopeName(path);
      UserDAO userDAO = new UserDAO(strategy.getSession());
      List<Long> dbIds = new ArrayList<Long>();
      List<UserServer> userServers =
          new UserServerDAO(strategy.getSession()).getAllUserServer(server);
      for (Iterator<UserServer> iterator = userServers.iterator(); iterator.hasNext(); ) {
        UserServer user = iterator.next();
        dbIds.add(user.getUserId());
      }
      Set<IClient> clients = KavalokApplication.getInstance().getClients();
      Date now = new Date();
      for (IClient client : clients) {
        UserAdapter user = (UserAdapter) client.getAttribute(UserManager.ADAPTER);
        if (user != null) {
          if (user.getLastTick() != null && DateUtil.minutesDiff(now, user.getLastTick()) > 30) {
            logger.debug(
                "Kicked by timeout. User: "
                    + user.getLogin()
                    + ", now: "
                    + now
                    + ", last tick: "
                    + user.getLastTick());

            user.kickOut("Timeout", false);
            CharTOCache.getInstance().removeCharTO(user.getUserId());
            CharTOCache.getInstance().removeCharTO(user.getLogin());
          } else {
            dbIds.remove(user.getUserId());
          }
        }
      }
      if (!dbIds.isEmpty()) {
        userDAO.clearServerId(dbIds);
        for (Iterator<Long> iterator = dbIds.iterator(); iterator.hasNext(); ) {
          UsersCache.getInstance().removeUser(iterator.next());
        }
      }

      logger.debug("Online users processor finish");

      strategy.afterCall();
    } catch (Exception e) {
      strategy.afterError(e);
      e.printStackTrace();
      logger.error(e.getMessage(), e);
    }
  }
}
