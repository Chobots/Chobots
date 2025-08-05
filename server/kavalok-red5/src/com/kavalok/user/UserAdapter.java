package com.kavalok.user;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Stack;
import java.util.concurrent.Executors;

import org.hibernate.Session;
import org.red5.server.api.IBasicScope;
import org.red5.server.api.IClient;
import org.red5.server.api.Red5;
import org.red5.server.api.service.IServiceCapableConnection;
import org.red5.server.api.so.ISharedObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.UserExtraInfoDAO;
import com.kavalok.dao.statistics.LoginStatisticsDAO;
import com.kavalok.db.GameChar;
import com.kavalok.db.Server;
import com.kavalok.db.StuffItem;
import com.kavalok.db.StuffType;
import com.kavalok.db.User;
import com.kavalok.db.UserExtraInfo;
import com.kavalok.db.statistics.LoginStatistics;
import com.kavalok.db.statistics.MoneyStatistics;
import com.kavalok.dto.stuff.StuffItemLightTO;
import com.kavalok.services.ClothingValidationService;
import com.kavalok.services.common.SimpleEncryptor;

public class UserAdapter {

  private static final Logger logger = LoggerFactory.getLogger(UserAdapter.class);
  private static final int MESSAGES_TO_LOG_COUNT = 100;

  private static final int MONEY_STATS_CACHE_MAX_SIZE = 20;

  private static String LOCATION_CHAT_MESSAGE_HANDLER = "lc";

  private static String DISABLE_CHAT_HANDLER = "onDisableChat";

  private static String LOAD_STUFF_HANDLER = "loadStuff";

  private static String LOAD_STUFF_END_HANDLER = "loadStuffEnd";

  private static String LOCATION_MOVE_HANDLER = "lm";

  private static String DISABLE_CHAT_ADMIN_HANDLER = "onDisableChatAdmin";

  private static String SKIP_CHAT_HANDLER = "onSkipChat";

  private static String COMMAND_HANDLER = "onCommand";

  private static String COMMAND_INSTANCE_HANDLER = "onCommandInstance";

  private IClient client;

  private IServiceCapableConnection connection;

  private Long userId;

  private String login;

  private String creationStackTrace;

  private Server server;

  private Boolean persistent = true;

  private Date loginDate;

  private Date lastTick;

  private Byte[] securityKey;

  private Stack<String> messagesStack = new Stack<String>();

  private List<MoneyStatistics> MONEY_STATS_CACHE = new ArrayList<MoneyStatistics>();

  @SuppressWarnings("unchecked")
  private Class accessType;

  public UserAdapter() {
    super();
    messagesStack.setSize(MESSAGES_TO_LOG_COUNT);
    client = new Red5().getClient();
    connection = (IServiceCapableConnection) Red5.getConnectionLocal();
    creationStackTrace = "";
    StackTraceElement[] trace = Thread.currentThread().getStackTrace();
    for (int i = 0; i < trace.length; i++) {
      String el = trace[i].toString();
      this.creationStackTrace = this.creationStackTrace + el + "\n<br>";
    }
  }

  public IServiceCapableConnection getConnection() {
    return connection;
  }

  public Byte[] getSecurityKey() {
    return securityKey;
  }

  public Byte[] newSecurityKey() {
    securityKey = SimpleEncryptor.generateKey();
    return securityKey;
  }

  public GameChar getChar(Session session) {
    GameChar gameChar = new GameCharDAO(session).findByUserId(userId);
    return gameChar;
  }

  public List<String> getSharedObjects() {
    ArrayList<String> result = new ArrayList<String>();
    Iterator<IBasicScope> iterator = getConnection().getBasicScopes();
    while (iterator.hasNext()) {
      IBasicScope scope = iterator.next();
      if (scope instanceof ISharedObject) {
        result.add(((ISharedObject) scope).getName());
      }
    }
    return result;
  }

  public void enterGame() {
    loginDate = new Date();
  }

  public IClient getClient() {
    return client;
  }

  public void setClient(IClient client) {
    this.client = client;
  }

  public List<StuffType> getStuff(Session session) {
    List<StuffType> result = new ArrayList<StuffType>();
    GameChar gameChar = new GameCharDAO(session).findByUserId(userId);
    for (StuffItem item : gameChar.getStuffItems()) {
      result.add(item.getType());
    }
    return result;
  }

  public Double getMoney(Session session) {
    GameChar gameChar = new GameCharDAO(session).findByUserId(userId);
    return gameChar.getMoney();
  }

  public List<String> getClothes(Session session) {
    GameCharDAO charDAO = new GameCharDAO(session);
    GameChar gameChar = charDAO.findByUserId(userId);

    if (gameChar == null) {
      logger.warn("Game character not found for user: {}", userId);
      return new ArrayList<>();
    }

    List<String> clothes = charDAO.getUsedClothes(gameChar);

    // Validate that all clothing items exist and belong to the user
    ClothingValidationService validationService =
        ClothingValidationService.createValidationService();

    // Convert clothing file names to item IDs for validation
    List<Long> itemIds = new ArrayList<>();
    List<StuffItem> userItems = gameChar.getStuffItems();

    for (String clothingFileName : clothes) {
      // Find the StuffItem by file name and get its ID
      for (StuffItem item : userItems) {
        if (item.isUsed() && clothingFileName.equals(item.getType().getFileName())) {
          itemIds.add(item.getId());
          break;
        }
      }
    }

    // Validate item existence and ownership
    Map<Long, StuffItem> validItems = validationService.validateItemExistence(itemIds, session);

    // Return only validated clothing file names
    List<String> validatedClothes = new ArrayList<>();
    for (String clothingFileName : clothes) {
      for (StuffItem item : userItems) {
        if (item.isUsed()
            && clothingFileName.equals(item.getType().getFileName())
            && validItems.containsKey(item.getId())) {
          validatedClothes.add(clothingFileName);
          break;
        }
      }
    }

    if (validatedClothes.size() != clothes.size()) {
      logger.warn(
          "User {} had {} invalid clothing items removed from broadcast",
          userId,
          clothes.size() - validatedClothes.size());
    }

    return validatedClothes;
  }

  /*
   * public void updateAll(Session session) { sharedObject.beginUpdate();
   * sharedObject.setAttribute(ATTRIBUTE_STUFF, getStuff(session));
   * sharedObject.setAttribute(ATTRIBUTE_MONEY, getMoney(session));
   * sharedObject.setAttribute(ATTRIBUTE_CLOTHES, getClothes(session));
   * sharedObject.endUpdate(); }
   */

  public void addMoney(Session session, long money, String reason) {
    addMoney(session, new User(userId), money, reason);
  }

  public void addMoney(Session session, User user, long money, String reason) {
    GameCharDAO gameCharDAO = new GameCharDAO(session);
    GameChar gameChar = gameCharDAO.findByUserId(user.getId());
    gameChar.setMoney(money + gameChar.getMoney());
    if (money > 0) {
      gameChar.setTotalMoneyEarned(gameChar.getTotalMoneyEarned() + money);
      insertMoneyStatistics(session, money, reason, user);
    }
    gameCharDAO.makePersistent(gameChar);
    executeCommand("UpdateMoneyCommand", gameChar.getMoney());
  }

  private void insertMoneyStatistics(Session session, long money, String reason, User user) {
    if (MONEY_STATS_CACHE.size() > MONEY_STATS_CACHE_MAX_SIZE) {
      updateMoneyStatistics(session);
    }
    MoneyStatistics moneyStatistics = new MoneyStatistics(user, money, new Date(), reason);
    MONEY_STATS_CACHE.add(moneyStatistics);
  }

  public void disableChatAdmin(String reason, Boolean enabledByMod, Boolean enabledByParent) {
    connection.invoke(
        DISABLE_CHAT_ADMIN_HANDLER, new Object[] {reason, enabledByMod, enabledByParent});
  }

  public void disableChat(String reason, Long interval, Integer minutes) {
    connection.invoke(DISABLE_CHAT_HANDLER, new Object[] {reason, interval, minutes});
  }

  public void sendLocationChat(Integer senderId, String senderLogin, Object message) {
    connection.invoke(
        LOCATION_CHAT_MESSAGE_HANDLER, new Object[] {senderLogin, senderLogin, message});
  }

  public void sendLocationMove(
      Integer senderId, String senderLogin, Integer x, Integer y, Boolean petBusy) {
    connection.invoke(
        LOCATION_MOVE_HANDLER,
        new Object[] {senderLogin, senderLogin, x, y, petBusy, System.currentTimeMillis()});
  }

  public void skipChat(String reason, String message) {
    connection.invoke(SKIP_CHAT_HANDLER, new Object[] {reason, message});
  }

  public void executeCommand(String className, Object parameter) {
    connection.invoke(COMMAND_HANDLER, new Object[] {className, parameter});
  }

  public void executeCommand(Object command) {
    connection.invoke(COMMAND_INSTANCE_HANDLER, new Object[] {command});
  }

  public boolean updateStatistics(Session session, User user) {
    boolean result = false; // if user needs to be updated
    if (getPersistent() && getUserId() != null && loginDate != null) {
      LoginStatistics loginStatistics = new LoginStatistics(user, loginDate, new Date());
      UserExtraInfo uei = user.getUserExtraInfo();
      if (uei == null) {
        uei = new UserExtraInfo();
        result = true; // there was no UserExtraInfo, so wee need to update
      }
      uei.setLastLoginDate(loginDate);
      uei.setLastLogoutDate(loginStatistics.getLogoutDate());
      new UserExtraInfoDAO(session).makePersistent(uei);
      user.setUserExtraInfo(uei);
      new LoginStatisticsDAO(session).makePersistent(loginStatistics);
    }
    updateMoneyStatistics(session);
    return result;
  }

  private static SimpleDateFormat SQL_DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

  private void updateMoneyStatistics(Session session) {
    if (MONEY_STATS_CACHE.isEmpty()) return;
    StringBuffer query =
        new StringBuffer("insert into MoneyStatistics (date, reason, user_id, money) values ");

    for (Iterator<MoneyStatistics> iterator = MONEY_STATS_CACHE.iterator(); iterator.hasNext(); ) {
      MoneyStatistics moneyStat = (MoneyStatistics) iterator.next();
      query.append("(");
      query.append("'").append(SQL_DATE_FORMAT.format(moneyStat.getDate())).append("',");
      query.append("'").append(moneyStat.getReason()).append("',");
      query.append(moneyStat.getUser().getId()).append(",");
      query.append(moneyStat.getMoney());
      query.append(")");
      if (iterator.hasNext()) query.append(",");
    }
    MONEY_STATS_CACHE.clear();
    session.createSQLQuery(query.toString()).executeUpdate();
  }

  public void kickOut(String reason, boolean banned) {
    executeCommand("KickOutCommand", banned);
    dispose();
  }

  public void dispose() {
    // Clear loginToken in database when user disconnects
    if (userId != null) {
      org.hibernate.Session session = null;
      try {
        session = com.kavalok.utils.HibernateUtil.getSessionFactory().openSession();
        com.kavalok.dao.UserDAO userDAO = new com.kavalok.dao.UserDAO(session);
        com.kavalok.db.User user = userDAO.findById(userId);
        if (user != null) {
          user.setLoginToken(null);
          userDAO.makePersistent(user);
        }
      } catch (Exception e) {
        logger.error("Error clearing loginToken for user " + userId, e);
      } finally {
        if (session != null && session.isOpen()) {
          session.close();
        }
      }
    }

    client.disconnect();
    client.removeAttribute(UserManager.ADAPTER);
  }

  @SuppressWarnings("unchecked")
  public Class getAccessType() {
    return accessType;
  }

  @SuppressWarnings("unchecked")
  public void setAccessType(Class accessType) {
    this.accessType = accessType;
  }

  public Long getUserId() {
    return userId;
  }

  public void setUserId(Long userId) {
    this.userId = userId;
  }

  public String getLogin() {
    return login;
  }

  public void setLogin(String login) {
    this.login = login;
  }

  public boolean saveChatMessage(String chatMessage) {
    int count = 0;
    for (Iterator<String> iterator = messagesStack.iterator(); iterator.hasNext(); ) {
      String mess = iterator.next();
      if (mess != null && mess.trim().equals(chatMessage.trim()) && mess.trim().length() > 10) {
        count++;
      }
    }
    if (count >= KavalokApplication.getInstance().getSpamMessagesCount()) {
      return false;
    }
    messagesStack.push(chatMessage);
    return true;
  }

  private List<String> SHORT_MESSAGES = new ArrayList<String>();

  public List<String> addToShortList(String message) {
    List<String> result = null;
    String messageTrimmed = message.trim();
    if (messageTrimmed.length() > 0 && messageTrimmed.length() <= 2) {
      SHORT_MESSAGES.add(messageTrimmed);
    } else {
      if (SHORT_MESSAGES.size() > 1) {
        StringBuffer res = new StringBuffer();
        for (Iterator<String> iterator = SHORT_MESSAGES.iterator(); iterator.hasNext(); ) {
          String mess = iterator.next();
          if (mess != null) {
            res.append(mess).append("\n");
          }
        }
        result = new ArrayList<String>(SHORT_MESSAGES);
      }
      SHORT_MESSAGES.clear();
    }
    return result;
  }

  public String getLastChatMessages() {
    StringBuffer result = new StringBuffer();
    for (Iterator<String> iterator = messagesStack.iterator(); iterator.hasNext(); ) {
      String mess = iterator.next();
      if (mess != null) {
        result.append(mess).append("\n");
      }
    }
    return result.toString();
  }

  public Boolean getPersistent() {
    return persistent;
  }

  public void setPersistent(Boolean persistent) {
    this.persistent = persistent;
  }

  public Server getServer() {
    return server;
  }

  public void setServer(Server server) {
    this.server = server;
  }

  public Date getLastTick() {
    return lastTick;
  }

  public void setLastTick(Date lastTick) {
    this.lastTick = lastTick;
  }

  public void loadCharStuffs(final List<StuffItemLightTO> stuffs) {
    Runnable worker =
        new Runnable() {
          public void run() {
            try {
              Thread.sleep(10000); // let user process previous stuff
            } catch (InterruptedException e1) {
              // TODO Auto-generated catch block
              e1.printStackTrace();
            }
            int totalCount = stuffs.size();
            List<String> portion = new ArrayList<String>();
            for (Iterator<StuffItemLightTO> iterator = stuffs.iterator(); iterator.hasNext(); ) {
              StuffItemLightTO stuffItemLightTO = iterator.next();
              if (!Boolean.TRUE.equals(stuffItemLightTO.getUsed()))
                portion.add(stuffItemLightTO.toStringPresentation());

              if (portion.size() == 75 || !iterator.hasNext()) {
                connection.invoke(LOAD_STUFF_HANDLER, new Object[] {portion});
                portion.clear();
                try {
                  Thread.sleep(1000); // let user process previous bunch of messages
                } catch (InterruptedException e) {
                  // TODO Auto-generated catch block
                  e.printStackTrace();
                }
              }
            }
            connection.invoke(LOAD_STUFF_END_HANDLER, new Object[] {totalCount}); // something
            // like
            // checksum
          }
        };
    Executors.newCachedThreadPool().execute(worker);
  }

  public String getCreationStackTrace() {
    return creationStackTrace;
  }

  public void setCreationStackTrace(String creationStackTrace) {
    this.creationStackTrace = creationStackTrace;
  }
}
