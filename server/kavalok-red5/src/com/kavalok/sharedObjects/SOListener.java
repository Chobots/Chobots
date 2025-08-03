package com.kavalok.sharedObjects;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.red5.io.utils.ObjectMap;
import org.red5.server.api.IAttributeStore;
import org.red5.server.api.so.ISharedObject;
import org.red5.server.api.so.ISharedObjectBase;
import org.red5.server.api.so.ISharedObjectListener;
import org.red5.threadmonitoring.ThreadMonitorServices;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.messages.MessageChecker;
import com.kavalok.transactions.TransactionUtil;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.utils.ReflectUtil;
import com.kavalok.utils.SOUtil;

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
      logger.warn("Method name was null - clientId: {}, args: {}", clientId, args);
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
