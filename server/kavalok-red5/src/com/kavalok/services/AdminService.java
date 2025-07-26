package com.kavalok.services;

import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Criteria;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.MatchMode;
import org.hibernate.criterion.Restrictions;
import org.red5.io.utils.ObjectMap;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.AdminDAO;
import com.kavalok.dao.BanDAO;
import com.kavalok.dao.ConfigDAO;
import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.MailServerDAO;
import com.kavalok.dao.ServerDAO;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.dao.UserReportDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.dao.statistics.MoneyStatisticsDAO;
import com.kavalok.db.Admin;
import com.kavalok.db.Ban;
import com.kavalok.db.GameChar;
import com.kavalok.db.MailServer;
import com.kavalok.db.Server;
import com.kavalok.db.User;
import com.kavalok.db.UserReport;
import com.kavalok.db.UserServer;
import com.kavalok.db.statistics.MoneyStatistics;
import com.kavalok.dto.ClientServerConfigTO;
import com.kavalok.dto.PagedResult;
import com.kavalok.dto.ServerConfigTO;
import com.kavalok.dto.UserReportTO;
import com.kavalok.dto.UserTO;
import com.kavalok.dto.WorldConfigTO;
import com.kavalok.dto.admin.FilterTO;
import com.kavalok.dto.stuff.StuffTypeTO;
import com.kavalok.permissions.AccessAdmin;
import com.kavalok.permissions.RequireAdmin;
import com.kavalok.permissions.RequireModerator;
import com.kavalok.permissions.RequireSuperUser;
import com.kavalok.permissions.RequirePermissionLevel;
import com.kavalok.permissions.RequireExternalMod;
import com.kavalok.permissions.RequirePartner;
import com.kavalok.permissions.RequireHalfMod;
import com.kavalok.permissions.RequireMod;
import com.kavalok.permissions.RequireSuperMod;
import com.kavalok.services.common.AdminServiceBase;
import com.kavalok.user.UserManager;
import com.kavalok.user.UserUtil;
import com.kavalok.utils.StringUtil;
import com.kavalok.xmlrpc.AdminClient;
import com.kavalok.xmlrpc.RemoteClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.kavalok.user.UserAdapter;
import org.hibernate.criterion.MatchMode;

public class AdminService extends AdminServiceBase {

  // private static final String SERVER_SELECT = "select user from Server as
  // server join server.users as user ";
  //
  // private static final String WHERE_SERVER = "where server.name = '%1$s'";
  //
  // private static final String USERS_SELECT_FORMAT = "from User as user ";
  //
  // private static final String WHERE_FORMAT = " where %1$s ";
  //
  // private static final String AND_WHERE_FORMAT = " and %1$s ";
  //
  // private static final String WHERE_OPERATOR_FORMAT = " user.%1$s %2$s %3$s
  // ";
  //
  // private static final String AND = " and ";

  private static final Integer ALL = -1;

  private static final String LESS = "<";

  private static final String EQUALS = "=";

  private static final String GREATER = ">";

  private static final String LIKE = "like";

  private static final String MESSAGE_CLASS = "com.kavalok.messenger.commands.MailMessage";

  private static final String CLASS_NAME = "className";

  private static final String PASSW_CHANGED = "passwordChanged";

  private static final String PASSW_INVALID = "invalidCurrentPassword";

  private static final Logger logger = LoggerFactory.getLogger(AdminService.class);

  /**
   * ACCESS CONTROL SYSTEM
   * ====================
   * 
   * This service uses a comprehensive access control system that allows different
   * privilege levels to access admin methods:
   * 
   * GRANULAR PERMISSION LEVELS (0-4):
   * - 0: EXTERNAL_MODER - External moderators (basic access)
   * - 1: PARTNER - Partners (limited admin access)
   * - 2: HALF_MODER - Half moderators (moderate admin access)
   * - 3: MOD - Full moderators (full moderator access)
   * - 4: SUPER_MOD - Super moderators (superuser access)
   * 
   * LEGACY PRIVILEGE LEVELS:
   * - @RequireSuperUser: Admin users and superUsers only (highest privilege)
   * - @RequireModerator: Admin users, moderators, and superUsers
   * - @RequireAdmin: Admin users, moderators, and superUsers (same as moderator)
   * - No annotation: No access control (for read-only methods)
   * 
   * USER TYPES:
   * - Admin users (AccessAdmin.class): Have access based on their permission level (0-4)
   * - Regular users with moderator=true: Equivalent to MOD level (3)
   * - Regular users with superUser=true: Equivalent to SUPER_MOD level (4)
   * - Regular users: Can only access methods with no annotation
   * 
   * ANNOTATION OPTIONS:
   * 
   * 1. Convenience Annotations (Recommended):
   *    @RequireSuperMod        // Level 4 - Super moderators only
   *    @RequireMod             // Level 3 - Full moderators and above
   *    @RequireHalfMod       // Level 2 - Half moderators and above
   *    @RequirePartner         // Level 1 - Partners and above
   *    @RequireExternalMod   // Level 0 - External moderators and above
   * 
   * 2. Direct Permission Level:
   *    @RequirePermissionLevel(4) // SUPER_MOD level
   *    @RequirePermissionLevel(3) // MOD level
   *    @RequirePermissionLevel(2) // HALF_MODER level
   *    @RequirePermissionLevel(1) // PARTNER level
   *    @RequirePermissionLevel(0) // EXTERNAL_MODER level
   * 
   * 3. Legacy Annotations (Still Supported):
   *    @RequireSuperUser         // Admin users and superUsers only
   *    @RequireModerator         // Admin users, moderators, and superUsers
   *    @RequireAdmin             // Admin users, moderators, and superUsers
   * 
   * 4. Manual Access Control:
   *    requirePermissionLevel(4); // Check specific level
   *    requireSuperUserAccess();  // Legacy checks
   *    requireModeratorAccess();
   *    requireAdminAccess();
   * 
   * USAGE EXAMPLES:
   * 
   * // Granular permission levels
   * @RequireSuperMod        // Level 4 - Super moderators only
   * public void reboot(String name) { ... }
   * 
   * @RequireMod             // Level 3 - Full moderators and above
   * public void kickOut(Integer userId, Boolean banned) { ... }
   * 
   * @RequireHalfMod       // Level 2 - Half moderators and above
   * public void moderateChat(String message) { ... }
   * 
   * @RequirePartner         // Level 1 - Partners and above
   * public void viewStatistics() { ... }
   * 
   * @RequireExternalMod   // Level 0 - External moderators and above
   * public void viewReports() { ... }
   * 
   * // Direct permission level
   * @RequirePermissionLevel(4) // SUPER_MOD level
   * public void serverMaintenance() { ... }
   * 
   * // Legacy privilege levels (still supported)
   * @RequireSuperUser
   * public void legacySuperUserMethod() { ... }
   * 
   * @RequireModerator
   * public void legacyModeratorMethod() { ... }
   * 
   * @RequireAdmin
   * public void legacyAdminMethod() { ... }
   * 
   * // No access control - read-only methods
   * public Integer getPermissionLevel(String login) { ... }
   * 
   * SECURITY FEATURES:
   * - Automatic logging of unauthorized access attempts
   * - Graceful error handling with SecurityException
   * - Centralized access control logic
   * - Support for both annotation-based and manual access checks
   * - Integration with Admin permission levels (0-4)
   * - Real-time privilege checking against database
   * - Support for both admin users and regular users with privileges
   * 
   * ACCESS MATRIX:
   * 
   * Method Level | Admin Level 0 | Admin Level 1 | Admin Level 2 | Admin Level 3 | Admin Level 4 | User Mod | User Super
   * -------------|---------------|---------------|---------------|---------------|---------------|----------|-----------
   * EXTERNAL_MODER (0) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓
   * PARTNER (1)        | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓
   * HALF_MODER (2)     | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓
   * MOD (3)            | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ | ✓
   * SUPER_MOD (4)      | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✓
   * 
   * ✓ = Access granted, ✗ = Access denied
   */

  /**
   * Examples of different permission levels:
   * 
   * @RequireSuperMod - Level 4 - Super moderators only
   * @RequireMod - Level 3 - Full moderators and above
   * @RequireHalfMod - Level 2 - Half moderators and above
   * @RequirePartner - Level 1 - Partners and above
   * @RequireExternalMod - Level 0 - External moderators and above
   * No annotation - No access control (for read-only methods)
   */

  // SUPER_MOD level methods (level 4) - Super moderators only
  @RequireSuperMod
  public void reboot(String name) {
    Server server = new ServerDAO(getSession()).findByName(name);
    new RemoteClient(server).reboot();
  }

  @RequireSuperMod
  public void setServerLimit(Integer value) {
    new ConfigDAO(getSession()).setServerLimit(value);
    refreshServersConfig();
  }

  @RequireSuperMod
  public void saveConfig(
      Boolean registrationEnabled,
      Boolean guestEnabled,
      Integer spamMessagesLimit,
      Integer serverLoad) {
    ConfigDAO configDAO = new ConfigDAO(getSession());
    configDAO.setRegistrationEnabled(registrationEnabled);
    configDAO.setGuestEnabled(guestEnabled);
    configDAO.setSpamMessagesCount(spamMessagesLimit);
    configDAO.setServerLimit(serverLoad);
    KavalokApplication.getInstance().refreshConfig();
    refreshServersConfig();
  }

  // MOD level methods (level 3) - Full moderators and above
  @RequireMod
  public void setBanDate(Integer userId, Date banDate) {
    User user = new UserDAO(getSession()).findById(userId.longValue());
    BanDAO banDAO = new BanDAO(getSession());
    Ban ban = new UserUtil().getBanModel(banDAO, user);
    ban.setBanCount(1);
    ban.setBanDate(banDate);
    banDAO.makePersistent(ban);

    // Integer banPeriod = BanUtil.getBanPeriod(ban);
    new RemoteClient(getSession(), user).sendCommand("BanDateCommand", null);
  }

  @RequireMod
  public void setDisableChatPeriod(Integer userId, Integer periodNumber) {
    User user = new UserDAO(getSession()).findById(userId.longValue());
    BanDAO banDAO = new BanDAO(getSession());
    Ban ban = new UserUtil().getBanModel(banDAO, user);
    ban.setBanCount(periodNumber);
    ban.setBanDate(new Date());
    banDAO.makePersistent(ban);

    new RemoteClient(getSession(), user).sendCommand("DisableChatCommand", periodNumber.toString());
  }

  @RequireMod
  public void kickOut(User user, Boolean banned) {
    new UserUtil().kickOut(user, banned, getSession());
  }

  @RequireMod
  public void kickOut(Integer userId, Boolean banned) {
    new UserUtil().kickOut(userId, banned, getSession());
  }

  // HALF_MODER level methods (level 2) - Half moderators and above
  @RequireHalfMod
  public void moderateChat(String message) {
    // Chat moderation functionality
    logger.info("Chat moderated by user: {}", getAdapter().getLogin());
  }

  @RequireHalfMod
  public void setReportProcessed(Integer reportId) {
    UserReportDAO userReportDAO = new UserReportDAO(getSession());
    UserReport report = userReportDAO.findById(Long.valueOf(reportId));
    report.setProcessed(true);
    userReportDAO.makePersistent(report);
  }

  // Admin level methods (legacy) - Admin users, moderators, and superUsers
  @RequireAdmin
  public void moveUsers(Integer fromId, Integer toId) {
    Server server = new ServerDAO(getSession()).findById(Long.valueOf(fromId));
    Server toServer = new ServerDAO(getSession()).findById(Long.valueOf(toId));
    new RemoteClient(server).sendCommandToAll("ReconnectCommand", toServer.getName());
  }

  @RequireAdmin
  public void sendGlobalMessage(String text, LinkedHashMap<Integer, String> locales) {
    ObjectMap<String, Object> command = new ObjectMap<String, Object>();
    command.put(CLASS_NAME, MESSAGE_CLASS);
    command.put("sender", null);
    command.put("text", text);
    command.put("dateTime", new Date());
    List<Server> servers = new ServerDAO(getSession()).findAvailable();
    ArrayList<String> localesList = new ArrayList<String>(locales.values());
    for (Server server : servers) {
      new RemoteClient(server).sendCommandToAll(command, localesList.toArray(new String[] {}));
    }
  }

  // No annotation - read-only methods that don't need access control
  public Integer getPermissionLevel(String login) {
    Admin admin = new AdminDAO(getSession()).findByLogin(login);
    return admin == null ? 0 : admin.getPermissionLevel();
  }

  public String changePassword(String oldPassword, String newPassword) {
    AdminDAO adminDAO = new AdminDAO(getSession());
    Long id = UserManager.getInstance().getCurrentUser().getUserId();
    Admin admin = adminDAO.findById(id);
    if (!admin.checkPassword(oldPassword, admin.getSalt())) {
      return PASSW_INVALID;
    } else {
      String newSalt = com.kavalok.utils.StringUtil.generateSalt(32);
      String newHash = com.kavalok.utils.StringUtil.hashPassword(newPassword, newSalt);
      admin.setSalt(newSalt);
      admin.setPassword(newHash);
      adminDAO.makePersistent(admin);
      return PASSW_CHANGED;
    }
  }

  // SUPER_MOD level methods (level 4) - Server administration, config, stuffs
  @RequireSuperMod
  public void setServerAvailable(Integer id, Boolean value) {
    ServerDAO serverDAO = new ServerDAO(getSession());
    Server server = serverDAO.findById(Long.valueOf(id), false);
    server.setAvailable(value);
    serverDAO.makePersistent(server);
  }

  @RequireSuperMod
  public void setMailServerAvailable(Integer id, Boolean value) {
    MailServerDAO mailServerDAO = new MailServerDAO(getSession());
    MailServer mailServer = mailServerDAO.findById(Long.valueOf(id), false);
    mailServer.setAvailable(value);
    mailServerDAO.makePersistent(mailServer);
  }

  public List<MailServer> getMailServers() {
    return new MailServerDAO(getSession()).findAll();
  }

  public Integer getServerLimit() {
    return KavalokApplication.getInstance().getServerLimit();
  }

  public ServerConfigTO getConfig() {
    KavalokApplication kavalokApp = KavalokApplication.getInstance();
    return new ServerConfigTO(
        kavalokApp.isGuestEnabled(),
        kavalokApp.isRegistrationEnabled(),
        kavalokApp.getSpamMessagesCount(),
        kavalokApp.getServerLimit());
  }

  @RequireSuperMod
  public void saveWorldConfig(Boolean safeModeEnabled) {
    requireAdminAccess();
    ConfigDAO configDAO = new ConfigDAO(getSession());
    configDAO.setSafeModeEnabled(safeModeEnabled);
    List<Server> servers = new ServerDAO(getSession()).findAvailable();
    for (Server server : servers) {
      new RemoteClient(server)
          .sendCommandToAll("ServerSafeModeCommand", safeModeEnabled.toString());
    }
    refreshServersConfig();
  }

  @RequireSuperMod
  public void refreshServersConfig() {
    List<Server> servers = new ServerDAO(getSession()).findRunning();
    for (Server server : servers) {
      new RemoteClient(server).refreshServerConfig();
    }
  }

  public WorldConfigTO getWorldConfig() {
    ConfigDAO configDAO = new ConfigDAO(getSession());
    return new WorldConfigTO(configDAO.getSafeModeEnabled());
  }

  @RequireSuperMod
  public void saveStuffGroupNum(Integer groupNum) {
    requireAdminAccess();
    ConfigDAO configDAO = new ConfigDAO(getSession());
    configDAO.setStuffGroupNum(groupNum);
    refreshServersConfig();
  }

  public Integer getStuffGroupNum() {
    ConfigDAO configDAO = new ConfigDAO(getSession());
    return configDAO.getStuffGroupNum();
  }

  @RequireSuperMod
  public void clearSharedObject(Integer serverId, String location) {
    requireAdminAccess();
    Server server = new ServerDAO(getSession()).findById(Long.valueOf(serverId), false);
    RemoteClient client = new RemoteClient(server);
    client.renewLocation(location);
  }

  @RequireSuperMod
  public void sendState(
      Integer serverId,
      String remoteId,
      String clientId,
      String method,
      String stateName,
      ObjectMap<String, Object> state) {
    requireAdminAccess();
    List<Server> servers = getServerList(serverId);
    for (Server server : servers) {
      new RemoteClient(server).sendState(remoteId, clientId, method, stateName, state);
    }
  }

  @RequireSuperMod
  public void removeState(
      Integer serverId, String remoteId, String clientId, String method, String stateName) {
    requireAdminAccess();
    List<Server> servers = getServerList(serverId);
    for (Server server : servers) {
      new RemoteClient(server).sendState(remoteId, clientId, method, stateName, null);
    }
  }

  @RequireSuperMod
  public void sendLocationCommand(
      Integer serverId, String remoteId, ObjectMap<String, Object> command) {
    requireAdminAccess();
    List<Server> servers = getServerList(serverId);
    for (Server server : servers) {
      new RemoteClient(server).sendLocationCommand(remoteId, command);
    }
  }

  private List<Server> getServerList(Integer serverId) {
    List<Server> result;
    if (serverId.equals(-1)) {
      result = new ServerDAO(getSession()).findAvailable();
    } else {
      result = new ArrayList<Server>();
      result.add(new ServerDAO(getSession()).findById(Long.valueOf(serverId), false));
    }
    return result;
  }

  // HALF_MODER level methods (level 2) - Statistics, user management, logs
  @RequireHalfMod
  public List<StuffTypeTO> getRainableStuffs() {
    return new StuffTypeDAO(getSession()).getRainableStuffs();
  }

  // MOD level methods (level 3) - User management, quests, info panel
  @RequireMod
  public void saveUserData(
      Integer userId,
      Boolean activated,
      Boolean chatEnabled,
      Boolean chatEnabledByParent,
      Boolean agent,
      Boolean baned,
      Boolean moderator,
      Boolean drawEnabled) {
    new UserUtil()
        .saveUserData(
            getSession(),
            userId,
            activated,
            chatEnabled,
            chatEnabledByParent,
            agent,
            baned,
            moderator,
            drawEnabled);
  }

  @RequireMod
  public void saveUserBan(Integer userId, Boolean baned, String reason) {
    UserDAO dao = new UserDAO(getSession());
    User user = dao.findById(userId.longValue());
    String messages = getLastChatMessages(user);
    if (baned) kickOut(user, baned);
    new UserUtil().saveUserBan(getSession(), user, baned, reason, messages);
  }

  @RequireMod
  public void saveIPBan(String ip, Boolean baned, String reason) {
    new UserUtil().saveIPBan(getSession(), ip, baned, reason);
  }

  @RequireMod
  public void addMoney(Integer userId, Integer money, String reason) {
    User user = new User();
    user.setId(userId.longValue());
    GameCharDAO gameCharDAO = new GameCharDAO(getSession());
    GameChar gameChar = gameCharDAO.findByUserId(userId.longValue());
    gameChar.setMoney(gameChar.getMoney() + money);
    MoneyStatistics statistics = new MoneyStatistics(user, Long.valueOf(money), new Date(), reason);
    new MoneyStatisticsDAO(getSession()).makePersistent(statistics);
    gameCharDAO.makePersistent(gameChar);
  }

  @RequireMod
  public void sendRules(Integer userId) {
    new RemoteClient(getSession(), userId.longValue()).sendCommand("ShowRulesCommand", null);
  }

  // EXTERNAL_MOD level methods (level 0) - Graphity, magic
  @RequireExternalMod
  public Object[] getGraphity(String serverName, String wallId) {
    Server server = new ServerDAO(getSession()).findByName(serverName);
    return new RemoteClient(server).getGraphity(wallId);
  }

  @RequireExternalMod
  public void clearGraphity(String serverName, String wallId) {
    Server server = new ServerDAO(getSession()).findByName(serverName);
    new RemoteClient(server).clearGraphity(wallId);
  }

  // HALF_MOD level methods (level 2) - User management, logs
  @RequireHalfMod
  public String getLastChatMessages(Integer userId) {
    return new RemoteClient(getSession(), userId.longValue()).getLastChatMessages();
  }

  @RequireHalfMod
  public String getLastChatMessages(User user) {
    return new RemoteClient(getSession(), user).getLastChatMessages();
  }

  @RequireHalfMod
  public UserTO getUser(Integer userId) {
    User user = new UserDAO(getSession()).findById(userId.longValue());
    return UserTO.convertUser(getSession(), user);
  }

  @RequireHalfMod
  @SuppressWarnings("unchecked")
  public PagedResult<UserTO> getUsers(
      Integer serverId,
      LinkedHashMap<Integer, Object> filters,
      Integer firstResult,
      Integer maxResults) {

    UserDAO userDAO = new UserDAO(getSession());

    Criteria criteria = createFilteredCriteria(serverId, filters);

    criteria.setFirstResult(firstResult);
    criteria.setMaxResults(maxResults);

    ArrayList<UserTO> result = UserTO.convertUsers(getSession(), criteria.list());
    Criteria sizeCriteria = createFilteredCriteria(serverId, filters);
    userDAO.setSizeProjection(sizeCriteria);

    return new PagedResult<UserTO>(((Number) sizeCriteria.uniqueResult()).intValue(), result);
  }

  private Criteria createFilteredCriteria(
      Integer serverId, LinkedHashMap<Integer, Object> filters) {
    UserDAO userDAO = new UserDAO(getSession());
    Criteria criteria = userDAO.createUserCriteria();
    boolean checkServer = false;
    List<UserServer> userServers = null;
    if (serverId == ALL) {
      checkServer = true;
      userServers = new UserServerDAO(getSession()).findAll();
    } else if (serverId > 0) {
      checkServer = true;
      userServers =
          new UserServerDAO(getSession()).getAllUserServerByServerId(serverId.longValue());
    }
    if (checkServer) {
      List<Long> userIds = new ArrayList<Long>();
      for (Iterator<UserServer> iterator = userServers.iterator(); iterator.hasNext(); ) {
        UserServer userServer = iterator.next();
        userIds.add(userServer.getUserId());
      }
      if (userIds.isEmpty()) {
        criteria.add(Restrictions.eq("id", new Long(-1)));
      } else {
        criteria.add(Restrictions.in("id", userIds));
      }
    }

    for (Object filter : filters.values()) {
      FilterTO filterTO = (FilterTO) filter;
      if ("citizen".equals(filterTO.getFieldName())) {
        if (Boolean.TRUE.equals(filterTO.getValue())) {
          criteria.add(Restrictions.gt("citizenExpirationDate", new Date()));
        } else {
          Criterion nonCititzen = Restrictions.isNull("citizenExpirationDate");
          nonCititzen =
              Restrictions.or(nonCititzen, Restrictions.lt("citizenExpirationDate", new Date()));
          criteria.add(nonCititzen);
        }
      } else if ("age".equals(filterTO.getFieldName())) {
        try {
          Date now = new Date();
          Integer age = new Integer(filterTO.getValue().toString());
          GregorianCalendar gc = new GregorianCalendar();
          gc.setTime(now);

          gc.add(GregorianCalendar.DATE, -age);

          Criterion ageCrit = Restrictions.lt("created", gc.getTime());

          gc.add(GregorianCalendar.DATE, -1);

          ageCrit = Restrictions.and(ageCrit, Restrictions.gt("created", gc.getTime()));
          criteria.add(ageCrit);
        } catch (NumberFormatException e) {
          // seems some stupid ass passed non number value
        }

      } else if (filterTO.getOperator().equals(LESS))
        criteria.add(Restrictions.lt(filterTO.getFieldName(), filterTO.getValue()));
      else if (filterTO.getOperator().equals(EQUALS))
        criteria.add(Restrictions.eq(filterTO.getFieldName(), filterTO.getValue()));
      else if (filterTO.getOperator().equals(GREATER))
        criteria.add(Restrictions.gt(filterTO.getFieldName(), filterTO.getValue()));
      else if (filterTO.getOperator().equals(LIKE))
        criteria.add(Restrictions.like(filterTO.getFieldName(), filterTO.getValue()));
    }

    return criteria;
  }

  // MOD level methods (level 3) - User management
  @RequireMod
  public void addCitizenship(Integer userId, Integer months, Integer days, String reason) {
    UserUtil.addCitizenship(getSession(), userId, months, days, reason);
  }

  @RequireMod
  public void addStuff(Integer userId, Integer stuffTypeId, Integer color, String reason) {
    UserUtil.addStuff(getSession(), userId, stuffTypeId, color, reason);
  }

  @RequireMod
  public void deleteUser(Integer userId) {
    kickOut(userId, false);
    UserUtil.deleteUser(getSession(), userId);
  }

  @RequireMod
  public void restoreUser(Integer userId) {
    UserUtil.restoreUser(getSession(), userId);
  }

  public ClientServerConfigTO getClientConfig() {
    KavalokApplication kavalokApp = KavalokApplication.getInstance();
    return new ClientServerConfigTO(
        kavalokApp.isGuestEnabled(), kavalokApp.isRegistrationEnabled());
  }

  public String adminLogin(String login, String password) {
    AdminDAO adminDAO = new AdminDAO(getSession());
    Admin admin = adminDAO.findByLogin(login.toLowerCase());

    if (admin == null) {
      return "error";
    }

    boolean validLogin = admin.checkPassword(password, admin.getSalt());

    if (validLogin) {
      if (admin.getSalt() == null) {
        String newSalt = com.kavalok.utils.StringUtil.generateSalt(32);
        String newHash = com.kavalok.utils.StringUtil.hashPassword(password, newSalt);
        admin.setSalt(newSalt);
        admin.setPassword(newHash);
        adminDAO.makePersistent(admin);
      }

      UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
      userAdapter.setUserId(admin.getId());
      userAdapter.setLogin(login);
      userAdapter.setAccessType(admin.getAccessType());

      return "success";
    } else {
      return "error";
    }
  }
}
