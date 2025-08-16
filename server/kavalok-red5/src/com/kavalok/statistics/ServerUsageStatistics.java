package com.kavalok.statistics;

import java.util.TimerTask;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.ServerDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.dao.statistics.ServerStatisticsDAO;
import com.kavalok.db.Server;
import com.kavalok.db.statistics.ServerStatistics;
import com.kavalok.transactions.DefaultTransactionStrategy;

public class ServerUsageStatistics extends TimerTask {

  public static final int DELAY = 15 * 60 * 1000;

  public ServerUsageStatistics() {
    super();
  }

  public void start() {
    // timer = new Timer("ServerUsageStatistics timer");
    // timer.schedule(this, 0, DELAY);
  }

  @Override
  public void run() {
    DefaultTransactionStrategy strategy = new DefaultTransactionStrategy();
    try {
      strategy.beforeCall();
      Server server = KavalokApplication.getInstance().getServer();
      UserDAO userDAO = new UserDAO(strategy.getSession());
      ServerStatistics serverStatistics =
          new ServerStatistics(server, userDAO.countByServer(server));
      new ServerStatisticsDAO(strategy.getSession()).makePersistent(serverStatistics);
      strategy.afterCall();
    } catch (Exception e) {
      strategy.afterError(e);
    }
  }
}
