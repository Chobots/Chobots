package com.kavalok.services;

import java.lang.reflect.InvocationTargetException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.red5.io.utils.ObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.BanDAO;
import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.MembershipInfoDAO;
import com.kavalok.dao.MessageDAO;
import com.kavalok.dao.PetDAO;
import com.kavalok.dao.QueriesNames;
import com.kavalok.dao.QuestDAO;
import com.kavalok.dao.RobotDAO;
import com.kavalok.dao.StuffItemDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.dao.UserDanceDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.dao.statistics.LoginStatisticsDAO;
import com.kavalok.db.Ban;
import com.kavalok.db.GameChar;
import com.kavalok.db.MembershipInfo;
import com.kavalok.db.Message;
import com.kavalok.db.Pet;
import com.kavalok.db.Server;
import com.kavalok.db.StuffItem;
import com.kavalok.db.User;
import com.kavalok.db.UserDance;
import com.kavalok.db.UserServer;
import com.kavalok.dto.CharTO;
import com.kavalok.dto.CharTOCache;
import com.kavalok.dto.GameEnterTO;
import com.kavalok.dto.KeysTO;
import com.kavalok.dto.MoneyReportTO;
import com.kavalok.dto.friend.FriendTO;
import com.kavalok.dto.home.CharHomeTO;
import com.kavalok.dto.pet.PetTO;
import com.kavalok.dto.stuff.StuffItemLightTO;
import com.kavalok.dto.stuff.StuffTypeTO;
import com.kavalok.messages.ServersCache;
import com.kavalok.robots.RobotUtil;
import com.kavalok.services.common.DataServiceBase;
import com.kavalok.services.stuff.StuffTypes;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.user.UserUtil;
import com.kavalok.utils.DateUtil;
import com.kavalok.utils.ReflectUtil;

public class CharService extends DataServiceBase {

  private static final String GIFT_CLASS_NAME = "com.kavalok.messenger.commands::GiftMessage";

  private static final int DANCES_COUNT = 3;

  private static final Logger logger = LoggerFactory.getLogger(CharService.class);

  private static Object friendSynchronizer = new Object();

  public int getLastOnlineDay(Integer userId) {
    User user = new UserDAO(getSession()).findById(userId.longValue());
    if (user == null) {
      return 10000;
    }
    Date lastDate = new LoginStatisticsDAO(getSession()).getLastOnlineDate(user);
    if (lastDate == null) {
      return 10000;
    }
    int day = (int) (new Date().getTime() - lastDate.getTime()) / 1000 / 3600 / 24;

    return day;
  }

  public void saveSettings(
      Integer musicVolume,
      Integer soundVolume,
      Boolean acceptRequests,
      Boolean showTips,
      Boolean showCharNames) {

    UserDAO userDAO = new UserDAO(getSession());
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (!userAdapter.getPersistent()) {
      return;
    }

    User user = userDAO.findById(userAdapter.getUserId());
    user.setMusicVolume(musicVolume);
    user.setSoundVolume(soundVolume);
    user.setAcceptRequests(acceptRequests);
    user.setShowTips(showTips);
    userDAO.makePersistent(user);
    GameChar gameChar = user.getGameChar();
    gameChar.setShowCharNames(showCharNames);
    new GameCharDAO(getSession()).makePersistent(gameChar);
  }

  public MoneyReportTO getMoneyReport() {
    GameChar gameChar = new GameCharDAO(getSession()).findByUserId(getAdapter().getUserId());
    return new MoneyReportTO(
        gameChar.getTotalMoneyEarned(),
        gameChar.getTotalMoneyEarnedByInvites(),
        gameChar.getTotalBonusMoney());
  }

  public void setLocale(String locale) {
    UserDAO userDAO = new UserDAO(getSession());
    User user = userDAO.findById(getAdapter().getUserId());
    user.setLocale(locale);
    userDAO.makePersistent(user);
  }

  public PetTO getPet(GameChar gameChar) {

    Pet pet = new PetDAO(getSession()).findByChar(gameChar);

    if (pet != null && pet.isEnabled()) {
      return new PetTO(pet);
    } else {
      return null;
    }
  }

  @SuppressWarnings("unchecked")
  public CharHomeTO getCharHome(Integer userId)
      throws IllegalAccessException, InvocationTargetException {
    CharHomeTO homeTO = new CharHomeTO();
    StuffItemDAO stuffItemDAO = new StuffItemDAO(getSession());
    User user = new UserDAO(getSession()).findById(userId.longValue());
    homeTO.setCitizen(user.isCitizen());
    GameChar gameCharIdent = user.getGameCharIdentifier();
    List<StuffItem> items =
        stuffItemDAO.findByTypes(gameCharIdent, new String[] {StuffTypes.HOUSE}, false);
    for (StuffItem item : items) {
      StuffTypeTO stuffTypeTO = new StuffTypeTO();
      BeanUtils.copyProperties(stuffTypeTO, item.getType());
      homeTO.getItems().add(stuffTypeTO);
    }
    List<StuffItem> furnitureItems =
        stuffItemDAO.findByTypes(gameCharIdent, new String[] {StuffTypes.FURNITURE}, false);
    boolean citizen =
        user.getCitizenExpirationDate() != null
            && user.getCitizenExpirationDate().after(new Date());
    if (!citizen) {
      for (Iterator iterator = furnitureItems.iterator(); iterator.hasNext(); ) {
        StuffItem stuffItem = (StuffItem) iterator.next();
        if (stuffItem.isUsed() && stuffItem.getLevel() != null && stuffItem.getLevel() > 0) {
          stuffItem.setUsed(false);
          stuffItemDAO.makePersistent(stuffItem);
        }
      }
    }
    List<StuffItemLightTO> furnitureTos =
        ReflectUtil.convertBeansByConstructorStuffItemLightTO(furnitureItems);
    homeTO.setFurniture(furnitureTos);
    homeTO.setRobotExists(new RobotDAO(getSession()).robotExists(user));
    return homeTO;
  }

  @SuppressWarnings("unchecked")
  public Double getSessionTime(Integer userId, Date minDate, Date maxDate) {

    UserDAO userDAO = new UserDAO(getSession());
    User user = userDAO.findById(userId.longValue());

    Query query = getSession().getNamedQuery(QueriesNames.LOGIN_STATISTICS_SESSION_TIME);

    query.setParameter("user", user);
    query.setParameter("minDate", minDate);
    query.setParameter("maxDate", maxDate);

    // ArrayList<Object> list = (ArrayList<Object>) query.list();
    List list = query.list();

    return (list.size() == 1) ? (Long) list.get(0) : 0.00;
  }

  public void setUserInfo(
      Integer userId, Boolean enabled, Boolean chatEnabledByParent, Boolean isParent) {

    UserDAO userDAO = new UserDAO(getSession());
    User user = userDAO.findById(userId.longValue());
    user.setEnabled(enabled);
    user.setChatEnabled(chatEnabledByParent);
    user.setParent(isParent);
    userDAO.makePersistent(user);
  }

  public ArrayList<String> removeCharFriends(LinkedHashMap<Integer, Integer> removedFriends)
      throws HibernateException, SQLException {

    UserDAO userDAO = new UserDAO(getSession());

    for (Integer friendId : removedFriends.values()) {

      userDAO.removeFriendship(
          UserManager.getInstance().getCurrentUser().getUserId(), friendId.longValue());
    }

    return getCharFriends(null, false);
  }

  public ArrayList<String> removeIgnoreChar(Integer ignoreId) {

    GameCharDAO charDAO = new GameCharDAO(getSession());
    GameChar friend = charDAO.findByUserId(ignoreId.longValue());
    GameChar gameChar = getGameChar();

    if (gameChar.getIgnoreList().contains(friend)) {
      gameChar.getIgnoreList().remove(friend);
      charDAO.makePersistent(gameChar);
    }
    return getIgnoreList();
  }

  public Double getCharMoney() {
    GameChar gameChar = getGameChar();
    return gameChar.getMoney();
  }

  public ArrayList<String> getCharFriends() {
    User user = getUser();
    return getCharFriends(user, true);
  }

  public ArrayList<String> getCharFriends(User us, boolean setCity) {

    ArrayList<FriendTO> result = new ArrayList<FriendTO>();

    long start = System.currentTimeMillis();
    User user = us;
    if (user == null) {
      user = getUser();
    }
    List<User> userFriends = user.getFriends();

    for (User friendUser : userFriends) {
      if (friendUser == null) {
        logger.error("Invalid char in friends charId: " + user.getId());
        continue;
      }

      FriendTO friend = new FriendTO();
      friend.setUserId(friendUser.getId().intValue());
      friend.setLogin(friendUser.getLogin());
      result.add(friend);
    }
    logger.debug("Select friends time: {}", (System.currentTimeMillis() - start));

    if (setCity) {

      start = System.currentTimeMillis();
      List<Long> userIds = new ArrayList<Long>();
      for (User member : userFriends) {
        userIds.add(member.getId());
      }
      if (!userIds.isEmpty()) {

        List<UserServer> userServers =
            new UserServerDAO(getSession()).getUserServerByUserIds(userIds.toArray());
        for (FriendTO friend : result) {
          for (Iterator<UserServer> iterator = userServers.iterator(); iterator.hasNext(); ) {
            UserServer userServer = iterator.next();
            if (userServer.getUserId().intValue() == friend.getUserId()) {
              friend.setServer(ServersCache.getInstance().getServerName(userServer));
              userServers.remove(userServer);
              break;
            }
          }
        }
      }
    }

    ArrayList<String> res = new ArrayList<String>();
    for (int i = 0; i < result.size(); i++) {
      FriendTO friend = result.get(i);
      res.add(friend.toStringPresentation());
    }

    logger.debug("Select friends servers time: {}", (System.currentTimeMillis() - start));
    return res;
  }

  public ArrayList<String> getIgnoreList() {

    GameChar gameChar = getGameChar();
    ArrayList<String> result = new ArrayList<String>();

    for (GameChar friend : gameChar.getIgnoreList()) {
      result.add(friend.getLogin());
    }

    return result;
  }

  public ArrayList<String> setCharFriend(Integer friendId) {

    UserDAO userDAO = new UserDAO(getSession());
    User friend = new UserDAO(getSession()).findById(friendId.longValue());
    User user = getUser();
    ArrayList<String> result;

    synchronized (friendSynchronizer) {
      if (!user.getFriends().contains(friend)) {
        user.getFriends().add(friend);
        userDAO.makePersistent(user);
      }

      if (!friend.getFriends().contains(user)) {
        friend.getFriends().add(user);
        userDAO.makePersistent(friend);
      }

      result = getCharFriends(user, false);
      afterCall();
    }

    return result;
  }

  public ArrayList<String> setIgnoreChar(Integer ignorChardUserId) {

    GameCharDAO charDAO = new GameCharDAO(getSession());
    GameChar friend = charDAO.findByUserId(ignorChardUserId.longValue());
    GameChar gameChar = getGameChar();

    if (!gameChar.getIgnoreList().contains(friend)) {
      gameChar.getIgnoreList().add(friend);
      charDAO.makePersistent(gameChar);
    }
    return getIgnoreList();
  }

  @SuppressWarnings("unchecked")
  private List<StuffItemLightTO> getCharStuffs(List<StuffItem> items) {
    return ReflectUtil.convertBeansByConstructorStuffItemLightTO(items);
  }

  @SuppressWarnings("unchecked")
  public List<String> getCharStuffs() {
    List<String> result = new ArrayList<String>();
    List<StuffItemLightTO> items =
        ReflectUtil.convertBeansByConstructorStuffItemLightTO(
            getCharClothesAndStuffs(null, null, false, false));
    // UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    // userAdapter.loadCharStuffs(items);
    for (Iterator iterator = items.iterator(); iterator.hasNext(); ) {
      StuffItemLightTO stuffItemLightTO = (StuffItemLightTO) iterator.next();
      result.add(stuffItemLightTO.toString());
    }
    return result;
  }

  private List<StuffItem> getCharClothesAndStuffs(
      User us, GameChar gc, boolean disableCitizens, boolean selectUsedOnly) {

    User user = us;
    if (user == null) {
      UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
      user = new UserDAO(getSession()).findById(userAdapter.getUserId());
    }

    GameChar gameChar = gc;
    if (gameChar == null) {
      gameChar = user.getGameCharIdentifier();
    }

    CharTOCache.getInstance().removeCharTO(user.getId());
    CharTOCache.getInstance().removeCharTO(user.getLogin());
    StuffItemDAO itemDAO = new StuffItemDAO(getSession());
    long now = System.currentTimeMillis();
    List<StuffItem> items =
        itemDAO.findByTypes(
            gameChar,
            new String[] {
              StuffTypes.CLOTHES,
              StuffTypes.STUFF,
              StuffTypes.COCKTAIL,
              StuffTypes.PET_ITEMS,
              StuffTypes.PLAYERCARD
            },
            selectUsedOnly);
    logger.debug("itemDAO.findByTypes time: {}", (System.currentTimeMillis() - now));

    if (disableCitizens) {
      now = System.currentTimeMillis();
      for (StuffItem item : items) {
        if (item.isUsed() && item.getType().getPremium()) {
          item.setUsed(false);
          itemDAO.makePersistent(item);
        }
      }
      logger.debug("disableCitizens clothes time: {}", (System.currentTimeMillis() - now));
    }
    return items;
  }

  public CharTO getCharView(Integer userId) {
    CharTO result = CharTOCache.getInstance().getCharTO(userId.longValue());
    if (result != null) {
      return result;
    }

    User user = new UserDAO(getSession()).findById(userId.longValue(), false);

    if (user == null) return null;
    else return getUserInfo(user);
  }

  public CharTO getCharViewLogin(String charName) {
    CharTO result = CharTOCache.getInstance().getCharTO(charName);
    if (result != null) {
      return result;
    }

    User user = new UserDAO(getSession()).findByLogin(charName, false);

    if (user == null) return null;
    else return getUserInfo(user, false, true);
  }

  public List<CharTO> getFamilyInfo() {

    Long userId = UserManager.getInstance().getCurrentUser().getUserId();
    UserDAO userDAO = new UserDAO(getSession());
    String email = userDAO.findById(userId).getEmail();
    List<User> users = userDAO.findByEmail(email, true);

    List<CharTO> items = new ArrayList<CharTO>();

    for (User user : users) {
      if (!user.getGuest()) items.add(getUserInfo(user));
    }

    return items;
  }

  private static final Map<Long, String> STUFFTYPES_TYPES_CACHE = new HashMap<Long, String>();

  private CharTO getUserInfo(User user) {
    return getUserInfo(user, true, false);
  }

  private CharTO getUserInfo(
      User user, boolean checkCurrentUserCache, boolean setCurrentUserLogin) {
    GameChar gameChar = user.getGameChar();

    BanDAO banDAO = new BanDAO(getSession());
    Ban ban = banDAO.findByUser(user);
    if (ban == null) {
      ban = new Ban();
    }

    Server server = new UserServerDAO(getSession()).getServer(user);

    CharTO result = new CharTO();

    Long age = UserUtil.getAge(user);

    result.setUserId(user.getId().intValue());
    result.setId(user.getLogin());
    result.setBody(gameChar.getBody());
    result.setColor(gameChar.getColor());
    result.setChatEnabled(ban.isChatEnabled());
    result.setChatEnabledByParent(user.isChatEnabled());
    result.setChatBanLeftTime(BanUtil.getBanLeftTime(ban).intValue());
    result.setEnabled(user.isEnabled());
    result.setParent(user.isParent());
    result.setCitizen(
        user.getCitizenExpirationDate() != null
            && user.getCitizenExpirationDate().after(new Date()));
    result.setGuest(user.getGuest() || !user.isActive());
    result.setAgent(user.isAgent());
    result.setModerator(user.isModerator());
    result.setOnline(server != null);
    result.setLocale(user.getLocale());
    result.setAge(age.intValue());
    result.setAcceptRequests(user.getAcceptRequests());
    result.setHasRobot(new RobotDAO(getSession()).robotExists(user));
    if (user.getRobotTeam() != null) {
      result.setTeamName(user.getRobotTeam().getUserLogin());
      result.setTeamColor(user.getRobotTeam().getColor());
    }

    if (gameChar.getPlayerCard() != null)
      result.setPlayerCard(new StuffItemLightTO(gameChar.getPlayerCard()));

    if (server != null) result.setServer(server.getName());

    ArrayList<StuffItemLightTO> clothes = new ArrayList<StuffItemLightTO>();

    for (StuffItem item : gameChar.getStuffItems()) {
      if (item.isUsed()) {
        String type = STUFFTYPES_TYPES_CACHE.get(item.getType_id());
        if (type == null) {
          type = item.getType().getType();
          STUFFTYPES_TYPES_CACHE.put(item.getType_id(), type);
        }

        if (StuffTypes.CLOTHES.equals(type)) {
          clothes.add(new StuffItemLightTO(item));
        }
      }
    }

    result.setClothes(clothes);
    result.setLogin(user.getLogin());

    if (!checkCurrentUserCache) {
        return result;
    }

    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (setCurrentUserLogin) {
      userAdapter.setLogin(user.getLogin());
      userAdapter.setUserId(user.getId());
    }
    Long currentServerId = null;
    if (userAdapter != null && userAdapter.getServer() != null) {
      currentServerId = userAdapter.getServer().getId();
    }
    String currentUserLogin = userAdapter.getLogin();
    boolean cacheUser = true;
    if (!user.getLogin().equals(currentUserLogin)) {
      if (server == null) cacheUser = false;
      else if (!server.getId().equals(currentServerId)) cacheUser = false;
    }
    if (cacheUser) {
      CharTOCache.getInstance().putCharTO(result);
    }
    return result;
  }

  public void saveCharStuffs(LinkedHashMap<Integer, ObjectMap<String, Object>> clothes) {
    for (StuffItem item : getCharClothesAndStuffs(null, null, false, false)) {

      for (ObjectMap<String, Object> clothe : clothes.values()) {
        Long id = Long.valueOf((Integer) clothe.get("id"));
        if (id.equals(item.getId())) {
          item.setUsed((Boolean) clothe.get("used"));
          item.setX((Integer) clothe.get("x"));
          item.setY((Integer) clothe.get("y"));

          break;
        }
      }
    }
  }

  private User getUser() {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    return new UserDAO(getSession()).findById(userAdapter.getUserId());
  }

  private GameChar getGameChar() {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    User user = new UserDAO(getSession()).findById(userAdapter.getUserId());

    return user.getGameChar();
  }

  public void saveCharBody(String body, Integer color) {
    GameChar gameChar = getGameChar();
    gameChar.setBody(body);
    gameChar.setColor(color);
    new GameCharDAO(getSession()).makePersistent(gameChar);
  }

  public void savePlayerCard(Integer stuffId) {
    StuffItem stuff = null;
    if (stuffId >= 0) {
      StuffItemDAO stuffDAO = new StuffItemDAO(getSession());
      stuff = stuffDAO.findById(new Long(stuffId));
    }
    GameChar gameChar = getGameChar();
    gameChar.setPlayerCard(stuff);
    new GameCharDAO(getSession()).makePersistent(gameChar);
  }

  @SuppressWarnings("unchecked")
  private List<ObjectMap<String, Object>> getOfflineCommands(GameChar gameChar) {
    long now = System.currentTimeMillis();
    MessageDAO messageDAO = new MessageDAO(getSession());

    List<Message> messageList = messageDAO.getMessages(gameChar);
    List<ObjectMap<String, Object>> messages = new ArrayList<ObjectMap<String, Object>>();

    for (Message msg : messageList) {
      ObjectMap<String, Object> command = (ObjectMap<String, Object>) msg.getCommand();
      if (!command.get("className").equals(GIFT_CLASS_NAME)) {
        command.put("id", msg.getId());
        messages.add(command);
      } else {
        new MessageDAO(getSession()).makeTransient(msg);
      }
    }
    logger.debug("getOfflineCommands time: {}", (System.currentTimeMillis() - now));

    return messages;
  }

  public void saveDance(String value, Integer index) {
    UserDAO userDAO = new UserDAO(getSession());
    User user = userDAO.findById(getAdapter().getUserId());
    UserDanceDAO userDanceDAO = new UserDanceDAO(getSession());
    List<UserDance> list = user.getDances();
    if (list.size() == 0) {
      for (int i = 0; i < DANCES_COUNT; i++) {
        UserDance dance = new UserDance("");
        list.add(dance);
        userDanceDAO.makePersistent(dance);
      }
    }
    UserDance dance = list.get(index);
    dance.setDance(value);
    userDanceDAO.makePersistent(dance);
  }

  public Integer makePresent(Integer userId, Integer stuffId) {
    if (1 == 1) return stuffId;
    StuffItemDAO itemDAO = new StuffItemDAO(getSession());
    StuffItem item = itemDAO.findById(stuffId.longValue(), false);

    item.resetOwner();
    GameChar friend =
        new UserDAO(getSession()).findById(userId.longValue()).getGameCharIdentifier();
    item.setGameChar(friend);
    itemDAO.makePersistent(item);

    return stuffId;
  }

  public KeysTO gK /* getKey */() {
    return new KeysTO(getAdapter().newSecurityKey(), MessageService.KEY);
  }

  public GameEnterTO enterGame(Object charName) {
    return null;
  }

  public GameEnterTO enterGame(String charName) {
    long nowTot = System.currentTimeMillis();

    long start = System.currentTimeMillis();

    UserAdapter userAdapter = getAdapter();
    userAdapter.enterGame();

    long finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    GameEnterTO result = new GameEnterTO();
    result.setSecurityKey(userAdapter.newSecurityKey());
    populateStaticData(result);

    if (!userAdapter.getPersistent()) {
        return result;
    }

    result.setIsGuest(false);
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    UserDAO userDAO = new UserDAO(getSession());
    User user = userDAO.findByLogin(charName.toLowerCase());
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    GameCharDAO charDAO = new GameCharDAO(getSession());
    GameChar gameChar = user.getGameChar();
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    BanDAO banDAO = new BanDAO(getSession());
    Ban ban = banDAO.findByUser(user);
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    if (ban == null) {
      ban = new Ban();
    }
    List<StuffItem> charClothesAndStuffs =
        getCharClothesAndStuffs(user, gameChar, !user.isCitizen(), false);

    List<StuffItem> usedCharClothesAndStuffs = new ArrayList<StuffItem>();
    // getting only used stuffs to optimize traffic
    for (Iterator<StuffItem> iterator = charClothesAndStuffs.iterator(); iterator.hasNext(); ) {
      StuffItem stuffItem = iterator.next();
      if (stuffItem.isUsed()) {
        usedCharClothesAndStuffs.add(stuffItem);
      }
    }

    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    MembershipInfo mi = user.getMembershipInfo();
    finish = System.currentTimeMillis();
    start = System.currentTimeMillis();
    if (mi == null) {
      mi = new MembershipInfo();
    }

    boolean saveMemberShipInfo = false;

    result.setFinishedNotification(false);
    result.setFinishingNotification(false);

    Date citizenshipExpiration = user.getCitizenExpirationDate();
    if (citizenshipExpiration != null) {
      if (!mi.getFinishedNotificationShowed() && citizenshipExpiration.before(new Date())) {
        result.setFinishedNotification(true);
        mi.setFinishedNotificationShowed(true);
        saveMemberShipInfo = true;
      } else if (!mi.getFinishedNotificationShowed()
          && !mi.getFinishingNotificationShowed()
          && DateUtil.daysDiff(citizenshipExpiration, new Date()) < 7) {
        mi.setFinishingNotificationShowed(true);
        result.setFinishingNotification(true);
        saveMemberShipInfo = true;
      }
    }
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    if (saveMemberShipInfo) {
      mi = (new MembershipInfoDAO(getSession())).makePersistent(mi);
      user.setMembershipInfo(mi);
      userDAO.makePersistent(user);
    }
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    result.setServerInSafeMode(KavalokApplication.getInstance().isSafeModeEnabled());
    result.setNonCitizenChatDisabled(false);
    result.setChatEnabled(ban.isChatEnabled());
    result.setChatBanLeftTime(BanUtil.getBanLeftTime(ban));
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    result.setFirstLogin(gameChar.getFirstLogin());
    result.setBody(gameChar.getBody());
    result.setColor(gameChar.getColor());
    result.setMoney(gameChar.getMoney());
    List<StuffItemLightTO> charStuffs = getCharStuffs(usedCharClothesAndStuffs);
    result.setStuffs(charStuffs);
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    result.setFriends(getCharFriends(user, false));
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    result.setIgnoreList(getIgnoreList());
    result.setCommands(getOfflineCommands(gameChar));
    result.setPet(getPet(gameChar));
    result.setQuests(getQuests());
    populateFromUser(result, user, gameChar);
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    result.setRobot(RobotUtil.getCharRobot(getSession(), user.getId().intValue()));
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    result.setRobotTeam(getRobotTeam(user));
    if (user.getRobotTeam() != null) {
      result.setTeamColor(user.getRobotTeam().getColor());
    }
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    StuffItem playerCard = gameChar.getPlayerCard();
    if (playerCard != null) {
      if (!user.isCitizen() && Boolean.TRUE.equals(playerCard.getType().getPremium())) {
        gameChar.setPlayerCard(null);
      } else {
        result.setPlayerCard(new StuffItemLightTO(playerCard));
      }
    }
    finish = System.currentTimeMillis();

    start = System.currentTimeMillis();
    // new AdminClient(getSession()).logUserEnter(user.getLogin(),
    // gameChar.getFirstLogin());
    gameChar.setFirstLogin(false);
    charDAO.makePersistent(gameChar);
    finish = System.currentTimeMillis();

    if (user.isCitizen()) {
      // TODO enabling timer to disable citizen features;
    }
    nowTot = (System.currentTimeMillis() - nowTot);

    userAdapter.loadCharStuffs(getCharStuffs(charClothesAndStuffs));
    result.setAge(UserUtil.getAge(user));
    return result;
  }

  private void populateStaticData(GameEnterTO result) {
    result.setChatSecurityKey(MessageService.KEY);
    result.setServerTime(new Date());
    result.setColor((int) (Math.random() * 0xFFFFFF));
    result.setIsGuest(true);
    result.setFirstLogin(true);
    result.setHelpEnabled(false);
    result.setShowTips(false);
  }

  private void populateFromUser(GameEnterTO result, User user, GameChar gameChar) {
    result.setHelpEnabled(user.isHelpEnabled());
    result.setNotActivated(!user.isActive());
    result.setChatEnabledByParent(user.isChatEnabled());
    result.setIsGuest(user.getGuest());
    result.setEmail(user.getEmail());
    result.setIsAgent(user.isAgent());
    result.setIsCitizen(user.isCitizen());
    result.setCitizenExpirationDate(user.getCitizenExpirationDate());
    result.setCitizenTryCount(user.getCitizenTryCount());
    result.setIsModerator(user.isModerator());
    result.setIsParent(user.isParent());
    result.setCreated(user.getCreated());
    result.setDrawEnabled(user.getDrawEnabled());
    result.setAcceptRequests(user.getAcceptRequests());
    result.setMusicVolume(user.getMusicVolume());
    result.setSoundVolume(user.getSoundVolume());
    result.setShowTips(user.getShowTips());
    result.setShowCharNames(gameChar.getShowCharNames());
    result.setDances(user.getDancesData());
    result.setSuperUser(user.getSuperUser());
    result.setUserId(user.getId());
  }

  public List<FriendTO> getRobotTeam() {
    User user = new UserDAO(getSession()).findById(getAdapter().getUserId());
    return getRobotTeam(user);
  }

  private List<FriendTO> getRobotTeam(User user) {
    List<FriendTO> result = new ArrayList<FriendTO>();
    if (user.getRobotTeam() == null) {
      return result;
    }
    List<User> members = new UserDAO(getSession()).findByRobotTeam(user.getRobotTeam());
    List<Long> userIds = new ArrayList<Long>();
    for (User member : members) {
      userIds.add(member.getId());
    }
    if (!userIds.isEmpty()) {
      List<UserServer> userServers =
          new UserServerDAO(getSession()).getUserServerByUserIds(userIds.toArray());
      for (User member : members) {
        FriendTO friend = new FriendTO();
        friend.setUserId(member.getId().intValue());
        friend.setLogin(member.getLogin());
        for (Iterator<UserServer> iterator = userServers.iterator(); iterator.hasNext(); ) {
          UserServer userServer = iterator.next();
          if (userServer.getUserId().equals(member.getId())) {
            friend.setServer(ServersCache.getInstance().getServerName(userServer));
            userServers.remove(userServer);
            break;
          }
        }
        if (member.getId().equals(user.getRobotTeam().getUser_id())) {
          result.add(0, friend);
        } else {
          result.add(friend);
        }
      }
    }
    return result;
  }

  private List<Object> getQuests() {
    List<Object> result =
        new QuestDAO(getSession()).findEnabled(KavalokApplication.getInstance().getServer());
    return result;
  }
}
