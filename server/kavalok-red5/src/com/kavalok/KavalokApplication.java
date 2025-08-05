package com.kavalok;

import java.io.FileReader;
import java.lang.reflect.InvocationTargetException;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Timer;

import org.hibernate.Session;
import org.red5.server.adapter.MultiThreadedApplicationAdapter;
import org.red5.server.api.IConnection;
import org.red5.server.api.IScope;
import org.red5.server.api.so.ISharedObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.cache.ShopCacheCleaner;
import com.kavalok.dao.ConfigDAO;
import com.kavalok.dao.ServerDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.db.Server;
import com.kavalok.db.User;
import com.kavalok.db.UserServer;
import com.kavalok.dto.CharTOCache;
import com.kavalok.messages.UsersCache;
import com.kavalok.messages.WordsCache;
import com.kavalok.statistics.ServerUsageStatistics;
import com.kavalok.transactions.DefaultTransactionStrategy;
import com.kavalok.transactions.ITransactionStrategy;
import com.kavalok.transactions.TransactionUtil;
import com.kavalok.user.BadClientsCleaner;
import com.kavalok.user.OnlineUsersCleaner;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.utils.HibernateUtil;
import com.kavalok.utils.ReflectUtil;
import com.kavalok.utils.SOManager;

import net.sf.cglib.core.ReflectUtils;

import java.lang.reflect.Method;
import com.kavalok.dao.AdminDAO;
import com.kavalok.db.Admin;
import com.kavalok.permissions.AccessAdmin;
import com.kavalok.services.stuff.RainTokenManager;
import java.security.SecureRandom;
import java.math.BigInteger;

public class KavalokApplication extends MultiThreadedApplicationAdapter {

  public static final String CONTEXT_FORMAT = "%1s/%2$s";

  public static Logger logger = LoggerFactory.getLogger(KavalokApplication.class);

  private boolean started = false;

  private boolean safeModeEnabled = false;

  private boolean registrationEnabled = false;

  private int spamMessagesCount = 100;

  private int stuffGroupNum = 100;

  private boolean guestEnabled = false;

  private int serverLimit = 250;

  private Timer serverUsageTimer;

  private Timer serverUsersCleanerTimer;

  private Timer clientsCleanerTimer;

  private Timer shopCacheCleanerTimer;

  private String rainServerSecret;

  public static KavalokApplication getInstance() {
    return instance;
  }

  private static KavalokApplication instance;

  private String serverPath;

  private String serverName;

  private Server server;

  private java.util.Properties properties;

  private ApplicationConfig applicationConfig;

  public KavalokApplication() {
    instance = this;
  }

  public boolean hasSharedObject(String name) {
    return hasSharedObject(scope, name);
  }

  public ISharedObject createSharedObject(String name) {
    if (!hasSharedObject(name)) createSharedObject(scope, name, false);
    return getSharedObject(name);
  }

  public ISharedObject getSharedObject(String name) {
    return getSharedObject(scope, name);
  }

  public String getCurrentServerPath() {
    return serverPath;
  }

  @Override
  public boolean appStart(IScope scope) {
    String path = getClassesPath() + "/kavalok.properties";
    properties = new java.util.Properties();
    try {
      properties.load(new FileReader(path));
    } catch (Exception e) {
      logger.error(e.getMessage(), e);
    }

    String applicationPropsPath = getClassesPath() + "/application.properties";
    try {
      Properties applicationProperties = new Properties();
      applicationProperties.load(new FileReader(applicationPropsPath));
      applicationConfig = new ApplicationConfig(applicationProperties);
    } catch (Exception e) {
      logger.error(e.getMessage(), e);
    }

    addListener(getScope(), new SOManager());
    HibernateUtil.getSessionFactory();
    WordsCache.getInstance(); // load words
    String name = scope.getName();
    serverPath = String.format(CONTEXT_FORMAT, getHostIP(), name);
    logger.info("Started (" + serverPath + ")");

    refreshServerState(true);

    serverUsageTimer = new Timer("ServerUsageStatistics timer", true);
    serverUsageTimer.schedule(new ServerUsageStatistics(), 0, ServerUsageStatistics.DELAY);
    // new ServerUsageStatistics().start();

    serverUsersCleanerTimer = new Timer("OnlineUsersCleaner timer", true);
    serverUsersCleanerTimer.schedule(new OnlineUsersCleaner(), 0, OnlineUsersCleaner.DELAY);

    clientsCleanerTimer = new Timer("BadClientsCleaner timer", true);
    clientsCleanerTimer.schedule(new BadClientsCleaner(), 0, BadClientsCleaner.DELAY);

    shopCacheCleanerTimer = new Timer("ShopCacheCleaner timer", true);
    shopCacheCleanerTimer.schedule(new ShopCacheCleaner(), 0, ShopCacheCleaner.DELAY);

    // Generate a random server secret for rain tokens
    SecureRandom random = new SecureRandom();
    rainServerSecret = new BigInteger(130, random).toString(32);
    RainTokenManager.initialize(rainServerSecret);

    started = true;
    refreshConfig();
    return true;
  }

  public String getClassesPath() {
    String path = ReflectUtil.getRootPath(KavalokApplication.class);
    if (path.contains("lib/kavalok.jar")) // deployed as jar
    {
      path = path.substring(0, path.indexOf("lib/kavalok.jar")) + "classes";
      path = path.substring("file:/".length(), path.length());
    }
    return path;
  }

  @Override
  public void appStop(IScope scope) {
    super.appStop(scope);
    refreshServerState(false);
    serverUsageTimer.cancel();
  }

  private String getHostIP() {
    return properties.getProperty("host.ip");
  }

  public ApplicationConfig getApplicationConfig() {
    return applicationConfig;
  }

  public void refreshConfig() {
    DefaultTransactionStrategy strategy = new DefaultTransactionStrategy();
    try {
      strategy.beforeCall();

      ConfigDAO configDAO = new ConfigDAO(strategy.getSession());
      setGuestEnabled(configDAO.getGuestEnabled());
      setRegistrationEnabled(configDAO.getRegistrationEnabled());
      setSafeModeEnabled(configDAO.getSafeModeEnabled());
      setServerLimit(configDAO.getServerLimit());
      setSpamMessagesCount(configDAO.getSpamMessagesCount());
      setStuffGroupNum(configDAO.getStuffGroupNum());

      strategy.afterCall();
    } catch (Exception e) {
      strategy.afterError(e);
      logger.error(e.getMessage(), e);
    }
  }

  private void refreshServerState(boolean available) {
    DefaultTransactionStrategy strategy = new DefaultTransactionStrategy();
    try {
      strategy.beforeCall();
      ServerDAO serverDAO = new ServerDAO(strategy.getSession());
      Server server = serverDAO.findByUrl(getCurrentServerPath());
      setServerName(server.getName());

      UserServerDAO usDAO = new UserServerDAO(strategy.getSession());
      List<UserServer> list = usDAO.getAllUserServer(server);
      for (Iterator<UserServer> iterator = list.iterator(); iterator.hasNext(); ) {
        UserServer userServer = (UserServer) iterator.next();
        usDAO.makeTransient(userServer);
      }
      server.setRunning(available);

      serverDAO.makePersistent(server);
      setServer(server);
      strategy.afterCall();
    } catch (Exception e) {
      strategy.afterError(e);
      logger.error(e.getMessage(), e);
    }
  }

  public Object call(String className, String method, List<Object> args)
      throws ClassNotFoundException, InstantiationException, IllegalAccessException,
          NoSuchMethodException, InvocationTargetException {
    Class<?> type = Class.forName(className);
    ITransactionStrategy service = (ITransactionStrategy) ReflectUtils.newInstance(type);
    
    Boolean authorized = isAuthorized(className, method);
    if (Boolean.FALSE.equals(authorized)) {
      logger.warn("Unauthorized access attempt to " + className + "." + method);
      return null;
    } else if (authorized == null) {
      logger.warn("Undefined permission level for '" + className + "." + method + "' - access denied");
      return null;
    }
    
    try {
      return TransactionUtil.callTransaction(service, method, args);
    } catch (SecurityException e) {
      logger.error("Security violation in " + className + "." + method + ": " + e.getMessage());
      throw e;
    } catch (Exception e) {
      logger.error("Error in " + className + "." + method + ": " + e.getMessage());
      throw e;
    }
  }

  private Boolean isAuthorized(String className, String methodName) {
    Integer requiredLevel = getRequiredPermissionLevel(className + "." + methodName);

    if (requiredLevel == null) {
      return null;
    }

    return userHasPermissionLevel(requiredLevel);
  }

  private Integer getRequiredPermissionLevel(String method) {
    if (!method.startsWith("com.kavalok.services.")) {
      return null;
    }

    String permission = method.substring("com.kavalok.services.".length());
    
    switch (permission) {
      // SUPER_ADMIN level methods (level 5) - Super Admin users only
      case "StatisticsService.getMembersAge":
      case "StatisticsService.getTotalLogins":
      case "StatisticsService.getActivationChart":
      case "StatisticsService.getLoadChart":
      case "StatisticsService.getPurchaseStatistics":
      case "AdminService.moveUsers":
      case "AdminService.reboot":
      case "AdminService.setServerLimit":
      case "AdminService.saveConfig":
      case "AdminService.setServerAvailable":
      case "AdminService.setMailServerAvailable":
      case "AdminService.refreshServersConfig":
      case "AdminService.getMailServers":
      case "ErrorService.getErrors":

        return 5;
        
      // SUPER_MOD level methods (level 4) - Super moderators and above
      case "AdminService.saveStuffGroupNum":
      case "MessageService.getBlockWords":
      case "MessageService.addBlockWord":
      case "MessageService.removeBlockWord":
      case "MessageService.getSkipWords":
      case "MessageService.addSkipWord":
      case "MessageService.removeSkipWord":
      case "MessageService.getAllowedWords":
      case "MessageService.removeAllowedWord":
      case "MessageService.addAllowedWord":
      case "MessageService.getReviewWords":
      case "MessageService.removeReviewWord":
      case "MessageService.addReviewWord":
      case "AdminService.sendGlobalMessage":
      case "AdminService.addCitizenship":
      case "AdminService.addMoney":
      case "AdminService.deleteUser":
      case "AdminService.restoreUser":
      case "StuffTypeService.saveItem":
      case "CompetitionDataService.getCompetitions":
      case "CompetitionDataService.startCompetition":
      case "CompetitionDataService.clearCompetition":
        return 4;
      
      // MOD level methods (level 3) - Full moderators and above
      case "AdminService.setBanDate":
      case "AdminService.kickOut":
      case "AdminService.saveUserData":
      case "AdminService.saveIPBan":
      case "AdminService.addStuff":
      case "InfoPanelService.getEntities":
      case "QuestService.getQuests":
      case "QuestService.saveQuest":
      case "InfoPanelService.saveEntity":
        return 3;
      
      // HALF_MOD level methods (level 2) - Half moderators and above
      case "AdminService.moderateChat":
      case "AdminService.setReportProcessed":
      case "AdminService.getLastChatMessages":
      case "AdminService.getUser":
      case "AdminService.getUsers":
      case "AdminService.setDisableChatPeriod":
      case "AdminService.saveUserBan":
      case "AdminService.sendRules":
      case "AdminService.saveWorldConfig":
        return 2;
      
      // PARTNER level methods (level 1) - Partners and above
      case "AdminService.viewStatistics":
      case "AdminService.viewPartnerData":
      case "StatisticsService.getTransactionStatistics":
      case "StatisticsService.getRobotTransactionStatistics":
        return 1;
      
      // EXTERNAL_MOD level methods (level 0) - External moderators and above
      case "AdminService.getGraphity":
      case "AdminService.clearGraphity":
      case "AdminService.viewReports":
      case "AdminService.getReports":
      case "ServerService.getAllServers":
      case "StuffTypeService.getShops":
      case "AdminService.clearSharedObject":
      case "AdminService.sendState":
      case "AdminService.removeState":
      case "AdminService.sendLocationCommand":
      case "StuffTypeService.getStuffListByShop":
      case "AdminService.getRainableStuffs":
      case "AdminService.triggerRainEventWithLocation":
        return 0;
      
      // Public methods (no permission required)
      case "AdminService.adminLogin":
      case "AdminService.changePassword":
      case "AdminService.getPermissionLevel":
      case "AdminService.getServerLimit":
      case "AdminService.getConfig":
      case "AdminService.getClientConfig":
      case "AdminService.getWorldConfig":
      case "AdminService.getStuffGroupNum":
      case "LoginService.getServerProperties":
      case "SystemService.clientTick":
      case "CharService.getCharViewLogin":
      case "LoginService.login":
      // Logged in
      case "LoginService.getMostLoadedServer":
      case "ServerService.getServers":
      case "ServerService.getServerAddress":
      case "CharService.enterGame":
      case "SOService.getState":
      case "MessageService.lPC":
      case "SOService.getNumConnectedChars":
      case "CompetitionDataService.getMyCompetitionResult":
      case "CharService.getCharFriends":
      case "CharService.getRobotTeam":
      case "CharService.getCharHome":
      case "MoneyService.addMoney":
      case "BillingTransactionService.getMembershipSKUs":
      case "StuffServiceNT.getItemOfTheMonthType":
      case "CharService.getCharView":
      case "StuffServiceNT.getItem":
      case "MessageService.deleteCommand":
      case "CharService.getFamilyInfo":
      case "GraphityService.getShapes":
      case "GraphityService.sendShape":
      case "CharService.saveSettings":
      case "UserServiceNT.setHelpEnabled":
      case "CharService.saveCharStuffs":
      case "StuffServiceNT.getStuffTypes":
      case "CharService.saveCharBody":
      case "CompetitionService.addResult":
      case "CharService.removeCharFriends":
      case "MessageService.sendCommand":
      case "RobotServiceNT.getTeamTopScores":
      case "StuffServiceNT.retriveItem": // Also has finer permission control
      case "StuffServiceNT.retriveItemByIdWithColor": // Also has finer permission control
      case "CharService.getCharMoney":
      case "CharService.getMoneyReport":
      case "SystemService.getSystemDate":
      case "MagicServiceNT.getMagicPeriod":
      case "MagicServiceNT.executeMagicRain":
      case "StuffServiceNT.removeItem":
      case "com.kavalok.services.StuffService.buyItem":
      case "CharService.makePresent":
        return -1;
      
      default:
        return null;
    }
  }

  private boolean userHasPermissionLevel(int requiredLevel) {
    // If no permission is required, allow access
    if (requiredLevel == -1) {
      return true;
    }
    
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (userAdapter == null) {
      logger.warn("Unauthorized access attempt by unknown user");
      return false;
    }

    if (AccessAdmin.class.equals(userAdapter.getAccessType())) {
      Session session = null;
      try {
        session = HibernateUtil.getSessionFactory().openSession();
        AdminDAO adminDAO = new AdminDAO(session);
        Admin admin = adminDAO.findById(userAdapter.getUserId());
        
        if (admin != null) {
          int adminPermissionLevel = admin.getPermissionLevel() != null ? admin.getPermissionLevel() : 0;
          return adminPermissionLevel >= requiredLevel;
        }
      } catch (Exception e) {
        logger.error("Error checking admin privileges", e);
      } finally {
        if (session != null && session.isOpen()) {
          session.close();
        }
      }
    }

    Session session = null;
    try {
      session = HibernateUtil.getSessionFactory().openSession();
      UserDAO userDAO = new UserDAO(session);
      User user = userDAO.findById(userAdapter.getUserId());
      
      if (user != null) {
        boolean isSuperUser = Boolean.TRUE.equals(user.getSuperUser());
        boolean isModerator = user.isModerator();

        int userPermissionLevel = 0;
        if (isSuperUser) {
          userPermissionLevel = 5; // SUPER_ADMIN level
        } else if (isModerator) {
          userPermissionLevel = 3; // MOD level
        }

        return userPermissionLevel >= requiredLevel;
      }
    } catch (Exception e) {
      logger.error("Error checking user privileges", e);
    } finally {
      if (session != null && session.isOpen()) {
        session.close();
      }
    }

    return false;
  }

  @Override
  public void appDisconnect(IConnection conn) {
    DefaultTransactionStrategy strategy = new DefaultTransactionStrategy();
    try {
      strategy.beforeCall();
      disconnectUser(strategy.getSession());
      strategy.afterCall();
    } catch (Exception e) {
      strategy.afterError(e);
      e.printStackTrace();
      logger.error(e.getMessage(), e);
    } finally {
      super.appDisconnect(conn);
    }
  }

  public boolean appConnect(IConnection conn, Object[] params) {
    if (!started) return false;
    return true;
  }

  public void disconnectUser(Session session) {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (userAdapter.getUserId() != null) {
      logger.info("User {} disconnect", userAdapter.getLogin());
      UserDAO userDAO = new UserDAO(session);
      User user = userDAO.findById(userAdapter.getUserId());
      if (user == null) {
        userAdapter.dispose();
        return;
      }
      boolean updateUser = userAdapter.updateStatistics(session, user);
      userAdapter.dispose();
      UserServerDAO usDAO = new UserServerDAO(session);
      List<UserServer> list = usDAO.getAllUserServer(userAdapter.getUserId());
      for (Iterator<UserServer> iterator = list.iterator(); iterator.hasNext(); ) {
        UserServer userServer = (UserServer) iterator.next();
        usDAO.makeTransient(userServer);
      }
      if (updateUser) userDAO.makePersistent(user);

      CharTOCache.getInstance().removeCharTO(user.getId());
      CharTOCache.getInstance().removeCharTO(user.getLogin());
      UsersCache.getInstance().removeUser(user.getId());
      userAdapter.dispose();
    }
  }

  public boolean isSafeModeEnabled() {
    return safeModeEnabled;
  }

  public void setSafeModeEnabled(boolean safeModeEnabled) {
    this.safeModeEnabled = safeModeEnabled;
  }

  public String getServerName() {
    return serverName;
  }

  public void setServerName(String serverName) {
    this.serverName = serverName;
  }

  public Server getServer() {
    return server;
  }

  public void setServer(Server server) {
    this.server = server;
  }

  public boolean isRegistrationEnabled() {
    return registrationEnabled;
  }

  public void setRegistrationEnabled(boolean registrationEnabled) {
    this.registrationEnabled = registrationEnabled;
  }

  public int getStuffGroupNum() {
    return stuffGroupNum;
  }

  public void setStuffGroupNum(int stuffGroupNum) {
    this.stuffGroupNum = stuffGroupNum;
  }

  public boolean isGuestEnabled() {
    return guestEnabled;
  }

  public void setGuestEnabled(boolean guestEnabled) {
    this.guestEnabled = guestEnabled;
  }

  public int getServerLimit() {
    return serverLimit;
  }

  public void setServerLimit(int serverLimit) {
    this.serverLimit = serverLimit;
  }

  public int getSpamMessagesCount() {
    return spamMessagesCount;
  }

  public void setSpamMessagesCount(int spamMessagesCount) {
    this.spamMessagesCount = spamMessagesCount;
  }
}
