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
import com.kavalok.dao.BlackIPDAO;
import com.kavalok.dao.MessageDAO;
import com.kavalok.dao.StuffItemDAO;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.dao.UserExtraInfoDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.db.BlackIP;
import com.kavalok.db.GameChar;
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
    //     UserAdapter adapter = getUserAdapter(login, getCurrentServer(), -1L);
    //     adapter.setUserId(-1l);
    //     adapter.setPersistent(false);
    //     return login;
  }

  public LoginResultTO freeLogin(String name, String body, Integer color, String locale)
      throws FileNotFoundException {
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
    //       String registartionResult = register(name, "", GUEST_EMAIL, body, color, true, false,
    // locale, null, null);
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

  //   public String adminLogin(String login, String password) {
  //     return tryLogin(new AdminDAO(getSession()), login, password);
  //   }
  //
  //   public String partnerLogin(String login, String password) {
  //     return tryLogin(new PartnerDAO(getSession()), login, password);
  //   }

  //   @SuppressWarnings("unchecked")
  //   private String tryLogin(LoginDAOBase dao, String login, String password) {
  //     LoginModelBase model = dao.findByLogin(login.toLowerCase());
  //     if (model != null && model instanceof com.kavalok.db.User) {
  //       com.kavalok.db.User user = (com.kavalok.db.User) model;
  //       if (user.checkPassword(password, user.getSalt())) {
  //         UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
  //         userAdapter.setUserId(model.getId());
  //         userAdapter.setLogin(login);
  //         userAdapter.setAccessType(model.getAccessType());
  //         return SUCCESS;
  //       }
  //     }
  //     return ERROR_UNKNOWN;
  //   }

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

  public LoginResultTO login(String login, String password, String locale) {
    UserDAO userDAO = new UserDAO(getSession());
    User user = findUserByLogin(login, userDAO);

    if (user == null) {
      return createErrorResult(ERROR_BAD_LOGIN);
    }

    if (!user.checkPassword(password, user.getSalt())) {
      return createErrorResult(ERROR_BAD_PASSW);
    }

    // Migrate legacy users (salt not present, has plaintext password)
    if (user.getSalt() == null) {
      String newSalt = com.kavalok.utils.StringUtil.generateSalt(32);
      String newHash = com.kavalok.utils.StringUtil.hashPassword(password, newSalt);
      user.setSalt(newSalt);
      user.setPassword(newHash);
      userDAO.makePersistent(user);
    }

    // Generate login token
    String loginToken = com.kavalok.utils.StringUtil.generateRandomString(32);
    user.setLoginToken(loginToken);

    return performLogin(user, userDAO, locale, loginToken);
  }

  private LoginResultTO createErrorResult(String reason) {
    LoginResultTO result = new LoginResultTO();
    result.setSuccess(false);
    result.setReason(reason);
    return result;
  }

  private User findUserByLogin(String login, UserDAO userDAO) {
    User user = userDAO.findByLogin(login);
    if (user == null) {
      user = userDAO.findByLogin(login.toLowerCase());
    }
    if (user == null || user.getDeleted()) {
      return null;
    }
    return user;
  }

  private LoginResultTO performLogin(User user, UserDAO userDAO, String locale, String loginToken) {
    if (user.isBaned()) {
      return createErrorResult(ERROR_LOGIN_BANNED);
    }

    if (!user.isEnabled()) {
      return createErrorResult(ERROR_LOGIN_DISABLED);
    }

    UserExtraInfo uei = user.getUserExtraInfo();
    String lastIp = null;
    if (uei != null) {
      lastIp = uei.getLastIp();
    }

    BlackIPDAO blackIPDAO = new BlackIPDAO(getSession());
    BlackIP blackIP = blackIPDAO.findByIp(lastIp);
    if (blackIP != null && blackIP.isBaned()) {
      return createErrorResult(ERROR_IP_BANNED);
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
        UserAdapter adapter = UserManager.getInstance().getUser(user.getLogin());
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

    UserManager manager = UserManager.getInstance();
    UserAdapter priorUserAdapter = manager.getUser(user.getLogin());

    if (priorUserAdapter != null) {
      logger.info("Kicking out prior existing session for user: {}", user.getLogin());
      priorUserAdapter.kickOut(SOMEONE_USED_YOUR_LOGIN, false);
    }

    // Get adapter for current session
    UserAdapter userAdapter = manager.getCurrentUser();

    userAdapter.setLogin(user.getLogin());
    userAdapter.setServer(server);
    userAdapter.setUserId(user.getId());

    userAdapter.setAccessType(AccessUser.class);
    boolean updateUei = processComboLogin(user, uei);

    String currentIP = userAdapter.getConnection().getRemoteAddress();
    if (updateUei || !currentIP.equals(uei.getLastIp())) {
      uei.setLastIp(currentIP);
      new UserExtraInfoDAO(getSession()).makePersistent(uei);
    }

    if (updateUser) {
      user.setUserExtraInfo(uei);
      userDAO.makePersistent(user);
    } else {
      userDAO.makePersistent(user);
    }

    LoginResultTO result = new LoginResultTO(true, user.isActive(), UserUtil.getAge(user), SUCCESS);
    result.setLoginToken(loginToken);
    return result;
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
    // return new UserUtil().sendPassword(email, locale, getSession());
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

  public LoginResultTO loginWithToken(String login, String token, String locale) {
    UserDAO userDAO = new UserDAO(getSession());
    User user = findUserByLogin(login, userDAO);

    if (user == null) {
      return createErrorResult(ERROR_BAD_LOGIN);
    }

    if (!token.equals(user.getLoginToken())) {
      return createErrorResult(ERROR_BAD_PASSW);
    }

    // Generate a new token for the next login (token rotation)
    String newLoginToken = com.kavalok.utils.StringUtil.generateRandomString(32);
    user.setLoginToken(newLoginToken);
    userDAO.makePersistent(user);

    return performLogin(user, userDAO, locale, newLoginToken);
  }
}
