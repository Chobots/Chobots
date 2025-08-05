package com.kavalok.sharedObjects;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Session;
import org.red5.io.utils.ObjectMap;
import org.red5.server.api.IAttributeStore;
import org.red5.server.api.so.ISharedObject;
import org.red5.server.api.so.ISharedObjectBase;
import org.red5.server.api.so.ISharedObjectListener;
import org.red5.threadmonitoring.ThreadMonitorServices;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.utils.HibernateUtil;
import com.kavalok.dao.UserDAO;
import com.kavalok.db.User;
import com.kavalok.messages.MessageChecker;
import com.kavalok.transactions.TransactionUtil;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.utils.ReflectUtil;
import com.kavalok.utils.SOUtil;
import com.kavalok.services.stuff.RainTokenManager;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.db.StuffType;
import com.kavalok.transactions.DefaultTransactionStrategy;
import com.kavalok.transactions.ITransactionStrategy;

public class SOListener implements ISharedObjectListener {

  private static String CHAR_STATE_FORMAT = "char_%1$s";

  private static String CONNECT_HANDLER = "oCC";

  private static String DISCONECT_HANDLER = "oCD";

  public static final String PREVENT = "PREVENT";

  public static final String CLEAR = "clear";

  public static final String LISTENER = "listener";

  public static final String DELIMITER = "|";

  public static final String SEND_STATE = "oSS";

  public static final String SEND = "oS";

  private static Logger logger = LoggerFactory.getLogger(SOListener.class);

  // Array of restricted rooms that require superuser access
  private static final String[] RESTRICTED_ROOMS = {
    "locSecret",
    "locSecret2", 
    "locSecret3",
    "locAdmin",
    "locModerator",
    "locTest",
    "locPrivate"
  };

  public static SOListener getListener(ISharedObject sharedObject) {
    return (SOListener) sharedObject.getAttribute(LISTENER);
  }

  protected ArrayList<String> connectedUsers = new ArrayList<String>();

  protected ISharedObject sharedObject;

  private ObjectMap<String, Object> state;

  private LockedStates lockedStates = new LockedStates();

  public SOListener() {
    state = new ObjectMap<String, Object>();
  }

  public Boolean C(Object[] message) {
    return false;
  }

  public Boolean C(String charId, Integer userId, String message) {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    if (!adapter.getUserId().equals(userId.longValue())) return true;
    ArrayList<Object> checkArgs = new ArrayList<Object>();
    checkArgs.add(message);
    checkArgs.add(true);
    checkArgs.add(true);
    MessageChecker checker = new MessageChecker();
    return (Boolean) TransactionUtil.callTransaction(checker, "checkMessage", checkArgs);
  }

  public Boolean rExecuteCommand(ObjectMap<String, Object> command) {
    String className = (String) command.get("className");
    
    logger.info("Received command: className=" + className + ", command=" + command);
    
    // Check for superuser-only commands
    if ("com.kavalok.location.commands::MoveCharCommand".equals(className) ||
        "com.kavalok.location.commands::MoveToLocCommand".equals(className) ||
        "com.kavalok.location.commands::FlyingPromoCommand".equals(className)) {
      if (!isUserSuperUser()) {
        logger.warn("Non-superuser attempted command: " + className + " - " + getCurrentUserLogin());
        return true; // Prevent execution
      }
    }
    
    // For now, just pass through all commands without special processing
    return false;
  }

  public ObjectMap<String, Object> getState() {
    return state;
  }

  public void initialize(ISharedObject sharedObject) {
    logger.info("shared object initialized " + sharedObject.getName());
    this.sharedObject = sharedObject;
    sharedObject.setAttribute(LISTENER, this);
  }

  public List<String> getConnectedChars() {
    return connectedUsers;
  }

  public void onSharedObjectClear(ISharedObjectBase arg0) {}

  public void onSharedObjectConnect(ISharedObjectBase sharedObject) {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    String roomName = ((org.red5.server.api.IBasicScope) sharedObject).getName();
    
    if (isRestrictedRoom(roomName)) {
      if (!isUserSuperUser()) {
        logger.warn("Non-superuser attempted to connect to restricted room: " + roomName + " - " + getCurrentUserLogin());
        adapter.kickOut("Unauthorized access to restricted room", false);
        return;
      }
    }
    
    connectedUsers.add(adapter.getLogin());
    ArrayList<Object> list = new ArrayList<Object>();
    list.add(adapter.getLogin());

    sharedObject.sendMessage(CONNECT_HANDLER, list);
    // IServiceCapableConnection connection = (IServiceCapableConnection)
    // Red5.getConnectionLocal();
    // logger.debug("Restore state ".concat(this.sharedObject.getName()));
    // connection.invoke(RESTORE_STATE, new Object[] {
    // this.sharedObject.getName(), state, getConnectedChars() });
    // logger.info("location {} char {} enter", ((IBasicScope)
    // sharedObject).getName(), adapter.getLogin());
  }

  public void onSharedObjectDelete(ISharedObjectBase arg0, String arg1) {
    // TODO Auto-generated method stub

  }

  public void onSharedObjectDisconnect(ISharedObjectBase sharedObject) {
    processDisconnect();
  }

  protected void sendState(
      String clientId, String method, String stateName, ObjectMap<String, Object> state) {
    SOUtil.sendState(sharedObject, clientId, method, stateName, state);
  }

  protected void callClient(String clientId, String method, Object... params) {
    SOUtil.callSharedObject(sharedObject, clientId, method, params);
  }

  @SuppressWarnings("unchecked")
  public void processDisconnect() {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    try {
      synchronized (this) {
        if (!connectedUsers.contains(adapter.getLogin())) return;

        connectedUsers.remove(adapter.getLogin());
      }

      ArrayList<Object> args = new ArrayList<Object>();
      args.add(adapter.getLogin());

      lockedStates.unlockStates(adapter.getLogin());

      for (Object clientStateObject : state.values()) {
        ObjectMap<String, Object> clientState = (ObjectMap<String, Object>) clientStateObject;
        String key = String.format(CHAR_STATE_FORMAT, adapter.getLogin());
        if (clientState.containsKey(key)) {
          clientState.remove(key);
        }
      }

      sharedObject.sendMessage(DISCONECT_HANDLER, args);
      // logger.info("location {} char {} exit", ((IBasicScope)
      // sharedObject).getName(), adapter.getLogin());
    } catch (Exception e) {
      logger.error("Error while disconnecting from so", e);
    }
  }

  @SuppressWarnings("unchecked")
  public void onSharedObjectSend(ISharedObjectBase arg0, String methodName, List args) {}

  @SuppressWarnings("unchecked")
  private LinkedHashMap<Integer, Object> getMethodArgs(List args) {
    LinkedHashMap<Integer, Object> methodArgs = (LinkedHashMap<Integer, Object>) args.get(2);
    return methodArgs;
  }

  protected void executeServerMethods(
    String clientId, String methodName, LinkedHashMap<Integer, Object> args) {

    if (methodName == null) {
      return;
    }

    try {
      Boolean interrup = (Boolean) ReflectUtil.callMethod(this, methodName, args.values());
      if (interrup != null && interrup) {
        logger.warn("interrup");
        preventClientInvocation(args);
      }
    } catch (NoSuchMethodException e) {
      // OK
    } catch (Exception e) {
      logger.error(e.getMessage(), e);
    }
  }

  protected boolean isPrevent(LinkedHashMap<Integer, Object> methodArgs) {
    return methodArgs.size() == 1 && methodArgs.get(0) == PREVENT;
  }

  protected void preventClientInvocation(LinkedHashMap<Integer, Object> methodArgs) {
    methodArgs.clear();
    methodArgs.put(0, PREVENT);
  }

  @SuppressWarnings("unchecked")
  protected void processSendState(
      LinkedHashMap<Integer, Object> methodArgs, String clientId, String stateName) {
    ObjectMap<String, Object> stateObject = getStateObject(clientId, stateName);

    if (lockedStates.canReset(clientId, stateName)) {
      if (methodArgs.size() == 3) {
        Boolean lockState = (Boolean) methodArgs.get(2);
        if (lockState) {
          lockedStates.lockState(clientId, stateName);
        } else {
          lockedStates.unlockState(clientId, stateName);
        }
      }
      ObjectMap<String, Object> newStateObject = (ObjectMap<String, Object>) methodArgs.get(1);
      if (newStateObject == null) {
        ObjectMap<String, Object> clientState = (ObjectMap<String, Object>) state.get(clientId);
        clientState.remove(stateName);
      } else
        for (Map.Entry<String, Object> newStateEntry : newStateObject.entrySet()) {
          stateObject.put(newStateEntry.getKey(), newStateEntry.getValue());
        }
      methodArgs.remove(2);
    } else {
      preventClientInvocation(methodArgs);
    }
  }

  @SuppressWarnings("unchecked")
  protected ObjectMap<String, Object> getStateObject(String clientId, String stateName) {
    forceKey(state, clientId);
    ObjectMap<String, Object> clientState = (ObjectMap<String, Object>) state.get(clientId);
    forceKey(clientState, stateName);
    ObjectMap<String, Object> stateObject = (ObjectMap<String, Object>) clientState.get(stateName);
    return stateObject;
  }

  protected Long getUserId() {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    return adapter.getUserId();
  }

  protected String getCharId() {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    return adapter.getLogin();
  }

  private void forceKey(ObjectMap<String, Object> map, String key) {
    if (!map.containsKey(key)) {
      map.put(key, new ObjectMap<String, Object>());
    }
  }

  /**
   * Check if the current user is a superuser
   * @return true if user is superuser, false otherwise
   */
  private boolean isUserSuperUser() {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (userAdapter == null) {
      logger.warn("Unauthorized access attempt by unknown user");
      return false;
    }

    Session session = null;
    try {
      session = HibernateUtil.getSessionFactory().openSession();
      UserDAO userDAO = new UserDAO(session);
      User user = userDAO.findById(userAdapter.getUserId());
      
      if (user != null) {
        return Boolean.TRUE.equals(user.getSuperUser());
      }
    } catch (Exception e) {
      logger.error("Error checking superuser status", e);
    } finally {
      if (session != null && session.isOpen()) {
        session.close();
      }
    }
    
    return false;
  }

  /**
   * Get the current user's login name
   * @return login name or "unknown" if not available
   */
  private String getCurrentUserLogin() {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    return userAdapter != null ? userAdapter.getLogin() : "unknown";
  }

  private boolean isRestrictedRoom(String roomName) {
    for (String restrictedRoom : RESTRICTED_ROOMS) {
      if (roomName.equals(restrictedRoom)) {
        return true;
      }
    }
    return false;
  }

  public void onSharedObjectUpdate(ISharedObjectBase arg0, IAttributeStore arg1) {
    // TODO Auto-generated method stub

  }

  public void onSharedObjectUpdate(ISharedObjectBase arg0, Map<String, Object> arg1) {
    // TODO Auto-generated method stub

  }

  public void onSharedObjectUpdate(ISharedObjectBase arg0, String arg1, Object arg2) {
    // TODO Auto-generated method stub

  }

  @Override
  public void onSharedObjectDestroy(ISharedObjectBase so) {
    so.removeSharedObjectListener(this);
  }

  @SuppressWarnings("unchecked")
  @Override
  public void beforeSharedObjectSend(ISharedObjectBase arg0, String methodName, List args) {
    ThreadMonitorServices.startJobSubDetails();
    ThreadMonitorServices.setJobDetails(
        "SOListenerbeforeSharedObjectSend(ISharedObjectBase arg0 {0}, String methodName {1}, List args {2})",
        arg0, methodName, args);
    
    logger.info("beforeSharedObjectSend: methodName=" + methodName + ", args=" + args);
    
    // Check for rCharAction messages (char property modifications)
    if ("oS".equals(methodName) && args.size() > 1) {
      String actualMethodName = (String) args.get(1);
      logger.info("Checking rCharAction: actualMethodName=" + actualMethodName + ", args.size()=" + args.size());
      if ("rCharAction".equals(actualMethodName) && args.size() > 2) {
        // Extract the action class name from the parameters
        Object parameters = args.get(2);
        logger.info("rCharAction parameters: " + parameters);
        logger.info("rCharAction parameters type: " + (parameters != null ? parameters.getClass().getName() : "null"));
        if (parameters instanceof java.util.Map) {
          java.util.Map<Object, Object> params = (java.util.Map<Object, Object>) parameters;
          logger.info("rCharAction params keys: " + params.keySet());
          String className = (String) params.get(1); // The action class name (Integer key)
          
          logger.info("rCharAction className: " + className);
          logger.info("rCharAction className null check: " + (className != null));
          
          // Check for superuser-only action classes
          if (className != null && (
              className.contains("::LoadExternalContent") ||
              className.contains("::CharPropertyAction") ||
              className.contains("::CharsModifierAction") ||
              className.contains("::LocationPropertyAction") ||
              className.contains("::PropertyActionBase") ||
              className.contains("::CharsPropertyAction"))) {
            logger.info("rCharAction matched superuser class: " + className);
            if (!isUserSuperUser()) {
              logger.warn("Non-superuser attempted rCharAction: " + className + " - " + getCurrentUserLogin());
              logger.info("BLOCKING rCharAction execution for non-superuser");
              // Use preventClientInvocation to actually block the execution
              LinkedHashMap<Integer, Object> methodArgs = getMethodArgs(args);
              preventClientInvocation(methodArgs);
              return;
            }
          } else {
            logger.info("rCharAction not matched or className null: " + className);
          }
        } else {
          logger.info("rCharAction parameters is not Map: " + parameters.getClass().getName());
        }
      }
    }
    
    // Check for rExecuteCommand messages (MoveCharCommand and other commands)
    if ("rExecuteCommand".equals(methodName) && args.size() > 0) {
      Object commandObj = args.get(0);
      if (commandObj instanceof ObjectMap) {
        ObjectMap<String, Object> command = (ObjectMap<String, Object>) commandObj;
        String className = (String) command.get("className");
        
        if ("com.kavalok.location.commands::MoveCharCommand".equals(className) ||
            "com.kavalok.location.commands::MoveToLocCommand".equals(className) ||
            "com.kavalok.location.commands::FlyingPromoCommand".equals(className)) {
          if (!isUserSuperUser()) {
            logger.warn("Non-superuser attempted command: " + className + " - " + getCurrentUserLogin());
            // Use preventClientInvocation to actually block the execution
            LinkedHashMap<Integer, Object> methodArgs = getMethodArgs(args);
            preventClientInvocation(methodArgs);
            return; // Prevent execution
          }
        }
      }
    }
    
    // Check for rResetObjectPositions (reset command)
    if ("rResetObjectPositions".equals(methodName)) {
      if (!isUserSuperUser()) {
        logger.warn("Non-superuser attempted rResetObjectPositions: " + getCurrentUserLogin());
        // Use preventClientInvocation to actually block the execution
        LinkedHashMap<Integer, Object> methodArgs = getMethodArgs(args);
        preventClientInvocation(methodArgs);
        return; // Prevent execution
      }
    }
    
    if (SEND_STATE.equals(methodName) || SEND.equals(methodName)) {
      UserAdapter adapter = UserManager.getInstance().getCurrentUser();
      synchronized (this) {
        if (adapter != null && !connectedUsers.contains(adapter.getLogin())) {
          if (args.size() > 1) {
            preventClientInvocation(getMethodArgs(args));
          }
          return;
        }
      }

      String clientId = (String) args.get(0);
      String clientMethodName = (String) args.get(1);

      LinkedHashMap<Integer, Object> methodArgs = getMethodArgs(args);
      if (methodName.equals(SEND_STATE)) {
        String stateName = (String) methodArgs.get(0);
        processSendState(methodArgs, clientId, stateName);
      }
      if (!isPrevent(methodArgs)) {
        executeServerMethods(clientId, clientMethodName, methodArgs);
      } else {
        logger.warn("prevented: " + clientId + " - " + clientMethodName);
      }
    }
    if (methodName.equals(CLEAR)) {
      state.clear();
      lockedStates.clear();
      connectedUsers.clear();
    }
    ThreadMonitorServices.stopJobSubDetails(
        "SOListenerbeforeSharedObjectSend(ISharedObjectBase arg0 {0}, String methodName {1}, List args {2})",
        arg0, methodName, args);
  }
}
