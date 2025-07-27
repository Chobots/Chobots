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
    
    if (!isAuthorized(className, method)) {
      logger.warn("Unauthorized access attempt to " + className + "." + method);
      return null;
    }
    
    return TransactionUtil.callTransaction(service, method, args);
  }

  private boolean isAuthorized(String className, String methodName) {
    Integer requiredLevel = getRequiredPermissionLevel(className + "." + methodName);

    if (requiredLevel == null) {
      logger.warn("Undefined permission level for '" + className + "." + methodName + "' - access denied");
      return false;
    }

    return userHasPermissionLevel(requiredLevel);
  }

  private Integer getRequiredPermissionLevel(String method) {
    switch (method) {    
      // SUPER_ADMIN level methods (level 5) - Super Admin users only
      case "test":
        return 5;
        
      // SUPER_MOD level methods (level 4) - Super moderators and above
      case "com.kavalok.services.AdminService.reboot":
      case "com.kavalok.services.AdminService.setServerLimit":
      case "com.kavalok.services.AdminService.saveConfig":
      case "com.kavalok.services.AdminService.setServerAvailable":
      case "com.kavalok.services.AdminService.setMailServerAvailable":
      case "com.kavalok.services.AdminService.saveWorldConfig":
      case "com.kavalok.services.AdminService.refreshServersConfig":
      case "com.kavalok.services.AdminService.saveStuffGroupNum":
        return 4;
      
      // MOD level methods (level 3) - Full moderators and above
      case "com.kavalok.services.AdminService.setBanDate":
      case "com.kavalok.services.AdminService.setDisableChatPeriod":
      case "com.kavalok.services.AdminService.kickOut":
      case "com.kavalok.services.AdminService.saveUserData":
      case "com.kavalok.services.AdminService.saveUserBan":
      case "com.kavalok.services.AdminService.saveIPBan":
      case "com.kavalok.services.AdminService.addMoney":
      case "com.kavalok.services.AdminService.sendRules":
      case "com.kavalok.services.AdminService.addCitizenship":
      case "com.kavalok.services.AdminService.addStuff":
      case "com.kavalok.services.AdminService.deleteUser":
      case "com.kavalok.services.AdminService.restoreUser":
        return 3;
      
      // HALF_MOD level methods (level 2) - Half moderators and above
      case "com.kavalok.services.AdminService.moderateChat":
      case "com.kavalok.services.AdminService.setReportProcessed":
      case "com.kavalok.services.AdminService.getLastChatMessages":
      case "com.kavalok.services.AdminService.getUser":
      case "com.kavalok.services.AdminService.getUsers":
        return 2;
      
      // PARTNER level methods (level 1) - Partners and above
      case "com.kavalok.services.AdminService.viewStatistics":
      case "com.kavalok.services.AdminService.viewPartnerData":
        return 1;
      
      // EXTERNAL_MOD level methods (level 0) - External moderators and above
      case "com.kavalok.services.AdminService.getGraphity":
      case "com.kavalok.services.AdminService.clearGraphity":
      case "com.kavalok.services.AdminService.viewReports":
      case "com.kavalok.services.AdminService.getReports":
      case "com.kavalok.services.ServerService.getAllServers":
      case "com.kavalok.services.StuffTypeService.getShops":
      case "com.kavalok.services.AdminService.clearSharedObject":
      case "com.kavalok.services.AdminService.sendState":
      case "com.kavalok.services.AdminService.removeState":
      case "com.kavalok.services.AdminService.sendLocationCommand":
      case "com.kavalok.services.StuffTypeService.getStuffListByShop":
      case "com.kavalok.services.AdminService.getRainableStuffs":
        return 0;
      
      // Public methods (no permission required)
      case "com.kavalok.services.AdminService.adminLogin":
      case "com.kavalok.services.AdminService.changePassword":
      case "com.kavalok.services.AdminService.getPermissionLevel":
      case "com.kavalok.services.AdminService.getMailServers":
      case "com.kavalok.services.AdminService.getServerLimit":
      case "com.kavalok.services.AdminService.getConfig":
      case "com.kavalok.services.AdminService.getClientConfig":
      case "com.kavalok.services.AdminService.getWorldConfig":
      case "com.kavalok.services.AdminService.getStuffGroupNum":
      case "com.kavalok.services.LoginService.getServerProperties":
      case "com.kavalok.services.SystemService.clientTick":
      case "com.kavalok.services.CharService.getCharViewLogin":
      case "com.kavalok.services.LoginService.login":
      // Logged in
      case "com.kavalok.services.LoginService.getMostLoadedServer":
      case "com.kavalok.services.ServerService.getServers":
      case "com.kavalok.services.ServerService.getServerAddress":
      case "com.kavalok.services.CharService.enterGame":
      case "com.kavalok.services.SOService.getState":
      case "com.kavalok.services.MessageService.lPC":
      case "com.kavalok.services.SOService.getNumConnectedChars":
      case "com.kavalok.services.CompetitionDataService.getMyCompetitionResult":
      case "com.kavalok.services.CharService.getCharFriends":
      case "com.kavalok.services.CharService.getRobotTeam":
      case "com.kavalok.services.CharService.getCharHome":
      case "com.kavalok.services.MoneyService.addMoney":
      case "com.kavalok.services.BillingTransactionService.getMembershipSKUs":
      case "com.kavalok.services.StuffServiceNT.getItemOfTheMonthType":
      case "com.kavalok.services.CharService.getCharView":
      case "com.kavalok.services.StuffServiceNT.getItem":
      case "com.kavalok.services.MessageService.deleteCommand":
      case "com.kavalok.services.CharService.getFamilyInfo":
      case "com.kavalok.services.GraphityService.getShapes":
      case "com.kavalok.services.GraphityService.sendShape":
      case "com.kavalok.services.CharService.saveSettings":
      case "com.kavalok.services.UserServiceNT.setHelpEnabled":
      case "com.kavalok.services.CharService.saveCharStuffs":
      case "com.kavalok.services.StuffServiceNT.getStuffTypes":
      case "com.kavalok.services.CharService.saveCharBody":
      case "com.kavalok.services.CompetitionService.addResult":
      case "com.kavalok.services.CharService.removeCharFriends":
      case "com.kavalok.services.MessageService.sendCommand":
      case "com.kavalok.services.RobotServiceNT.getTeamTopScores":
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
