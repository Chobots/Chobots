package com.kavalok.messages;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.hibernate.Session;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.dao.UserDAO;
import com.kavalok.db.User;
import com.kavalok.services.BanUtil;
import com.kavalok.transactions.ISessionDependent;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.xmlrpc.AdminClient;
import com.kavalok.xmlrpc.RemoteClient;

public class MessageChecker implements ISessionDependent {
  private static Logger logger = Red5LoggerFactory.getLogger(MessageChecker.class);

  private Session session;

  public MessageChecker() {
    super();
  }

  public MessageChecker(Session session) {
    super();
    this.session = session;
  }

  @Override
  public void setSession(Session session) {
    this.session = session;
  }

  public boolean checkMessage(String message, Boolean checkSpam, Boolean showInLog) {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    return checkMessage(
        null,
        adapter.getUserId(),
        UsersCache.getInstance().getLogin(adapter.getUserId(), session),
        message,
        checkSpam,
        showInLog);
  }

  public boolean checkMessage(
      User user,
      Long userId,
      String userLogin,
      String message,
      Boolean checkSpam,
      Boolean showInLog) {

    MessageCheck messageCheck = new MessageCheck(session);

    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    boolean isSpam = !adapter.saveChatMessage((String) message);

    List<String> shortMessage = adapter.addToShortList(message);
    if (shortMessage != null) {
      StringBuffer messageToLog = new StringBuffer();
      StringBuffer messageToCheck = new StringBuffer();
      for (Iterator<String> iterator = shortMessage.iterator(); iterator.hasNext(); ) {
        String messPart = iterator.next();
        messageToLog.append(messPart).append("\n");
        messageToCheck.append(messPart);
      }
      MessageCheckResult checkResult = messageCheck.check(messageToCheck.toString());
      if (checkResult.getSafety() != MessageSafety.SAFE) {
        reviewUserMessage(
            userId, userLogin, messageToLog.toString(), checkResult.getPart(), "susp");
      }
    }

    MessageCheckResult checkResult = messageCheck.check(message);

    if (!adapter.getPersistent()) {
      return false;
    }

    if (isSpam && checkSpam) {
      user = populateUser(user, userId);
      new RemoteClient(session, user).sendCommand("ShowRulesCommand", null);
      return true;
    } else if (checkResult.getSafety() == MessageSafety.BAD) {
      user = populateUser(user, userId);
      blockChat(user, checkResult.getPart());
      if (showInLog) reviewUserMessage(userId, userLogin, message, checkResult.getPart(), "bad");
      return true;
    } else if (checkResult.getSafety() == MessageSafety.SUSPICIOUS
        || checkResult.getSafety() == MessageSafety.REVIEW) {
      if (showInLog) reviewUserMessage(userId, userLogin, message, checkResult.getPart(), "susp");
    } else if (checkResult.getSafety() == MessageSafety.SKIP) {
      if (showInLog) reviewUserMessage(userId, userLogin, message, checkResult.getPart(), "skip");
      // skipChat(checkResult.getPart(), message);
      return true;
    }
    return false;
  }

  private User populateUser(User user, Long userId) {
    if (user == null) {
      user = new UserDAO(session).findById(userId);
    }
    return user;
  }

  private void reviewUserMessage(
      Long userId, String userLogin, String message, String part, String type) {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();

    if (!adapter.getPersistent()) {
      return;
    }
    Map<String, Object> badWord = new HashMap<String, Object>();
    badWord.put("userLogin", userLogin);
    badWord.put("userId", userId.intValue());
    badWord.put("word", part);
    badWord.put("message", message);
    badWord.put("type", type);

    new AdminClient(session).logBadWord(badWord);
    // new AdminClient(session).logBadWord(userLogin, userId.intValue(), part,
    // message, type);
  }

  private void blockChat(User user, String part) {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    if (adapter.getPersistent()) BanUtil.disableChat(user, session, adapter, part);
    logger.info(String.format("user %1s said bad word: %2s", adapter.getLogin(), part));
  }

  //  private void skipChat(String part, String message) {
  //    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
  //    adapter.skipChat(part, message);
  //    logger.info(String.format("user %1s said skip word: %2s", adapter.getLogin(), part));
  //  }

}
