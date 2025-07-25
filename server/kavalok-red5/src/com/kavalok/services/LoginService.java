package com.kavalok.services;

import java.io.FileNotFoundException;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import org.hibernate.HibernateException;
import org.red5.io.utils.ObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.AdminDAO;
import com.kavalok.dao.BlackIPDAO;
import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.GuestMarketingInfoDAO;
import com.kavalok.dao.LoginDAOBase;
import com.kavalok.dao.LoginFromPartnerDAO;
import com.kavalok.dao.MarketingInfoDAO;
import com.kavalok.dao.MessageDAO;
import com.kavalok.dao.PartnerDAO;
import com.kavalok.dao.StuffItemDAO;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.dao.UserExtraInfoDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.db.BlackIP;
import com.kavalok.db.GameChar;
import com.kavalok.db.GuestMarketingInfo;
import com.kavalok.db.LoginFromPartner;
import com.kavalok.db.LoginModelBase;
import com.kavalok.db.MarketingInfo;
import com.kavalok.db.Message;
import com.kavalok.db.Server;
import com.kavalok.db.StuffItem;
import com.kavalok.db.StuffType;
import com.kavalok.db.User;
import com.kavalok.db.UserExtraInfo;
import com.kavalok.db.UserServer;
import com.kavalok.dto.ServerPropertiesTO;
import com.kavalok.dto.login.ActivationTO;
import com.kavalok.dto.login.LoginResultTO;
import com.kavalok.dto.login.MarketingInfoTO;
import com.kavalok.dto.login.PartnerLoginCredentialsTO;
import com.kavalok.messages.MessageCheck;
import com.kavalok.messages.MessageSafety;
import com.kavalok.permissions.AccessUser;
import com.kavalok.services.common.DataServiceBase;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.user.UserUtil;
import com.kavalok.utils.DateUtil;
import com.kavalok.xmlrpc.RemoteClient;

public class LoginService extends DataServiceBase {

  public static String SOMEONE_USED_YOUR_LOGIN = "Someone used your email to login";

  public static final String GUEST_EMAIL = "guest";

  private static String SUCCESS = "success";

  private static String ERROR_UNKNOWN = "unknown";

  private static String ERROR_LOGIN_BANNED = "login_banned";

  private static String ERROR_IP_BANNED = "ip_banned";

  // private static String ERROR_LOGIN_NOT_ACTIVE = "login_not_active ";

  private static String ERROR_BAD_LOGIN = "bad_login";

  private static String ERROR_BAD_PASSW = "bad_passw";

  private static String ERROR_LOGIN_DISABLED = "disabled";

  private static final Logger logger = LoggerFactory.getLogger(LoginService.class);

  private static Integer prefixedCont = 0;

  public String freeLoginByPrefix(String prefix) throws FileNotFoundException {
    return null;
//     String login;
//
//     MessageCheck messageCheck = new MessageCheck(getSession());
//     if (messageCheck.check(prefix).getSafety() != MessageSafety.SAFE
//         || messageCheck.check(" " + prefix).getSafety() != MessageSafety.SAFE
//         || messageCheck.check(prefix + " ").getSafety() != MessageSafety.SAFE
//         || messageCheck.check(" " + prefix + " ").getSafety() != MessageSafety.SAFE) {
//       return null;
//     }
//     synchronized (LoginService.class) {
//       login = prefix + prefixedCont.toString();
//       prefixedCont++;
//     }
//     UserAdapter adapter = registerAdapter(login, getCurrentServer(), -1L);
//     adapter.setUserId(-1l);
//     adapter.setPersistent(false);
//     return login;
  }

  public LoginResultTO freeLogin(String name, String body, Integer color, String locale) throws FileNotFoundException {
    // TODO: Enable this in a safe way to facilitate guests

    LoginResultTO resultTO = new LoginResultTO();
    resultTO.setSuccess(false);
    resultTO.setReason(ERROR_LOGIN_DISABLED);

    return resultTO;

//     UserDAO userDAO = new UserDAO(getSession());
//     User user = userDAO.findByLogin(name);
//
//     if (user == null) {
//       user = userDAO.findByLogin(name.toLowerCase());
//     }
//
//     LoginResultTO result = null;
//
//     if (user == null) {
//       String registartionResult = register(name, "", GUEST_EMAIL, body, color, true, false, locale, null, null);
//       if (registartionResult.equals(SUCCESS)) {
//         user = userDAO.findByLogin(name);
//         user.setActivationKey(null);
//         user.setEnabled(true);
//         userDAO.makePersistent(user);
//         // Instead of sending the password, require the client to login with their password
//         result = login(name, "", locale); // Empty password, should only be used for guests
//       }
//     } else {
//       // Do not send the password to the client
//       result = login(name, "", locale); // Empty password, should only be used for guests
//     }
//     return result;
  }

  public boolean activateAccount(String login, String activationKey, Boolean chatEnabled) {
    return new UserUtil().activateAccount(getSession(), login, activationKey, chatEnabled);
  }

  public ServerPropertiesTO getServerProperties() {
    return new ServerPropertiesTO();
  }

  public String adminLogin(String login, String password) {
    return tryLogin(new AdminDAO(getSession()), login, password);
  }

  public String partnerLogin(String login, String password) {
    return tryLogin(new PartnerDAO(getSession()), login, password);
  }

  @SuppressWarnings("unchecked")
  private String tryLogin(LoginDAOBase dao, String login, String password) {
    LoginModelBase model = dao.findByLogin(login.toLowerCase());
    if (model != null && model instanceof com.kavalok.db.User) {
      com.kavalok.db.User user = (com.kavalok.db.User) model;
      if (user.checkPassword(password, user.getSalt())) {
        UserAdapter currentUser = UserManager.getInstance().getCurrentUser();
        currentUser.setUserId(model.getId());
        currentUser.setLogin(login);
        currentUser.setAccessType(model.getAccessType());
        return SUCCESS;
      }
    }
    return ERROR_UNKNOWN;
  }

  private Server getCurrentServer() {
    return KavalokApplication.getInstance().getServer();
  }

  public PartnerLoginCredentialsTO getPartnerLoginInfo(String uid) {
    return null;
//     System.out.println("uid: " + uid);
//     LoginFromPartnerDAO dao = new LoginFromPartnerDAO(getSession());
//     LoginFromPartner loginFromPartner = dao.findByUid(uid);
//     if (loginFromPartner != null) {
//       User user = loginFromPartner.getUser();
//       System.out.println(
//           "loginFromPartner: "
//               + loginFromPartner
//               + " loginFromPartnerId: "
//               + loginFromPartner.getId());
//       System.out.println("user: " + user + " userId: " + user.getId());
//       boolean needRegistartion = user.getGameChar_id() == null;
//       if (!needRegistartion) dao.makeTransient(loginFromPartner);
//
//       return new PartnerLoginCredentialsTO(
//           user.getId().intValue(), user.getLogin(), needRegistartion);
//     } else {
//       throw new IllegalStateException(String.format("unknown login uid %1s", uid));
//     }
  }

  /**
   * Main login method. Handles authentication, session setup, and migration of legacy users.
   * Ensures UserAdapter is always set up with userId. Logs all critical steps.
   */
  public LoginResultTO login(String login, String password, String locale) {
    logger.info("login called for user: {}", login);
    LoginResultTO resultTO = new LoginResultTO();
    UserDAO userDAO = new UserDAO(getSession());
    BlackIPDAO blackIPDAO = new BlackIPDAO(getSession());
    User user = userDAO.findByLogin(login);
    if (user == null) {
      user = userDAO.findByLogin(login.toLowerCase());
    }
    if (user == null || user.getDeleted()) {
      logger.warn("Login failed: user not found or deleted for login: {}", login);
      resultTO.setSuccess(false);
      resultTO.setReason(ERROR_BAD_LOGIN);
      return resultTO;
    }

    if (!user.checkPassword(password, user.getSalt())) {
      logger.warn("Login failed: bad password for user: {}", login);
      resultTO.setSuccess(false);
      resultTO.setReason(ERROR_BAD_PASSW);
      return resultTO;
    }

    // Migrate legacy users (salt not present, has plaintext password)
    if (user.getSalt() == null) {
      String newSalt = com.kavalok.utils.StringUtil.generateSalt(32);
      String newHash = com.kavalok.utils.StringUtil.hashPassword(password, newSalt);
      user.setSalt(newSalt);
      user.setPassword(newHash);
      userDAO.makePersistent(user);
      logger.info("Migrated legacy user to salted hash: {}", login);
    }
    if (user.isBaned()) {
      logger.warn("Login failed: user banned: {}", login);
      resultTO.setSuccess(false);
      resultTO.setReason(ERROR_LOGIN_BANNED);
      return resultTO;
    }
    if (!user.isEnabled()) {
      logger.warn("Login failed: user disabled: {}", login);
      resultTO.setSuccess(false);
      resultTO.setReason(ERROR_LOGIN_DISABLED);
      return resultTO;
    }
    UserExtraInfo uei = user.getUserExtraInfo();
    String lastIp = null;
    if (uei != null) {
      lastIp = uei.getLastIp();
    }
    BlackIP blackIP = blackIPDAO.findByIp(lastIp);
    if (blackIP != null && blackIP.isBaned()) {
      logger.warn("Login failed: IP banned: {}", login);
      resultTO.setSuccess(false);
      resultTO.setReason(ERROR_IP_BANNED);
      return resultTO;
    }
    boolean updateUser = false;
    if (uei == null) {
      updateUser = true;
      uei = new UserExtraInfo();
    }
    UserServerDAO userServerDAO = new UserServerDAO(getSession());
    UserServer currentUs = userServerDAO.getUserServer(user);
    Server server = getCurrentServer();
    if (currentUs != null) {
      Server currentServer = currentUs.getServer();
      if (!currentServer.getId().equals(server.getId())) {
        new UserUtil().kickOut(user, false, getSession());
      } else {
        UserAdapter adapter = UserManager.getInstance().getUser(login);
        if (adapter != null) {
          adapter.executeCommand("KickOutCommand", false);
        }
      }
    }
    if (currentUs == null) {
      currentUs = new UserServer(user, server);
    }
    userServerDAO.makePersistent(currentUs);
    if (locale != null && !locale.equals(user.getLocale())) {
      user.setLocale(locale);
      updateUser = true;
    }
    // Always set up UserAdapter with userId
    UserAdapter currentUser = registerAdapter(login, server, user.getId());
    if (user.getId() == null) {
      logger.error("User ID is null after login for login: {}", login);
      throw new IllegalStateException("User ID is null on login");
    }
    if (currentUser.getUserId() == null || !currentUser.getUserId().equals(user.getId())) {
      logger.error(String.format("UserAdapter userId mismatch after login for login: %s. Adapter userId: %s DB userId: %s", login, currentUser.getUserId(), user.getId()));
      throw new IllegalStateException("UserAdapter userId mismatch after login");
    }
    currentUser.setAccessType(AccessUser.class);
    boolean updateUei = processComboLogin(user, uei); // giving some stuff for login 10-20-30 days in row
    String currentIP = currentUser.getConnection().getRemoteAddress();
    if (updateUei || !currentIP.equals(uei.getLastIp())) {
      uei.setLastIp(currentIP);
      new UserExtraInfoDAO(getSession()).makePersistent(uei);
    }
    if (updateUser) {
      user.setUserExtraInfo(uei);
      userDAO.makePersistent(user);
    }
    logger.info("User {} login, ip: {}", login, currentIP);
    return new LoginResultTO(true, user.isActive(), UserUtil.getAge(user), SUCCESS);
  }

  private boolean processComboLogin(User user, UserExtraInfo uei) {
    if (uei == null) {
      uei = new UserExtraInfo();
    }
    Date lastLogin = uei.getLastLoginDate();
    if (lastLogin == null || uei.getContinuousDaysLoginCount() == null) {
      uei.setContinuousDaysLoginCount(1);
      return true;
    } else {
      Date now = new Date();
      if (DateUtil.daysFollowing(lastLogin, now)) {
        uei.setContinuousDaysLoginCount(uei.getContinuousDaysLoginCount() + 1);
        uei.setLastLoginDate(now);
        if (uei.getContinuousDaysLoginCount() == 10
            || uei.getContinuousDaysLoginCount() == 20
            || uei.getContinuousDaysLoginCount() == 30) {
          assignComboLoginItem(user, uei);
        }
        return true;
      } else if (!DateUtil.sameDay(lastLogin, now)) {
        uei.setContinuousDaysLoginCount(1);
        return true;
      }
    }
    return false;
  }

  private void assignComboLoginItem(User user, UserExtraInfo uei) {
    StuffTypeDAO stDAO = new StuffTypeDAO(getSession());
    StuffType itemType = stDAO.findByFileName("futbolka_" + uei.getContinuousDaysLoginCount());
    if (itemType != null) {
      StuffItem item = new StuffItem();
      item.setType(itemType);
      item.setUsed(false);
      GameChar gameChar = user.getGameCharIdentifier();
      item.setGameChar(gameChar);
      new StuffItemDAO(getSession()).makePersistent(item);

      ObjectMap<String, Object> command = new ObjectMap<String, Object>();
      command.put("days", uei.getContinuousDaysLoginCount());
      command.put("itemId", item.getId());
      command.put("className", "com.kavalok.messenger.commands::ComboLoginItemMessage");
      Message msg = new Message(gameChar, command);
      MessageDAO messageDAO = new MessageDAO(getSession());
      Long messId = messageDAO.makePersistent(msg).getId();
      command.put("id", messId);

      // new RemoteClient(getSession(), user).sendCommand(command);
    }
  }

  private UserAdapter registerAdapter(String login, Server server, Long userId) {
    UserManager manager = UserManager.getInstance();
    UserAdapter userAdapter = manager.getUser(login);
    if (userAdapter != null) {
      logger.info("Kicking out previous session for login: {}", login);
      userAdapter.kickOut(SOMEONE_USED_YOUR_LOGIN, false);
    }
    UserAdapter currentUser = manager.getCurrentUser();
    if (currentUser != null) {
      logger.info("Setting up UserAdapter for login: {}, userId: {}", login, userId);
      currentUser.setLogin(login);
      currentUser.setServer(server);
      currentUser.setUserId(userId);
    } else {
      logger.error("Current UserAdapter is null after login for login: {}", login);
      throw new IllegalStateException("Current UserAdapter is null after login");
    }
    return currentUser;
  }

  public String register(
      String login,
      String passw,
      String email,
      String body,
      Integer color,
      Boolean isParent,
      Boolean familyMode,
      String locale,
      Object invitedBy,
      MarketingInfoTO marketingInfo)
      throws FileNotFoundException {
    return register(
        login,
        passw,
        email,
        body,
        color,
        isParent,
        familyMode,
        locale,
        (String) invitedBy,
        marketingInfo);
  }

  public String register(
      String login,
      String passw,
      String email,
      String body,
      Integer color,
      Boolean isParent,
      Boolean familyMode,
      String locale,
      String invitedBy,
      MarketingInfoTO marketingInfo)
      throws FileNotFoundException {

    return new UserUtil()
        .register(
            getSession(),
            login,
            passw,
            email,
            body,
            color,
            isParent,
            familyMode,
            locale,
            invitedBy,
            marketingInfo,
            false);
  }

//   public String registerGirls(
//       String login,
//       String passw,
//       String email,
//       String body,
//       Integer color,
//       Boolean isParent,
//       Boolean familyMode,
//       String locale,
//       Object invitedBy,
//       MarketingInfoTO marketingInfo)
//       throws FileNotFoundException {
//     return registerGirls(
//         login,
//         passw,
//         email,
//         body,
//         color,
//         isParent,
//         familyMode,
//         locale,
//         (String) invitedBy,
//         marketingInfo);
//   }

//   public String registerGirls(
//       String login,
//       String passw,
//       String email,
//       String body,
//       Integer color,
//       Boolean isParent,
//       Boolean familyMode,
//       String locale,
//       String invitedBy,
//       MarketingInfoTO marketingInfo)
//       throws FileNotFoundException {
//
//     return new UserUtil()
//         .register(
//             getSession(),
//             login,
//             passw,
//             email,
//             body,
//             color,
//             isParent,
//             familyMode,
//             locale,
//             invitedBy,
//             marketingInfo,
//             true);
//   }
//
//   public String registerFromPartner(String uid, String body, Integer color, Boolean isParent) {
//     LoginFromPartnerDAO dao = new LoginFromPartnerDAO(getSession());
//     LoginFromPartner loginFromPartner = dao.findByUid(uid);
//     User user = loginFromPartner.getUser();
//     GameCharDAO charDAO = new GameCharDAO(getSession());
//     new UserUtil().fillUser(charDAO, getSession(), user, body, color, isParent, true);
//     return SUCCESS;
//   }

  public ActivationTO getActivationInfo(String login) {
    UserDAO userDAO = new UserDAO(getSession());
    User user = userDAO.findByLogin(login.toLowerCase());

    return new ActivationTO(user);
  }

  public String sendActivationMail(String host, String login, String locale) {
    return null;
//     return new UserUtil()
//         .sendActivationMail(
//             KavalokApplication.getInstance().getApplicationConfig().getHost(),
//             login,
//             locale,
//             getSession());
  }

  public Boolean sendPassword(String email, String locale) {
    return null;
    //return new UserUtil().sendPassword(email, locale, getSession());
  }

  public String guestLogin(MarketingInfoTO marketingInfoTO) {
    return null;
//     UserDAO userDAO = new UserDAO(getSession());
//     User user = userDAO.getGuest();
//     MarketingInfo info = MarketingInfo.fromTO(marketingInfoTO, getSession());
//     GuestMarketingInfo guestMarketingInfo = new GuestMarketingInfo();
//     guestMarketingInfo.setUser(user);
//     guestMarketingInfo.setMarketingInfo(info);
//     new MarketingInfoDAO(getSession()).makePersistent(info);
//     new GuestMarketingInfoDAO(getSession()).makePersistent(guestMarketingInfo);
//     login(user.getLogin(), user.getPassword(), null);
//     return user.getLogin();
  }

  public String getMostLoadedServer(String location) {
    try {
      List<Object[]> serversLoad = new UserServerDAO(getSession()).getServerLoad();
      for (Object[] serverLoad : serversLoad) {
        String name = (String) serverLoad[0];
        Integer load = Integer.parseInt(serverLoad[1].toString());
        String url = (String) serverLoad[2];
        if (load < KavalokApplication.getInstance().getServerLimit()) {
          Server server = new Server();
          server.setName(name);
          server.setUrl(url);
          RemoteClient client = new RemoteClient(server);
          Integer numConnectedChars = client.getNumConnectedChars(location);
          if (numConnectedChars != null && numConnectedChars < 75) {
            return name;
          }
        }
      }
    } catch (HibernateException e) {
      e.printStackTrace();
      return null;
    } catch (SQLException e) {
      e.printStackTrace();
      return null;
    }
    return null;
  }
}
