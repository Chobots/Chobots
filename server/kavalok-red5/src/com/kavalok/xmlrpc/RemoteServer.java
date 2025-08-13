package com.kavalok.xmlrpc;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

import org.apache.xmlrpc.server.XmlRpcServer;
import org.red5.io.utils.ObjectMap;
import org.red5.server.api.so.ISharedObject;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.KavalokApplication;
import com.kavalok.cache.StuffTypeCache;
import com.kavalok.dao.ServerDAO;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.db.Server;
import com.kavalok.db.User;
import com.kavalok.db.UserServer;
import com.kavalok.permissions.AccessUser;
import com.kavalok.services.GraphityService;
import com.kavalok.services.LoginService;
import com.kavalok.sharedObjects.AdminSO;
import com.kavalok.sharedObjects.SOListener;
import com.kavalok.transactions.DefaultTransactionStrategy;
import com.kavalok.transactions.TransactionUtil;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.utils.HibernateUtil;
import com.kavalok.utils.SOUtil;
import com.kavalok.services.stuff.RainTokenManager;
import com.kavalok.sharedObjects.SOListener;
import com.kavalok.db.StuffType;
import com.kavalok.services.RainCommandService;

public class RemoteServer extends DefaultTransactionStrategy {

  private static final Logger logger = Red5LoggerFactory.getLogger(RemoteServer.class);

  protected XmlRpcServer rpcServer;

  protected Thread rpcThread;

  public RemoteServer() {}

  public void renewLocation(String location) {
    try {
      ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(location);
      if (sharedObject != null) {
        sharedObject.sendMessage(SOListener.CLEAR, new ArrayList<Object>());
      } else {
        logger.warn("Shared object not found for location: " + location);
      }
    } catch (Exception e) {
      logger.error("Error in renewLocation for location: " + location, e);
    }
  }

  @SuppressWarnings("unchecked")
  public void sendState(
      String remoteId, String clientId, String method, String stateName, byte[] state /*
                                                                                                         * HashMap<String,
                                                                                                         * Object>
                                                                                                         * stateMap
                                                                                                         */) {
    try {
      ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(remoteId);
      if (sharedObject != null) {
        ObjectMap<String, Object> stateInstance =
            (ObjectMap<String, Object>) HibernateUtil.deserialize(state);
        SOUtil.sendState(sharedObject, clientId, method, stateName, stateInstance);
      } else {
        logger.warn("Shared object not found for remoteId: " + remoteId);
      }
    } catch (Exception e) {
      logger.error("Error in sendState for remoteId: " + remoteId, e);
    }
  }

  public Integer getNumConnectedChars(String sharedObjectId) {
    return SOUtil.getNumConnectedChars(sharedObjectId);
  }

  public void sendCommand(String commandName, Object parameter) {
    try {
      for (UserAdapter user : UserManager.getInstance().getUsers()) {
        user.executeCommand(commandName, parameter);
      }
    } catch (Exception e) {
      System.out.println("Error exectuing command: " + commandName + "\n parameter: " + parameter);
      e.printStackTrace();
      logger.error(e.getMessage(), e);
    }
  }

  public void sendCommand(String login, String commandName, Object parameter) {
    try {
      UserAdapter user = UserManager.getInstance().getUser(login);
      if (user == null) {
        return;
      }

      user.executeCommand(commandName, parameter);
    } catch (Exception e) {
      logger.error("Error exectuing command: " + commandName + "\n parameter: " + parameter);
      logger.error(
          "RemoteServer.sendCommand: Error sending command to user '"
              + login
              + "': "
              + e.getMessage(),
          e);
    }
  }

  public void clearGraphity(String wallId) {
    new GraphityService().clear(wallId);
  }

  public Object[] getGraphity(String wallId) {
    List<Object> shapes = new GraphityService().getShapes(wallId);
    return shapes.toArray();
  }

  public void logUserMessage(String login, String message) {
    new AdminSO().logUserMessage(login, message);
  }

  public void logMessage(String message) {
    new AdminSO().logMessage(message);
  }

  public void logUserReport(String login, Integer userId, String message, Integer id) {
    new AdminSO().logUserReport(login, userId, message, id);
  }

  public void logAdminMessage(String login, String server, String message) {
    new AdminSO().logAdminMessage(login, server, message);
  }

  public void logBadWord(
      String login, Integer userId, String server, String word, String message, String type) {
    try {
      new AdminSO().logBadWord(login, userId, server, word, message, type);
    } catch (Exception e) {
      logger.error(e.getMessage(), e);
    }
  }

  @SuppressWarnings("unchecked")
  public void logBadWord(String server, Object[] badWords) {
    try {

      for (int i = 0; i < badWords.length; i++) {
        Map badWord = (Map) badWords[i];
        new AdminSO()
            .logBadWord(
                (String) badWord.get("userLogin"),
                (Integer) badWord.get("userId"),
                server,
                (String) badWord.get("word"),
                (String) badWord.get("message"),
                (String) badWord.get("type"));
      }

    } catch (Exception e) {
      logger.error(e.getMessage(), e);
    }
  }

  public void logUserEnter(String login, String server, Boolean firstLogin) {
    new AdminSO().logUserEnter(login, server, firstLogin);
  }

  public String getUserLocations(String login) {
    UserAdapter adapter = UserManager.getInstance().getUser(login);
    List<String> locations = adapter.getSharedObjects();
    String result = "";
    for (String item : locations) {
      result += item;
      break;
    }
    return result;
  }

  public String getUserLastChatMessages(String login) {
    UserAdapter adapter = UserManager.getInstance().getUser(login);
    return adapter.getLastChatMessages();
  }

  public void reboot() {
    try {
      Runtime.getRuntime().exec("/etc/init.d/red5 restart");
    } catch (IOException e) {
      logger.error(e.getMessage(), e);
    }
  }

  public void refreshServerConfig() {
    KavalokApplication.getInstance().refreshConfig();
  }

  public void refreshStuffTypeCache() {
    StuffTypeCache.getInstance().clear();
  }

  public void disableUserChat(String login, Boolean enabledByMod, Boolean enabledByParent) {
    UserAdapter adapter = UserManager.getInstance().getUser(login);
    if (adapter != null)
      adapter.disableChatAdmin("Disabled by admin", enabledByMod, enabledByParent);
  }

  private static long maxKickOutTime = 0;

  public void kickOutUser(String login, boolean banned) {
    UserAdapter adapter = UserManager.getInstance().getUser(login);

    long now = System.currentTimeMillis();
    if (adapter != null) {
      adapter.kickOut(LoginService.SOMEONE_USED_YOUR_LOGIN, banned);
      long diff = System.currentTimeMillis() - now;
      System.err.println("KICKOUT_SERVER time ms: " + diff);
      System.err.println("KICKOUT_SERVER time user: " + adapter.getLogin());
      if (diff > maxKickOutTime) {
        maxKickOutTime = diff;
        System.err.println("Max_KICKOUT_SERVER_CALL time user: " + adapter.getLogin());
        System.err.println("Max_KICKOUT_SERVER_CALL time ms: " + maxKickOutTime);
      }
    }
  }

  public void sendCommandToAll(String commandName, Object parameter) {
    for (UserAdapter adapter : UserManager.getInstance().getUsers()) {
      if (adapter.getAccessType() == AccessUser.class)
        adapter.executeCommand(commandName, parameter);
    }
  }

  public void sendCommandToAll(byte[] command, byte[] locales) {
    ArrayList<Object> args = new ArrayList<Object>();
    args.add(command);
    args.add(locales);
    TransactionUtil.callTransaction(this, "doSendCommandToAll", args);
  }

  public void sendLocationCommand(String remoteId, byte[] command) {
    try {
      Object commandInstance = HibernateUtil.deserialize(command);
      String clientId = "L";

      // Check if shared object exists before trying to call it
      ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(remoteId);
      if (sharedObject != null) {
        SOUtil.callSharedObject(sharedObject, clientId, "rExecuteCommand", commandInstance);
      } else {
        logger.warn("Shared object not found for remoteId: " + remoteId);
      }
    } catch (Exception e) {
      logger.error("Error in sendLocationCommand for remoteId: " + remoteId, e);
    }
  }

  public void doSendCommandToAll(byte[] command, byte[] locales) {
    Server server = KavalokApplication.getInstance().getServer();

    UserServerDAO usDAO = new UserServerDAO(getSession());
    List<UserServer> userServers = usDAO.getAllUserServer(server);
    List<String> localesList = Arrays.asList((String[]) HibernateUtil.deserialize(locales));
    for (UserServer userServer : userServers) {
      User user = userServer.getUser();
      if (user.getLocale() == null
          || localesList.contains(user.getLocale())
          || localesList.size() == 0) sendCommand(user.getLogin(), command);
    }
  }

  public void sendCommand(String charName, byte[] command) {
    try {
      Object commandInstance = HibernateUtil.deserialize(command);
      UserAdapter adapter = UserManager.getInstance().getUser(charName);
      if (adapter != null) adapter.executeCommand(commandInstance);
    } catch (Exception e) {
      logger.error(e.getMessage(), e);
    }
  }

  /**
   * Handle rain command on this server for a specific location.
   * This method is called via XMLRPC from the admin server.
   * 
   * @param locationId The location ID where to rain
   * @param fileName The file name of the item to rain
   * @param count The number of items to rain per user
   */
  public void triggerRainOnLocation(String locationId, String fileName, Integer count) {
    ArrayList<Object> args = new ArrayList<Object>();
    args.add(locationId);
    args.add(fileName);
    args.add(count);
    TransactionUtil.callTransaction(this, "doTriggerRainOnLocation", args);
  }

  /**
   * Internal method to handle rain command with proper transaction management.
   * This method is called via TransactionUtil.callTransaction.
   * 
   * @param locationId The location ID where to rain
   * @param fileName The file name of the item to rain
   * @param count The number of items to rain per user
   */
  public void doTriggerRainOnLocation(String locationId, String fileName, Integer count) {
    try {
      // Get the shared object for the location
      ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(locationId);
      if (sharedObject == null) {
        logger.warn("Shared object not found for location: " + locationId);
        return;
      }

      // Get connected users in this location
      SOListener listener = SOListener.getListener(sharedObject);
      List<String> connectedUsers = listener.getConnectedChars();
      
      if (connectedUsers.isEmpty()) {
        logger.info("No connected users found in location: " + locationId);
        return;
      }

      // Get the stuff type - properly create DAO with session
      StuffTypeDAO stuffTypeDAO = new StuffTypeDAO(getSession());
      StuffType stuffType = stuffTypeDAO.findByFileName(fileName);

      if (stuffType == null || !stuffType.getRainable()) {
        logger.error("Item is not rainable: " + fileName);
        return;
      }

      logger.info("Triggering rain for " + connectedUsers.size() + " users in location " + locationId);

      // Use the shared method to send rain commands to users
      RainCommandService.sendRainCommandsToUsers(connectedUsers, stuffType, count);
    } catch (Exception e) {
      logger.error("Error triggering rain on location: " + locationId, e);
    }
  }
}
