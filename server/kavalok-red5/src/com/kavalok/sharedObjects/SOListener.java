package com.kavalok.sharedObjects;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Collections;

import org.red5.io.utils.ObjectMap;
import org.red5.server.api.IAttributeStore;
import org.red5.server.api.scope.IBasicScope;
import org.red5.server.api.so.ISharedObject;
import org.red5.server.api.so.ISharedObjectBase;
import org.red5.server.api.so.ISharedObjectListener;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

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

  public static final String CLEAR = "clear";

  public static final String LISTENER = "listener";

  public static final String DELIMITER = "|";

  public static final String SEND_STATE = "oSS";

  public static final String SEND = "oS";

  private static Logger logger = Red5LoggerFactory.getLogger(SOListener.class);

  public static SOListener getListener(ISharedObject sharedObject) {
    return (SOListener) sharedObject.getAttribute(LISTENER);
  }

  protected List<String> connectedUsers = Collections.synchronizedList(new ArrayList<String>());

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
    synchronized (state) {
      ObjectMap<String, Object> copy = new ObjectMap<String, Object>();
      copy.putAll(state);
      return copy;
    }
  }

  public void initialize(ISharedObject sharedObject) {
    this.sharedObject = sharedObject;
    sharedObject.setAttribute(LISTENER, this);
  }

  public List<String> getConnectedChars() {
    synchronized (connectedUsers) {
      return new ArrayList<String>(connectedUsers);
    }
  }

  /**
   * Manually release the shared object when it's no longer needed.
   * This should be called when the shared object is no longer required.
   */
  public void releaseSharedObject() {
    if (sharedObject != null && sharedObject.isAcquired()) {
      sharedObject.release();
    }
  }

  public void onSharedObjectClear(ISharedObjectBase arg0) {}

  public void onSharedObjectConnect(ISharedObjectBase sharedObject) {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    connectedUsers.add(adapter.getLogin());
    ArrayList<Object> list = new ArrayList<Object>();
    list.add(adapter.getLogin());

    sharedObject.sendMessage(CONNECT_HANDLER, list);
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
    UserAdapter adapter  = UserManager.getInstance().getCurrentUser();

    if (adapter == null || adapter.getLogin() == null) {
      logger.warn("processDisconnect: unable to resolve disconnecting user; skipping notify");
      return;
    }

    String login = adapter.getLogin();
    try {
      if (!connectedUsers.contains(login)) return;

      ArrayList<Object> args = new ArrayList<Object>();
      args.add(login);
      sharedObject.sendMessage(DISCONECT_HANDLER, args);

      connectedUsers.remove(login);
      lockedStates.unlockStates(login);

      synchronized (state) {
        for (Object clientStateObject : state.values()) {
          ObjectMap<String, Object> clientState = (ObjectMap<String, Object>) clientStateObject;
          String key = String.format(CHAR_STATE_FORMAT, login);
          if (clientState.containsKey(key)) {
            clientState.remove(key);
          }
        }
      }

      if (connectedUsers.isEmpty() && sharedObject.isAcquired()) {
        sharedObject.release();
      }
    } catch (Exception e) {
      logger.error("Error while disconnecting from so", e);
    }
  }

  @SuppressWarnings("unchecked")
  public void onSharedObjectSend(ISharedObjectBase arg0, String methodName, List args) {
    handleSharedObjectSend(methodName, args);
  }

  @SuppressWarnings("unchecked")
  private LinkedHashMap<Integer, Object> getMethodArgs(List args) {
    if (args == null) {
      logger.warn("getMethodArgs: args is null");
      return new LinkedHashMap<Integer, Object>();
    }
    
    if (args.size() > 2) {
      Object arg2 = args.get(2);
      if (arg2 instanceof LinkedHashMap) {
        return (LinkedHashMap<Integer, Object>) arg2;
      }
      if (arg2 instanceof List) {
        // Red5 0.8.x may provide method args as a List instead of a LinkedHashMap; adapt
        LinkedHashMap<Integer, Object> methodArgs = new LinkedHashMap<Integer, Object>();
        List list = (List) arg2;
        for (int i = 0; i < list.size(); i++) {
          methodArgs.put(i, list.get(i));
        }
        return methodArgs;
      }
    }
    logger.warn("getMethodArgs: args too small or wrong type: " + args);
    return new LinkedHashMap<Integer, Object>();
  }

  protected boolean executeServerMethods(
      String clientId, String methodName, LinkedHashMap<Integer, Object> args) {

    if (methodName == null) {
      return false;
    }

    try {
      Boolean interrup = (Boolean) ReflectUtil.callMethod(this, methodName, args.values());
      if (interrup != null && interrup) {
        logger.warn("interrup");
        return true; // handled and should interrupt client delivery
      }
      return true; // handled but no interrupt requested
    } catch (NoSuchMethodException e) {
      // No server-side handler for this method
    } catch (Exception e) {
      logger.error(e.getMessage(), e);
    }
    return false; // not handled on server
  }

  @SuppressWarnings("unchecked")
  protected void processSendState(
      LinkedHashMap<Integer, Object> methodArgs, String clientId, String stateName) {
    synchronized (state) {
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
      }
    }
  }

  @SuppressWarnings("unchecked")
  protected ObjectMap<String, Object> getStateObject(String clientId, String stateName) {
    synchronized (state) {
      forceKey(state, clientId);
      ObjectMap<String, Object> clientState = (ObjectMap<String, Object>) state.get(clientId);
      forceKey(clientState, stateName);
      ObjectMap<String, Object> stateObject = (ObjectMap<String, Object>) clientState.get(stateName);
      return stateObject;
    }
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
    synchronized (map) {
      if (!map.containsKey(key)) {
        map.put(key, new ObjectMap<String, Object>());
      }
    }
  }

  /**
   * Uses reflection to resolve a method name to its constant representation. Searches through all
   * static final String fields in this class to find a match.
   *
   * @param methodName the method name to resolve
   * @return the constant name if found, otherwise the original method name
   */
  private String resolveMethodNameToConstant(String methodName) {
    try {
      Field[] fields = this.getClass().getDeclaredFields();
      for (Field field : fields) {
        if (field.getType() == String.class
            && java.lang.reflect.Modifier.isStatic(field.getModifiers())
            && java.lang.reflect.Modifier.isFinal(field.getModifiers())) {
          field.setAccessible(true);
          String fieldValue = (String) field.get(null);
          if (methodName.equals(fieldValue)) {
            return field.getName();
          }
        }
      }
    } catch (Exception e) {
      logger.debug("Error resolving method name to constant: " + e.getMessage());
    }
    return methodName; // Return original if no constant found
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

  @SuppressWarnings("unchecked")
  public void beforeSharedObjectSend(ISharedObjectBase arg0, String methodName, List args) {
    // Kept for Red5 0.7.x compatibility; 0.8.x uses onSharedObjectSend instead
    handleSharedObjectSend(methodName, args);
  }

  @SuppressWarnings("unchecked")
  private void handleSharedObjectSend(String methodName, List args) {
    if (SEND_STATE.equals(methodName) || SEND.equals(methodName)) {
      // Add bounds checking for AMF3 compatibility
      if (args == null || args.size() < 2) {
        logger.warn("handleSharedObjectSend: insufficient arguments for " + methodName + ": " + args);
        return;
      }
      
      String clientId = (String) args.get(0);
      String clientMethodName = (String) args.get(1);
      LinkedHashMap<Integer, Object> methodArgs = getMethodArgs(args);
      
      if (methodName.equals(SEND_STATE)) {
        String stateName = (String) methodArgs.get(0);
        // Create a defensive copy to avoid concurrent modification during serialization
        LinkedHashMap<Integer, Object> methodArgsCopy = new LinkedHashMap<Integer, Object>(methodArgs);
        processSendState(methodArgsCopy, clientId, stateName);
        
        // Convert methodArgs back to a simple Array for client dispatch
        ArrayList<Object> flattenedArgs = new ArrayList<Object>();
        for (int i = 0; i < methodArgsCopy.size(); i++) {
          flattenedArgs.add(methodArgsCopy.get(i));
        }
        
        // Forward sanitized state updates to clients
        if (args.size() >= 3) {
          args.set(2, flattenedArgs);
        }
      } else { // SEND (oS)
        // Create a defensive copy to avoid concurrent modification during serialization
        LinkedHashMap<Integer, Object> methodArgsCopy = new LinkedHashMap<Integer, Object>(methodArgs);
        boolean handled = executeServerMethods(clientId, clientMethodName, methodArgsCopy);
        if (handled) {
          // Server handled this method; prevent client invocation by sending PREVENT marker
          ArrayList<Object> preventArgs = new ArrayList<Object>();
          preventArgs.add("PREVENT");
          if (args.size() >= 3) {
            args.set(2, preventArgs);
          }
        } else {
          // Normalize method arguments for client delivery: convert map to a simple Array
          ArrayList<Object> flattenedArgs = new ArrayList<Object>();
          for (int i = 0; i < methodArgsCopy.size(); i++) {
            flattenedArgs.add(methodArgsCopy.get(i));
          }
          if (args.size() >= 3) {
            args.set(2, flattenedArgs);
          }
        }
      }
    }
    if (methodName.equals(CLEAR)) {
      synchronized (state) {
        state.clear();
      }
      lockedStates.clear();
      connectedUsers.clear();
    }
  }
}
