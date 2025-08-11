package com.kavalok.user;

import java.util.Set;
import java.util.TimerTask;

import org.red5.server.api.IClient;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.KavalokApplication;

public class BadClientsCleaner extends TimerTask {

  public static final int DELAY = 10 * 60 * 1000;

  public static Logger logger = Red5LoggerFactory.getLogger(BadClientsCleaner.class);

  @Override
  public void run() {
    try {
      logger.debug("BadClientsCleaner start");
      Set<IClient> clients = KavalokApplication.getInstance().getClients();
      for (IClient client : clients) {

        UserAdapter user = (UserAdapter) client.getAttribute(UserManager.ADAPTER);
        if (user == null) {
          logger.debug("User attribute was null, cleaning client: " + client);
          try {
            // client.disconnect();
          } catch (Exception e) {
            // TODO: handle exception
          }
        } else if (user.getLogin() == null && user.getUserId() == null) {
          logger.debug("User attribute is empty, cleaning client: " + client);
          try {
            client.disconnect();
          } catch (Exception e) {
            // TODO: handle exception
          }
        }
      }

      logger.debug("BadClientsCleaner finish");
    } catch (Exception e) {
      e.printStackTrace();
      logger.debug(e.getMessage(), e);
    }
  }
}
