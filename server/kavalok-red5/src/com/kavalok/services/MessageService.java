package com.kavalok.services;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

import org.hibernate.ObjectNotFoundException;
import org.red5.io.utils.ObjectMap;
import org.red5.server.api.so.ISharedObject;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.AllowedWordDAO;
import com.kavalok.dao.BlockWordDAO;
import com.kavalok.dao.GameCharDAO;
import com.kavalok.dao.MessageDAO;
import com.kavalok.dao.ReviewWordDAO;
import com.kavalok.dao.SkipWordDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.db.AllowedWord;
import com.kavalok.db.BlockWord;
import com.kavalok.db.GameChar;
import com.kavalok.db.Message;
import com.kavalok.db.ReviewWord;
import com.kavalok.db.Server;
import com.kavalok.db.SkipWord;
import com.kavalok.db.User;
import com.kavalok.dto.PagedResult;
import com.kavalok.messages.MessageChecker;
import com.kavalok.messages.UsersCache;
import com.kavalok.services.common.DataServiceNotTransactionBase;
import com.kavalok.services.common.SimpleEncryptor;
import com.kavalok.sharedObjects.SOListener;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.xmlrpc.RemoteClient;

public class MessageService extends DataServiceNotTransactionBase {

  public static final Byte[] KEY = SimpleEncryptor.generateKey();

  private static final String CLASS_NAME_FIELD = "className";

  private static final int MAX_OFFLINE_MESSAGES = 50;

  private static String MESSAGE_TEXT_FIELD = "text";

  private static String MESSAGE_SENDER_FIELD = "sender";

  private static String MESSAGE_SENDER_USER_ID_FIELD = "senderUserId";

  private static String CHAT_METHOD = "oC";

  public Integer removeBlockWord(Integer id) {
    new BlockWordDAO(getSession()).makeTransient(Long.valueOf(id));
    return id;
  }

  public Integer removeAllowedWord(Integer id) {
    new AllowedWordDAO(getSession()).makeTransient(Long.valueOf(id));
    return id;
  }

  public Integer removeSkipWord(Integer id) {
    new SkipWordDAO(getSession()).makeTransient(Long.valueOf(id));
    return id;
  }

  public Integer removeReviewWord(Integer id) {
    new ReviewWordDAO(getSession()).makeTransient(Long.valueOf(id));
    return id;
  }

  public PagedResult<BlockWord> findBlockWord(
      String part, Integer firstResult, Integer maxResults) {
    return new BlockWordDAO(getSession()).findLikeWord(part, firstResult, maxResults);
  }

  public PagedResult<AllowedWord> findAllowedWord(
      String part, Integer firstResult, Integer maxResults) {
    return new AllowedWordDAO(getSession()).findLikeWord(part, firstResult, maxResults);
  }

  public PagedResult<SkipWord> findSkipWord(String part, Integer firstResult, Integer maxResults) {
    return new SkipWordDAO(getSession()).findLikeWord(part, firstResult, maxResults);
  }

  public PagedResult<ReviewWord> findReviewWord(
      String part, Integer firstResult, Integer maxResults) {
    return new ReviewWordDAO(getSession()).findLikeWord(part, firstResult, maxResults);
  }

  public BlockWord addBlockWord(String word) {
    BlockWord blockWord = new BlockWord(word);
    return new BlockWordDAO(getSession()).makePersistent(blockWord);
  }

  public AllowedWord addAllowedWord(String word, Boolean checkReview) {
    word = word.toLowerCase();

    if (checkReview) {
      ReviewWordDAO reviewWordDAO = new ReviewWordDAO(getSession());
      if (reviewWordDAO.hasWord(word)) return new AllowedWord(word);
    }

    AllowedWordDAO allowedWordDAO = new AllowedWordDAO(getSession());
    if (allowedWordDAO.hasWord(word)) return allowedWordDAO.findByWord(word);
    return allowedWordDAO.makePersistent(new AllowedWord(word));
  }

  public ReviewWord addReviewWord(String word) {
    word = word.toLowerCase();
    ReviewWordDAO reviewWordDAO = new ReviewWordDAO(getSession());
    if (reviewWordDAO.hasWord(word)) return reviewWordDAO.findByWord(word);
    return reviewWordDAO.makePersistent(new ReviewWord(word));
  }

  public SkipWord addSkipWord(String word) {
    word = word.toLowerCase();
    SkipWordDAO skipWordDAO = new SkipWordDAO(getSession());
    if (skipWordDAO.hasWord(word)) return skipWordDAO.findByWord(word);
    return skipWordDAO.makePersistent(new SkipWord(word));
  }

  public PagedResult<BlockWord> getBlockWords(Integer firstResult, Integer maxResults) {
    BlockWordDAO blockWordDAO = new BlockWordDAO(getSession());
    List<BlockWord> result = blockWordDAO.findAll(firstResult, maxResults);
    return new PagedResult<BlockWord>(blockWordDAO.size(), result);
  }

  public PagedResult<ReviewWord> getReviewWords(Integer firstResult, Integer maxResults) {
    ReviewWordDAO reviewWordDAO = new ReviewWordDAO(getSession());
    List<ReviewWord> result = reviewWordDAO.findAll(firstResult, maxResults);
    return new PagedResult<ReviewWord>(reviewWordDAO.size(), result);
  }

  public PagedResult<AllowedWord> getAllowedWords(Integer firstResult, Integer maxResults) {
    AllowedWordDAO allowedWordDAO = new AllowedWordDAO(getSession());
    List<AllowedWord> result = allowedWordDAO.findAll(firstResult, maxResults);
    return new PagedResult<AllowedWord>(allowedWordDAO.size(), result);
  }

  public PagedResult<SkipWord> getSkipWords(Integer firstResult, Integer maxResults) {
    SkipWordDAO skipWordDAO = new SkipWordDAO(getSession());
    List<SkipWord> result = skipWordDAO.findAll(firstResult, maxResults);
    return new PagedResult<SkipWord>(skipWordDAO.size(), result);
  }

  // sendChat: shorten for traffic optimization
  public void sC(String remoteId, String message) {
    sC(remoteId, (Object) message);
  }

  // sendChat: shorten for traffic optimization
  public void sC(String remoteId, LinkedHashMap<String, Object> message) {
    sC(remoteId, (Object) message);
  }

  // sendChat: shorten for traffic optimization
  public void sC(String remoteId, Object message) {
    ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(remoteId);
    send(message, sharedObject, CHAT_METHOD);
  }

  @SuppressWarnings("unchecked")
  public void lPC(LinkedHashMap message, String sharedObjId) {
    lPC((Object) message, sharedObjId);
  }

  public void lPC(String message, String sharedObjId) {
    lPC((Object) message, sharedObjId);
  }

  // locationPublicChat: shorten for traffic optimization
  public void lPC(Object message, String sharedObjId) {
    if (sharedObjId == null || sharedObjId.length() == 0) return;
    ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(sharedObjId);
    if (sharedObject == null) {
      return;
    }

    UserManager userMan = UserManager.getInstance();
    UserAdapter userAdapter = userMan.getCurrentUser();
    if (message instanceof String) {
      MessageChecker checker = new MessageChecker(getSession());

      if (checker.checkMessage(
          null, userAdapter.getUserId(), userAdapter.getLogin(), (String) message, true, true))
        return;
    }

    SOListener listener = SOListener.getListener(sharedObject);
    List<String> connectedChars = listener.getConnectedChars();
    // ObjectMap<String, Object> command;
    if (connectedChars.size() > 1 && connectedChars.contains(userAdapter.getLogin())) {
      List<String> connChars = new ArrayList<String>(connectedChars);
      for (Iterator<String> iterator = connChars.iterator(); iterator.hasNext(); ) {
        String login = (String) iterator.next();
        UserAdapter user = userMan.getUser(login);
        if (user != null
            && user.getLogin() != null
            && user.getUserId() != null
            && !userAdapter.getUserId().equals(user.getUserId())) {

          user.sendLocationChat(
              userAdapter.getUserId().intValue(), userAdapter.getLogin(), message);
        }
      }
    }
  }

  public void sendCommand(
      Integer userId, ObjectMap<String, Object> command, Boolean offline, Boolean showInLog) {

    UserDAO dao = new UserDAO(getSession());
    long userIdL = userId.longValue();
    String userLogin = UsersCache.getInstance().getLogin(userIdL, getSession());
    Long gameCharId = UsersCache.getInstance().getGameCharId(userIdL, getSession());
    User user = new User(userIdL, userLogin);
    user.setGameChar_id(gameCharId);

    // making workaround with user for offline messages
    User userToCheck = new User();
    userToCheck.setLogin(user.getLogin());
    userToCheck.setId(user.getId());

    GameCharDAO gameCharDao = new GameCharDAO(getSession());
    String className = (String) command.get(CLASS_NAME_FIELD);
    if ("com.kavalok.messenger.commands::TeleportMessage".equals(className)
        && isSenderIgnored(gameCharDao, userIdL, command)) return;
    MessageChecker checker = new MessageChecker(getSession());
    if (command.containsKey(MESSAGE_TEXT_FIELD)) {
      if (isSenderIgnored(gameCharDao, userIdL, command)) return;

      Object senderUserId = command.get(MESSAGE_SENDER_USER_ID_FIELD);
      if (senderUserId instanceof Integer && !userId.equals(senderUserId)) {
        userToCheck = dao.findById(((Integer) senderUserId).longValue());
      }

      Object message = command.get(MESSAGE_TEXT_FIELD);

      if (message instanceof String
          && checker.checkMessage(
              userToCheck,
              userToCheck.getId(),
              userToCheck.getLogin(),
              (String) message,
              false,
              showInLog)) return;
    }

    if (offline) {
      long id = saveOfflineCommand(user, command);
      command.put("id", id);
    }

    Server userServer = new UserServerDAO(getSession()).getServer(user);

    if (userServer == null) {
      // recipient not connected, returning because command saved
      return;
    }

    if (!userServer.getId().equals(KavalokApplication.getInstance().getServer().getId())) {
      // sending remote command because recipient is on another server
      new RemoteClient(getSession(), user, userServer).sendCommand(command);
    } else {
      // sending command in local instance because recipient is on same server
      UserAdapter adapter = UserManager.getInstance().getUser(user.getLogin());
      if (adapter != null) adapter.executeCommand(command);
    }
  }

  private boolean isSenderIgnored(GameCharDAO dao, Long userId, ObjectMap<String, Object> command) {
    GameChar gc = dao.findByUserId(userId);
    if (gc != null) {
      Object sender = command.get(MESSAGE_SENDER_FIELD);
      if (sender instanceof String) {
        String senderName = (String) sender;
        for (GameChar ignoreChar : gc.getIgnoreList()) {
          if (senderName.equals(ignoreChar.getLogin())) return true;
        }
      }
    }
    return false;
  }

  public void deleteCommand(Integer id) {
    MessageDAO dao = new MessageDAO(getSession());
    try {
      dao.makeTransient(id.longValue());
    } catch (ObjectNotFoundException e) {
      // OK message is deleted already
    }
  }

  private long saveOfflineCommand(User user, ObjectMap<String, Object> command) {
    GameChar gameChar = user.getGameCharIdentifier();

    Message msg = new Message(gameChar, command);
    MessageDAO messageDAO = new MessageDAO(getSession());
    messageDAO.makePersistent(msg);
    List<Message> messages = messageDAO.getMessages(gameChar, MAX_OFFLINE_MESSAGES);
    for (Message message : messages) messageDAO.makeTransient(message);

    return msg.getId();
  }

  private void send(Object message, ISharedObject sharedObject, String method) {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    if (message instanceof String) {
      MessageChecker checker = new MessageChecker(getSession());

      Long userId = UserManager.getInstance().getCurrentUser().getUserId();
      if (checker.checkMessage(
          null,
          userId,
          UsersCache.getInstance().getLogin(userId, getSession()),
          (String) message,
          true,
          true)) return;
    }

    ArrayList<Object> args = new ArrayList<Object>();
    args.add(new SimpleEncryptor(KEY).encrypt(adapter.getLogin()));
    if (message instanceof String) message = new SimpleEncryptor(KEY).encrypt((String) message);
    args.add(message);

    // for crash testing
    /*
     * args.add(new Integer[]{}); args.add(new Integer[]{});
     */

    System.err.println("method: " + method);
    System.err.println("args: " + args);
    sharedObject.sendMessage(method, args);
  }
}
