package com.kavalok.user;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Random;

import org.hibernate.Session;
import org.red5.io.utils.ObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.BanDAO;
import com.kavalok.dao.BlackIPDAO;
import com.kavalok.dao.EmailExtraInfoDAO;
import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.MailServerDAO;
import com.kavalok.dao.MarketingInfoDAO;
import com.kavalok.dao.MembershipHistoryDAO;
import com.kavalok.dao.MembershipInfoDAO;
import com.kavalok.dao.MessageDAO;
import com.kavalok.dao.StuffItemDAO;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.dao.TransactionUserInfoDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.dao.statistics.MoneyStatisticsDAO;
import com.kavalok.db.Ban;
import com.kavalok.db.BlackIP;
import com.kavalok.db.EmailExtraInfo;
import com.kavalok.db.GameChar;
import com.kavalok.db.MailServer;
import com.kavalok.db.MarketingInfo;
import com.kavalok.db.MembershipHistory;
import com.kavalok.db.MembershipInfo;
import com.kavalok.db.Message;
import com.kavalok.db.Partner;
import com.kavalok.db.RobotItem;
import com.kavalok.db.RobotSKU;
import com.kavalok.db.RobotTransaction;
import com.kavalok.db.StuffItem;
import com.kavalok.db.StuffType;
import com.kavalok.db.Transaction;
import com.kavalok.db.TransactionUserInfo;
import com.kavalok.db.User;
import com.kavalok.db.statistics.MoneyStatistics;
import com.kavalok.dto.login.MarketingInfoTO;
import com.kavalok.mail.Email;
import com.kavalok.mail.MailSender;
import com.kavalok.mail.MailUtil;
import com.kavalok.messages.MessageCheck;
import com.kavalok.messages.MessageSafety;
import com.kavalok.services.LoginService;
import com.kavalok.services.RobotService;
import com.kavalok.utils.ReflectUtil;
import com.kavalok.utils.StringUtil;
import com.kavalok.xmlrpc.RemoteClient;

public class UserUtil {

  private static final int MIN_LOGIN_LENGTH = 4;

  private static final Double START_MONEY = 500d;

  private static final String URL_SEPARATOR = "?";

  private static final String PARAMETERS_SEPARATOR = "&";

  private static Logger logger = LoggerFactory.getLogger(MailSender.class);

  public static final String ACTIVATION_POSTFIX = "login=%s&activationKey=%s&chatEnabled=%s";

  private static Properties ADMIN_MAIL_PROPERTIES = new Properties();

  public static int MAX_FAMILY = 7;

  private static String MAIL_CONFIG_PATH = "mail.properties";

  private static String SUCCESS = "success";

  private static String ERROR_LOGIN_EXISTS = "login_exists";

  private static String ERROR_EMAIL_NOT_FOUND = "email_not_found";

  private static String ERROR_FAMILY_FULL = "familyIsFull";

  private static String REGISTRATION_DISABLED = "registration_disabled";

  private static final SimpleDateFormat ITEM_OF_THE_MONTH_FORMAT = new SimpleDateFormat("yyyyMM");

  static {
    try {
      String path = ReflectUtil.getRootPath(UserUtil.class);
      FileInputStream input = new FileInputStream(path + "/" + MAIL_CONFIG_PATH);
      ADMIN_MAIL_PROPERTIES.load(input);
    } catch (FileNotFoundException e) {
      logger.error(e.getMessage(), e);
    } catch (IOException e) {
      logger.error(e.getMessage(), e);
    }
  }

  public boolean activateAccount(
      Session session, String login, String activationKey, Boolean chatEnabled) {
    UserDAO userDAO = new UserDAO(session);
    User user = userDAO.findByLogin(login.toLowerCase());

    if (user == null) return false;

    if (!user.getActivationKey().equals(activationKey)) return false;

    BanDAO banDAO = new BanDAO(session);
    Ban ban = getBanModel(banDAO, user);

    user.setActivated(true);
    ban.setChatEnabled(true); // admin can disable chat at any time
    user.setChatEnabled(chatEnabled); // this field is controlled by parent
    userDAO.makePersistent(user);
    banDAO.makePersistent(ban);

    return true;
  }

  public String register(
      Session session,
      String login,
      String passw,
      String email,
      String body,
      Integer color,
      Boolean isParent,
      Boolean familyMode,
      String locale,
      String invitedBy,
      MarketingInfoTO marketingInfoTO,
      boolean girls) {

    if (!(KavalokApplication.getInstance().isRegistrationEnabled())) {
      return REGISTRATION_DISABLED;
    }

    login = login.toLowerCase();
    email = email.toLowerCase();

    UserDAO userDAO = new UserDAO(session);

    if (login.indexOf("ass") >= 0) {
      return ERROR_LOGIN_EXISTS;
    }

    if (login.length() < MIN_LOGIN_LENGTH) {
      return ERROR_LOGIN_EXISTS;
    }
    if (userDAO.findByLogin(login) != null) {
      return ERROR_LOGIN_EXISTS;
    }

    MessageCheck messageCheck = new MessageCheck(session);
    if (messageCheck.check(login).getSafety() != MessageSafety.SAFE
        || messageCheck.check(" " + login).getSafety() != MessageSafety.SAFE
        || messageCheck.check(" " + login).getSafety() != MessageSafety.SAFE
        || messageCheck.check(" " + login + " ").getSafety() != MessageSafety.SAFE) {
      return ERROR_LOGIN_EXISTS;
    }

    List<User> family;
    if (!email.equals(LoginService.GUEST_EMAIL)) {
      family = userDAO.findByEmail(email, true);
      if (family.size() >= MAX_FAMILY) {
        return ERROR_FAMILY_FULL;
      }
    } else {
      family = new ArrayList<User>();
    }

    User user = new User(login, passw);
    user.setEnabled(true);
    user.setEmail(email);

    if (!StringUtil.isEmptyOrNull(invitedBy)) {
      User invitee = userDAO.findByLogin(invitedBy);
      user.setInvitedBy(invitee);
    }

    MarketingInfo info = MarketingInfo.fromTO(marketingInfoTO, session);

    user.setMarketingInfo(info);
    new MarketingInfoDAO(session).makePersistent(info);

    GameCharDAO charDAO = new GameCharDAO(session);

    // Chobots.org Modification - Default chatEnabled and activated to true (originally false) due
    // to probable lack of email activation configuration
    Boolean chatEnabled = true;
    Boolean activated = true;

    GameChar gameChar = fillUser(charDAO, session, user, body, color, isParent, chatEnabled);
    addPartnerItem(session, info, gameChar);
    addInitialItems(session, gameChar, girls);

    for (User friend : family) {
      user.getFriends().add(friend);
      userDAO.makePersistent(user);

      friend.getFriends().add(user);
      userDAO.makePersistent(friend);
    }

    initMembershipInfo(session, user);

    user.setActivated(activated);
    userDAO.makePersistent(user);
    if (locale != null && !familyMode && !email.equals(LoginService.GUEST_EMAIL)) {
      sendActivationMail(
          KavalokApplication.getInstance().getApplicationConfig().getHost(),
          userDAO,
          user,
          locale,
          session);
      // sendAdminMail(session, login, email);
    }

    Partner partner = info.getPartner();
    if (partner != null && "cpmstar".equals(partner.getLogin())) {
      try {
        URL u = new URL("http://server.cpmstar.com/action.aspx?advertiserid=749&gif=1");
        System.err.println("cpmstar partner");
        URLConnection uc = u.openConnection();
        uc.setRequestProperty("Referer", "http://www.chobots.com/?partner=cpmstar");
        uc.setDoOutput(true);
        BufferedReader in = new BufferedReader(new InputStreamReader(uc.getInputStream()));
        in.readLine();
        in.close();
      } catch (MalformedURLException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      } catch (IOException e1) {
        // TODO Auto-generated catch block
        e1.printStackTrace();
      }
    }

    return SUCCESS;
  }

  private static void initMembershipInfo(Session session, User user) {

    MembershipInfo membershipInfo = user.getMembershipInfo();
    if (membershipInfo == null) {
      membershipInfo = new MembershipInfo();
    }
    membershipInfo.setFinishingNotificationShowed(false);
    membershipInfo.setFinishedNotificationShowed(false);
    MembershipInfoDAO mid = new MembershipInfoDAO(session);
    mid.makePersistent(membershipInfo);

    user.setMembershipInfo(membershipInfo);
  }

  private void addPartnerItem(Session session, MarketingInfo info, GameChar gameChar) {
    if (info.getPartner() != null && info.getPartner().getStuff() != null) {
      StuffItem partnerItem = new StuffItem();
      partnerItem.setType(info.getPartner().getStuff());
      partnerItem.setUsed(true);
      partnerItem.setGameChar(gameChar);
      new StuffItemDAO(session).makePersistent(partnerItem);
    }
  }

  private void addInitialItems(Session session, GameChar gameChar, boolean girls) {
    List<String> nonCitizenFileNames = new ArrayList<String>();
    nonCitizenFileNames.add("peruka_2");
    nonCitizenFileNames.add("hair_care");
    nonCitizenFileNames.add("hair_jedy");
    nonCitizenFileNames.add("peruka_1");
    nonCitizenFileNames.add("shirt_pet");
    nonCitizenFileNames.add("futbolka_heard");
    nonCitizenFileNames.add("shirt_work");
    nonCitizenFileNames.add("pants5");
    nonCitizenFileNames.add("shtani");
    nonCitizenFileNames.add("pants3");
    nonCitizenFileNames.add("shirt_bboy");
    nonCitizenFileNames.add("sirt_bgirl");
    nonCitizenFileNames.add("pachka");
    nonCitizenFileNames.add("boots");
    nonCitizenFileNames.add("peruka_anime2");
    nonCitizenFileNames.add("peruka_emo5");
    List<String> citizenFileNames = new ArrayList<String>();
    citizenFileNames.add("cheerleader_girl");
    citizenFileNames.add("Ninja");
    addInitialItems(session, gameChar, nonCitizenFileNames, false, false);
    addInitialItems(session, gameChar, citizenFileNames, true, false);
    if (girls) {
      List<String> girlsFileNames = new ArrayList<String>();
      girlsFileNames.add("face_doll_5");
      girlsFileNames.add("dress_7_reg");
      addInitialItems(session, gameChar, girlsFileNames, false, true);
    }
  }

  private void addInitialItems(
      Session session, GameChar gameChar, List<String> fileNames, boolean citizen, boolean putOn) {
    StuffTypeDAO td = new StuffTypeDAO(session);
    StuffItemDAO stuffItemDAO = new StuffItemDAO(session);
    List<StuffType> types = td.findByFileNames(fileNames.toArray());
    for (Iterator<StuffType> iterator = types.iterator(); iterator.hasNext(); ) {
      StuffType stuffType = iterator.next();
      if (fileNames.contains(stuffType.getFileName())
          && Boolean.valueOf(citizen).equals(stuffType.getPremium())) {
        StuffItem initialItem = new StuffItem();
        initialItem.setType(stuffType);
        if (stuffType.getHasColor()) {
          initialItem.setColor((int) Math.round(Math.random() * 16777215));
        }

        initialItem.setUsed(putOn);
        initialItem.setGameChar(gameChar);
        stuffItemDAO.makePersistent(initialItem);
        fileNames.remove(stuffType.getFileName());
      }
    }
  }

  public GameChar fillUser(
      GameCharDAO charDAO,
      Session session,
      User user,
      String body,
      int color,
      Boolean isParent,
      Boolean chatEnabled) {
    UserDAO userDAO = new UserDAO(session);
    GameChar gameChar = new GameChar();
    gameChar.setBody(body);
    gameChar.setColor(color);
    gameChar.setMoney(START_MONEY);
    gameChar.setUser(user);

    charDAO.makePersistent(gameChar);

    user.setParent(isParent);
    user.setChatEnabled(chatEnabled);
    user.setGameChar(gameChar);
    user.setDeleted(false);
    userDAO.makePersistent(user);
    gameChar.setUserId(user.getId());
    charDAO.makePersistent(gameChar);

    BanDAO banDAO = new BanDAO(session);
    Ban ban = banDAO.findByUser(user);
    if (ban == null) { // ban already exists when this function called by
      // LoginService.registerFromPartnerFromPartner
      ban = new Ban();
      ban.setUser(user);
      ban.setChatEnabled(isParent);
      banDAO.makePersistent(ban);
    }
    return gameChar;
  }

  private static String ACTIVATION_URL = "http://%s/kavalok/jsp/activation%s.jsp";

  private static String PARTNER_ACTIVATION_URL = "http://%s/kavalok/jsp/activationpartner%s.jsp";

  public String sendActivationMail(String host, String login, String locale, Session session) {
    UserDAO userDAO = new UserDAO(session);
    User user = userDAO.findByLogin(login.toLowerCase());
    return sendActivationMail(host, userDAO, user, locale, session);
  }

  public String sendActivationMail(
      String host, UserDAO userDAO, User user, String locale, Session session) {

    if (user == null) return ERROR_EMAIL_NOT_FOUND;

    Partner partner = user.getMarketingInfo().getPartner();

    String fileName =
        user.isParent() ? MailUtil.PARENT_ACTIVATION_FILE : MailUtil.CHILD_ACTIVATION_FILE;

    boolean insertPartnerUrl = false;
    if (partner != null && !StringUtil.isEmptyOrNull(partner.getPortalUrl())) {
      insertPartnerUrl = true;
      fileName =
          user.isParent()
              ? MailUtil.PARENT_PARTNER_ACTIVATION_FILE
              : MailUtil.CHILD_PARTNER_ACTIVATION_FILE;
    }

    Email email = MailUtil.getMail(fileName, locale);

    if (user.getActivationKey() == null) {
      String key = StringUtil.generateRandomString(5);
      user.setActivationKey(key);
      userDAO.makePersistent(user);
    }
    String link1;
    String link2;
    String activationUrl;
    String localeUrl = "_" + locale;
    if (!"_deDE".equals(localeUrl)) {
      localeUrl = "";
    }
    if (partner == null) {
      activationUrl = String.format(ACTIVATION_URL, host, localeUrl);
    } else {
      activationUrl = String.format(PARTNER_ACTIVATION_URL, host, localeUrl);
    }

    user.getMarketingInfo().getActivationUrl();
    String separator = activationUrl.contains(URL_SEPARATOR) ? PARAMETERS_SEPARATOR : URL_SEPARATOR;
    link1 = activationUrl + separator + ACTIVATION_POSTFIX;
    link2 = activationUrl + separator + ACTIVATION_POSTFIX;

    link1 = String.format(link1, user.getLogin(), user.getActivationKey(), '1');
    link2 = String.format(link2, user.getLogin(), user.getActivationKey(), '0');

    email.content =
        insertPartnerUrl
            ? String.format(
                email.content,
                user.getLogin(),
                user.getPassword(),
                link1,
                link2,
                partner.getPortalUrl())
            : String.format(email.content, user.getLogin(), user.getPassword(), link1, link2);

    KavalokApplication.logger.info(
        "UserUtil.sendActivationMail user.isParent():"
            + user.isParent()
            + " user.getLogin()"
            + user.getLogin()
            + " link1: "
            + link1
            + " link2: "
            + link2
            + " email.content: "
            + email.content);

    Properties config = getMailServerConfig(session);
    MailUtil.sendMail(config, user.getEmail(), email);

    return SUCCESS;
  }

  // private void sendAdminMail(Session session, String login, String address) {
  //
  // Email email = MailUtil.getMail(MailUtil.ADMIN_MAIL_FILE_NAME, "");
  //
  // email.title = String.format(email.title, login, address);
  // email.content = String.format(email.content, login, address);
  //
  // MailUtil.sendMail(ADMIN_MAIL_PROPERTIES, MailUtil.ADMIN_ADDRESS, email);
  // }

  @SuppressWarnings("deprecation")
  public Boolean sendPassword(String address, String locale, Session session) {

    UserDAO userDAO = new UserDAO(session);
    List<User> users = userDAO.findByEmail(address.toLowerCase(), true);

    if (users.isEmpty()) return false;

    EmailExtraInfoDAO eD = new EmailExtraInfoDAO(session);
    EmailExtraInfo eei = eD.findByEmail(address);
    if (eei == null) {
      eei = new EmailExtraInfo();
      eei.setEmail(address);
    }

    Date now = new Date();
    String nowStr = now.getYear() + "" + now.getMonth() + "" + now.getDate();
    if (!nowStr.equals(eei.getLastRemindPasswordDate())) {
      eei.setLastRemindPasswordDate(nowStr);
      eei.setRemindPasswordCount(1);
    } else if (eei.getRemindPasswordCount() > 1) {
      return true;
    } else {
      eei.setRemindPasswordCount(2);
    }
    eD.makePersistent(eei);

    StringBuilder list = new StringBuilder();

    int counter = 1;
    for (User user : users) {
      list.append(counter + ": " + user.getLogin() + " / " + user.getPassword() + '\n');
      counter++;
    }

    Email email = MailUtil.getMail(MailUtil.PASSWORD_FILE, locale);
    email.content = String.format(email.content, list);
    MailUtil.sendMail(getMailServerConfig(session), address, email);

    return true;
  }

  private static Properties getMailServerConfig(Session session) {
    Properties config = new Properties();
    config.setProperty("mail.transport.protocol", "smtp");
    config.setProperty("mail.smtp.auth", "true");
    config.setProperty(
        "mail.from",
        KavalokApplication.getInstance().getApplicationConfig().getEmailsenderAddress());
    config.setProperty(
        "mail.smtp.from",
        KavalokApplication.getInstance().getApplicationConfig().getEmailsenderAddress());

    MailServerDAO mailServerDAO = new MailServerDAO(session);
    List<MailServer> servers = mailServerDAO.findAvailable();
    if (servers.size() == 0) return null;

    int index = new Random().nextInt(servers.size());
    MailServer server = servers.get(index);
    config.setProperty("mail.smtp.host", server.getUrl());
    config.setProperty("mail.smtp.port", server.getPort().toString());
    config.setProperty("mail.smtp.user", server.getLogin());
    config.setProperty("mail.user", server.getLogin());
    config.setProperty("mail.password", server.getPass());
    config.setProperty("mail.smtp.password", server.getPass());

    Date now = new Date();
    if (server.getLastUsageDate() == null || dayEquals(now, server.getLastUsageDate())) {
      server.setSentLastDay(server.getSentLastDay() + 1);
    }
    server.setLastUsageDate(now);
    mailServerDAO.makePersistent(server);
    return config;
  }

  @SuppressWarnings("deprecation")
  private static boolean dayEquals(Date first, Date second) {
    return first.getYear() == second.getYear()
        && first.getMonth() == second.getMonth()
        && first.getDate() == second.getDate();
  }

  public void saveUserBan(
      Session session, Integer userId, Boolean baned, String reason, String messages) {
    UserDAO dao = new UserDAO(session);
    User user = dao.findById(userId.longValue());
    saveUserBan(session, user, baned, reason, messages);
  }

  public void saveUserBan(
      Session session, User user, Boolean baned, String reason, String messages) {
    UserDAO dao = new UserDAO(session);
    user.setBaned(baned);
    if (baned) {
      if (messages != null) {
        user.setBanReason(reason + "\n\n" + messages);
      } else {
        user.setBanReason(reason);
      }
    }
    dao.makePersistent(user);
  }

  public void saveIPBan(Session session, String ip, Boolean baned, String reason) {
    if (ip == null || ip.trim().length() == 0) return;
    BlackIPDAO dao = new BlackIPDAO(session);
    BlackIP blackIP = dao.findByIp(ip);
    if (blackIP == null) {
      blackIP = new BlackIP();
      blackIP.setIp(ip);
    }
    blackIP.setBaned(baned);
    if (baned) {
      blackIP.setReason(reason);
    }
    dao.makePersistent(blackIP);
  }

  public void saveUserData(
      Session session,
      Integer userId,
      Boolean activated,
      Boolean chatEnabled,
      Boolean chatEnabledByParent,
      Boolean agent,
      Boolean baned,
      Boolean moderator,
      Boolean drawEnabled) {

    UserDAO dao = new UserDAO(session);
    User user = dao.findById(userId.longValue());
    BanDAO banDAO = new BanDAO(session);
    Ban ban = getBanModel(banDAO, user);

    if ((!chatEnabled && ban.isChatEnabled()) || (!chatEnabledByParent && user.isChatEnabled())) {
      new RemoteClient(session, user).disableUserChat(chatEnabled, chatEnabledByParent);
    }

    if (!drawEnabled.equals(user.getDrawEnabled())) {
      String parameter = drawEnabled ? "true" : "false";
      RemoteClient client = new RemoteClient(session, user);
      client.sendCommand("EnableDrawingCommand", parameter);
    }

    if (baned) kickOut(user, baned, session);

    user.setActivated(activated);

    ban.setChatEnabled(chatEnabled);
    user.setChatEnabled(chatEnabledByParent);
    user.setAgent(agent);
    user.setBaned(baned);
    user.setModerator(moderator);
    user.setDrawEnabled(drawEnabled);

    dao.makePersistent(user);
    banDAO.makePersistent(ban);
  }

  public void kickOut(Integer userId, boolean banned, Session session) {
    new RemoteClient(session, userId.longValue()).kickOutUser(banned);
  }

  public void kickOut(User user, boolean banned, Session session) {
    new RemoteClient(session, user).kickOutUser(banned);
  }

  public void kickOutNewThread(User user, boolean banned, Session session) {
    new RemoteClient(session, user).kickOutUserNewThread(banned);
  }

  public Ban getBanModel(BanDAO banDAO, User user) {
    Ban ban = banDAO.findByUser(user);
    if (ban == null) {
      ban = new Ban();
      ban.setUser(user);
    }
    return ban;
  }

  public static long getAge(User user) {
    return (new Date().getTime() - user.getCreated().getTime()) / 1000 / 60 / 60 / 24;
  }

  private static void sendCitizenshipCommand(
      Session session,
      User user,
      boolean extended,
      Integer months,
      Integer days,
      boolean tryMembership,
      String reason) {
    ObjectMap<String, Object> command = new ObjectMap<String, Object>();
    command.put("expireDate", user.getCitizenExpirationDate());
    command.put("extended", extended);
    command.put("months", months);
    command.put("days", days);
    command.put("tryMembership", tryMembership);
    command.put("reason", reason);
    command.put("className", "com.kavalok.messenger.commands::CitizenMembershipMessage");
    Message msg = new Message(user.getGameCharIdentifier(), command);
    MessageDAO messageDAO = new MessageDAO(session);
    Long messId = messageDAO.makePersistent(msg).getId();
    command.put("id", messId);

    new RemoteClient(session, user).sendCommand(command);
  }

  public static int daysCanTryCitizenship(Session session, Long userId) {
    UserDAO userDAO = new UserDAO(session);
    User user = userDAO.findById(userId);

    long age = getAge(user);
    if (age >= 30 && age < 60 && user.getCitizenTryCount() == 0) {
      return 3;
    } else if (age >= 60 && age < 100 && user.getCitizenTryCount() <= 1) {
      if (user.getCitizenTryCount() == 0) {
        return 6;
      } else if (user.getCitizenTryCount() == 1) {
        return 3;
      }
    } else if (age >= 100 && user.getCitizenTryCount() <= 2) {
      if (user.getCitizenTryCount() == 0) {
        return 10;
      } else if (user.getCitizenTryCount() == 1) {
        return 6;
      } else if (user.getCitizenTryCount() == 2) {
        return 3;
      }
    }

    return 0;
  }

  public static void tryCitizenship(Session session, Integer userId) {
    UserDAO userDAO = new UserDAO(session);
    User user = userDAO.findById(userId.longValue());

    long age = getAge(user);

    Integer days = 0;
    int tryCount = 0;

    if (age >= 30 && age < 60 && user.getCitizenTryCount() == 0) {
      days = 3;
      tryCount = 1;
    } else if (age >= 60 && age < 100 && user.getCitizenTryCount() <= 1) {
      if (user.getCitizenTryCount() == 0) {
        days = 6;
      } else if (user.getCitizenTryCount() == 1) {
        days = 3;
      }
      tryCount = 2;
    } else if (age >= 100 && user.getCitizenTryCount() <= 2) {
      if (user.getCitizenTryCount() == 0) {
        days = 10;
      } else if (user.getCitizenTryCount() == 1) {
        days = 6;
      } else if (user.getCitizenTryCount() == 2) {
        days = 3;
      }
      tryCount = 3;
    } else {
      return;
    }

    Date now = new Date();
    GregorianCalendar gc = new GregorianCalendar();
    gc.setTime(now);
    gc.add(GregorianCalendar.DAY_OF_YEAR, days);
    user.setCitizenExpirationDate(gc.getTime());
    user.setCitizenTryCount(tryCount);
    if (!user.isAgent() && !user.isModerator()) {
      user.setDrawEnabled(false);
    }

    initMembershipInfo(session, user);

    userDAO.makePersistent(user);

    MembershipHistoryDAO hitoryDao = new MembershipHistoryDAO(session);
    MembershipHistory history = new MembershipHistory();
    history.setUser(user);
    history.setReason("Try membership. Days: " + days);
    history.setPeriodDays(days.byteValue());
    history.setEndDate(user.getCitizenExpirationDate());
    hitoryDao.makePersistent(history);

    sendCitizenshipCommand(session, user, false, 0, days, true, null);
  }

  public static void buyCitizenship(
      Session session, User user, Transaction transaction, Integer months) {
    UserDAO userDAO = new UserDAO(session);

    Date now = new Date();
    Date citizenExpirationDate = user.getCitizenExpirationDate();
    boolean extend = citizenExpirationDate != null && citizenExpirationDate.after(now);

    GregorianCalendar gc = new GregorianCalendar();

    if (extend) {
      gc.setTime(citizenExpirationDate);
    } else {
      gc.setTime(now);
    }

    gc.add(GregorianCalendar.MONTH, months);
    user.setCitizenExpirationDate(gc.getTime());

    user.setDrawEnabled(true);

    initMembershipInfo(session, user);

    user.setActivated(true);

    userDAO.makePersistent(user);

    GameChar gameChar = user.getGameChar();

    addBugsBonus(session, user, transaction, gameChar);

    saveMembershipHistory(
        session, user, transaction, months, null, transaction.getSuccessMessage());
    sendCitizenshipCommand(session, user, extend, months, 0, false, null);
    assignItemOfMonth(session, user, gameChar, transaction, months);
    sendMembershipBoughtMessage(session, user, months, transaction.getId());
  }

  private static SimpleDateFormat MEMBERSHIP_END_DATE_FORMAT =
      new SimpleDateFormat("MM-dd-yyyy HH:mm");

  private static void sendMembershipBoughtMessage(
      Session session, User user, Integer months, Long transactionId) {
    Email email =
        MailUtil.getMail(
            user.isParent()
                ? MailUtil.MEMBERSHIP_BOUGHT_FILE_PARENT
                : MailUtil.MEMBERSHIP_BOUGHT_FILE_CHILD,
            user.getLocale());
    String activationUrl = "http://wwww.chobots.com";
    if (user.getMarketingInfo() != null) {
      activationUrl = user.getMarketingInfo().getActivationUrl();
    }

    email.content =
        String.format(
            email.content,
            user.getLogin(),
            months,
            MEMBERSHIP_END_DATE_FORMAT.format(user.getCitizenExpirationDate()),
            activationUrl);
    KavalokApplication.logger.info("UserUtil.sendMembershipBoughtMessage: " + email.content);

    Properties config = getMailServerConfig(session);

    List<TransactionUserInfo> infos =
        new TransactionUserInfoDAO(session).findByTransactionId(transactionId.toString());
    if (!infos.isEmpty()) {
      TransactionUserInfo info = infos.get(0);
      if (info.getEmail() != null && !info.getEmail().equals(user.getEmail())) {
        MailUtil.sendMail(config, info.getEmail(), email);
      }
    }

    MailUtil.sendMail(config, user.getEmail(), email);
  }

  private static void sendRobotItemBoughtMessage(
      Session session, User user, RobotSKU sku, Long transactionId) {
    Email email =
        MailUtil.getMail(
            user.isParent()
                ? MailUtil.ROBOT_ITEM_BOUGHT_FILE_PARENT
                : MailUtil.ROBOT_ITEM_BOUGHT_FILE_CHILD,
            user.getLocale());
    email.content = String.format(email.content, user.getLogin(), sku.getName());
    KavalokApplication.logger.info("UserUtil.sendMembershipBoughtMessage: " + email.content);

    Properties config = getMailServerConfig(session);
    List<TransactionUserInfo> infos =
        new TransactionUserInfoDAO(session).findByTransactionId("R" + transactionId);
    if (!infos.isEmpty()) {
      TransactionUserInfo info = infos.get(0);
      if (info.getEmail() != null && !info.getEmail().equals(user.getEmail())) {
        MailUtil.sendMail(config, info.getEmail(), email);
      }
    }
    MailUtil.sendMail(config, user.getEmail(), email);
  }

  private static void addBugsBonus(
      Session session, User user, Transaction trans, GameChar gameChar) {
    long moneyBonus = trans.getSku().getBugsBonus();

    GameCharDAO gameCharDAO = new GameCharDAO(session);
    Double money = gameChar.getMoney() + moneyBonus;
    gameChar.setMoney(money);
    gameCharDAO.makePersistent(gameChar);
    MoneyStatistics moneyStatistics =
        new MoneyStatistics(user, moneyBonus, new Date(), "Membership bonus");
    new MoneyStatisticsDAO(session).makePersistent(moneyStatistics);
  }

  private static void saveMembershipHistory(
      Session session,
      User user,
      Transaction transaction,
      Integer months,
      Integer days,
      String reason) {
    MembershipHistoryDAO hitoryDao = new MembershipHistoryDAO(session);
    MembershipHistory history = new MembershipHistory();
    history.setUser(user);
    if (transaction != null) {
      history.setTransaction(transaction);
      history.setReason(transaction.getSuccessMessage());
    } else if (reason != null) {
      history.setReason(reason);
    }
    if (months != null && months != 0) {
      history.setPeriodMonths(months.byteValue());
    } else if (days != null && days != 0) {
      history.setPeriodDays(days.byteValue());
    }
    history.setEndDate(user.getCitizenExpirationDate());
    history.setReason(reason);
    hitoryDao.makePersistent(history);
  }

  private static void sendRobotTypeCommand(Session session, User user, RobotItem ri) {
    ObjectMap<String, Object> command = new ObjectMap<String, Object>();
    command.put("itemId", ri.getId());
    command.put("className", "com.kavalok.messenger.commands::RobotItemBoughtMessage");
    Message msg = new Message(user.getGameCharIdentifier(), command);
    MessageDAO messageDAO = new MessageDAO(session);
    Long messId = messageDAO.makePersistent(msg).getId();
    command.put("id", messId);

    new RemoteClient(session, user).sendCommand(command);
  }

  private static void assignItemOfMonth(
      Session session, User user, GameChar gameChar, Transaction trans, Integer months) {
    StuffTypeDAO stDAO = new StuffTypeDAO(session);
    StuffType itemOfTheMonthType =
        stDAO.findByItemOfTheMonth(ITEM_OF_THE_MONTH_FORMAT.format(trans.getCreated()) + months);
    if (itemOfTheMonthType != null) {
      StuffItem itemOfTheMonth = new StuffItem();
      itemOfTheMonth.setType(itemOfTheMonthType);
      itemOfTheMonth.setUsed(false);
      itemOfTheMonth.setGameChar(gameChar);
      new StuffItemDAO(session).makePersistent(itemOfTheMonth);

      ObjectMap<String, Object> command = new ObjectMap<String, Object>();
      command.put("itemId", itemOfTheMonth.getId());
      command.put("className", "com.kavalok.messenger.commands::ItemOfTheMonthMessage");
      Message msg = new Message(gameChar, command);
      MessageDAO messageDAO = new MessageDAO(session);
      Long messId = messageDAO.makePersistent(msg).getId();
      command.put("id", messId);

      new RemoteClient(session, user).sendCommand(command);
    }
  }

  public static void addStuff(
      Session session, Integer userId, Integer stuffTypeId, Integer color, String reason) {
    UserDAO userDAO = new UserDAO(session);
    User user = userDAO.findById(userId.longValue());

    StuffTypeDAO stDAO = new StuffTypeDAO(session);
    StuffType type = stDAO.findById(stuffTypeId.longValue());
    if (type != null) {
      StuffItem item = new StuffItem();
      item.setType(type);
      item.setUsed(false);
      GameChar gameChar = user.getGameCharIdentifier();
      item.setGameChar(gameChar);
      item.setColor(color);
      new StuffItemDAO(session).makePersistent(item);

      ObjectMap<String, Object> command = new ObjectMap<String, Object>();
      command.put("itemId", item.getId());
      command.put("reason", reason);
      command.put("className", "com.kavalok.messenger.commands::AdminStuffItemMessage");
      Message msg = new Message(gameChar, command);
      MessageDAO messageDAO = new MessageDAO(session);
      Long messId = messageDAO.makePersistent(msg).getId();
      command.put("id", messId);

      new RemoteClient(session, user).sendCommand(command);
    }
  }

  public static void buyPayedStuff(Session session, Long userId, StuffType type) {
    User user = new UserDAO(session).findById(userId);
    GameChar gameChar = user.getGameCharIdentifier();

    StuffItemDAO stuffItemDAO = new StuffItemDAO(session);

    StuffItem item = new StuffItem(type);

    item.setGameChar(gameChar);
    stuffItemDAO.makePersistent(item);

    ObjectMap<String, Object> command = new ObjectMap<String, Object>();
    command.put("itemId", item.getId());
    command.put("className", "com.kavalok.messenger.commands::PaidStuffBoughtMessage");
    Message msg = new Message(gameChar, command);
    MessageDAO messageDAO = new MessageDAO(session);
    Long messId = messageDAO.makePersistent(msg).getId();
    command.put("id", messId);

    new RemoteClient(session, user).sendCommand(command);
  }

  public static void addCitizenship(
      Session session, Integer userId, Integer months, Integer days, String reason) {
    UserDAO userDAO = new UserDAO(session);
    User user = userDAO.findById(userId.longValue());

    Date now = new Date();
    Date citizenExpirationDate = user.getCitizenExpirationDate();
    boolean extend = citizenExpirationDate != null && citizenExpirationDate.after(now);

    GregorianCalendar gc = new GregorianCalendar();

    if (extend) {
      gc.setTime(citizenExpirationDate);
    } else {
      gc.setTime(now);
    }

    if (months != null && months != 0) {
      gc.add(GregorianCalendar.MONTH, months);
      user.setCitizenExpirationDate(gc.getTime());
    } else {
      gc.add(GregorianCalendar.DATE, days);
      user.setCitizenExpirationDate(gc.getTime());
    }

    user.setDrawEnabled(true);

    initMembershipInfo(session, user);

    userDAO.makePersistent(user);

    saveMembershipHistory(session, user, null, months, days, reason);
    sendCitizenshipCommand(session, user, extend, months, days, false, reason);
  }

  public static void deleteUser(Session session, Integer userId) {
    UserDAO userDAO = new UserDAO(session);
    User user = userDAO.findById(userId.longValue());
    user.setDeleted(true);
    userDAO.makePersistent(user);
  }

  public static void restoreUser(Session session, Integer userId) {
    UserDAO userDAO = new UserDAO(session);
    User user = userDAO.findById(userId.longValue());
    user.setDeleted(false);
    userDAO.makePersistent(user);
  }

  public static void buyRobotItem(Session session, RobotTransaction transaction) {
    RobotService rs = new RobotService();
    try {
      rs.beforeCall();
      RobotItem ri =
          rs.buyItem(transaction.getUser(), transaction.getRobotSKU().getRobotType(), 0, false);
      sendRobotTypeCommand(session, transaction.getUser(), ri);
      sendRobotItemBoughtMessage(
          session, transaction.getUser(), transaction.getRobotSKU(), transaction.getId());
      rs.afterCall();
    } catch (Exception e) {
      rs.afterError(e);
      logger.error("Error buyingRobotItem", e);
    }
  }

  public static void buyBugs(Session session, Long userId, StuffType type, Integer bugs) {
    User user = new UserDAO(session).findById(userId);
    GameCharDAO gameCharDAO = new GameCharDAO(session);
    GameChar gameChar = user.getGameChar();
    Double money = gameChar.getMoney() + bugs;
    gameChar.setMoney(money);
    gameCharDAO.makePersistent(gameChar);
    MoneyStatistics statistics =
        new MoneyStatistics(user, bugs.longValue(), new Date(), "bugs bought");
    new MoneyStatisticsDAO(session).makePersistent(statistics);

    ObjectMap<String, Object> command = new ObjectMap<String, Object>();
    command.put("bugs", bugs);
    command.put("className", "com.kavalok.messenger.commands::BugsBoughtMessage");
    Message msg = new Message(gameChar, command);
    MessageDAO messageDAO = new MessageDAO(session);
    Long messId = messageDAO.makePersistent(msg).getId();
    command.put("id", messId);

    new RemoteClient(session, user).sendCommand(command);
  }
}
