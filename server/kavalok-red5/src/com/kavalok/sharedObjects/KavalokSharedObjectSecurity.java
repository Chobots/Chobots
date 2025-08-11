package com.kavalok.sharedObjects;

import java.util.List;
import java.util.Map;

import org.hibernate.Session;
import org.red5.io.utils.ObjectMap;
import org.red5.server.api.scope.IScope;
import org.red5.server.api.so.ISharedObject;
import org.red5.server.api.so.ISharedObjectSecurity;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.dao.UserDAO;
import com.kavalok.db.User;
import com.kavalok.services.ClothingValidationService;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.utils.HibernateUtil;

/**
 * Security handler for shared objects that implements permission logic previously contained in
 * SOListener.beforeSharedObjectSend
 */
public class KavalokSharedObjectSecurity implements ISharedObjectSecurity {

  private static Logger logger = Red5LoggerFactory.getLogger(KavalokSharedObjectSecurity.class);

  public KavalokSharedObjectSecurity() {}

  // Array of restricted rooms that require superuser access
  private static final String[] RESTRICTED_ROOMS = {"locSecret"};

  @Override
  public boolean isCreationAllowed(
      IScope scope, String name, boolean persistent) {
    // Allow creation by default
    return true;
  }

  @Override
  public boolean isConnectionAllowed(ISharedObject so) {
    String roomName = so.getName();

    if (isRestrictedRoom(roomName)) {
      if (!isUserSuperUser()) {
        logger.warn(
            "Non-superuser attempted to connect to restricted room: "
                + roomName
                + " - "
                + getCurrentUserLogin());
        return false;
      }
    }

    return true;
  }

  @Override
  public boolean isWriteAllowed(ISharedObject so, String key, Object value) {
    // Allow writes by default
    return true;
  }

  @Override
  public boolean isDeleteAllowed(ISharedObject so, String key) {
    // Allow deletes by default
    return true;
  }

  @Override
  public boolean isSendAllowed(ISharedObject so, String message, List arguments) {
    // Check if user is properly connected to this shared object
    if (!isUserConnectedToSharedObject(so)) {
      logger.warn(
          "User "
              + getCurrentUserLogin()
              + " attempted to send message without being connected to shared object: "
              + so.getName());
      kickOutUser("Unauthorized shared object access");
      return false;
    }

    if ("oS".equals(message) && arguments.size() > 1) {
      String actualMethodName = (String) arguments.get(1);

      if ("rCharAction".equals(actualMethodName)) {
        Object parameters = arguments.get(2);
        if (parameters instanceof java.util.Map) {
          java.util.Map<Object, Object> params = (java.util.Map<Object, Object>) parameters;
          String className = (String) params.get(1); // The action class name (Integer key)

          if (className != null
              && (className.contains("::LoadExternalContent")
                  || className.contains("::CharPropertyAction")
                  || className.contains("::CharsModifierAction")
                  || className.contains("::LocationPropertyAction")
                  || className.contains("::PropertyActionBase")
                  || className.contains("::CharsPropertyAction"))) {
            if (!isUserSuperUser()) {
              logger.warn(
                  "Non-superuser attempted rCharAction: "
                      + className
                      + " - "
                      + getCurrentUserLogin());
              kickOutUser("Unauthorized rCharAction: " + className);
              return false;
            }
          }
        }
      }
    }

    if ("rExecuteCommand".equals(message)) {
      Object commandObj = arguments.get(0);
      if (commandObj instanceof ObjectMap) {
        ObjectMap<String, Object> command = (ObjectMap<String, Object>) commandObj;
        String className = (String) command.get("className");

        if ("com.kavalok.location.commands::MoveCharCommand".equals(className)
            || "com.kavalok.location.commands::MoveToLocCommand".equals(className)
            || "com.kavalok.location.commands::FlyingPromoCommand".equals(className)
            || "com.kavalok.location.commands::PlaySwfCommand".equals(className)
            || "com.kavalok.location.commands::StuffRainCommand".equals(className)) {
          if (!isUserSuperUser()) {
            logger.warn(
                "Non-superuser attempted command: " + className + " - " + getCurrentUserLogin());
            kickOutUser("Unauthorized command: " + className);
            return false;
          }
        }
      }
    }

    if ("rResetObjectPositions".equals(message)) {
      if (!isUserSuperUser()) {
        logger.warn("Non-superuser attempted rResetObjectPositions: " + getCurrentUserLogin());
        kickOutUser("Unauthorized rResetObjectPositions");
        return false;
      }
    }

    // Check for character state updates (clothing validation)
    if ("oSS".equals(message)) {
      String stateName = (String) arguments.get(0);

      // Check if this is a character state update (includes movement, model changes, clothing,
      // etc.)
      if (stateName != null && stateName.startsWith("char_")) {
        // Validate character ownership - ensure user can only control their own character
        String targetCharId = (String) arguments.get(0);
        String currentUserLogin = getCurrentUserLogin();
        String expectedCharId = "char_" + currentUserLogin;

        if (!targetCharId.equals(expectedCharId)) {
          logger.warn(
              "User "
                  + currentUserLogin
                  + " attempted to control character "
                  + targetCharId
                  + " - blocking unauthorized character control");
          kickOutUser("Unauthorized character control: " + targetCharId);
          return false;
        }

        // Additional validation: ensure the state name format is correct
        if (!stateName.matches("char_[a-zA-Z0-9_]+")) {
          logger.warn(
              "User "
                  + currentUserLogin
                  + " attempted to send invalid character state name: "
                  + stateName
                  + " - blocking invalid state name");
          kickOutUser("Invalid character state name: " + stateName);
          return false;
        }

        Object stateData = arguments.get(1);
        if (stateData instanceof ObjectMap) {
          ObjectMap<String, Object> stateObject = (ObjectMap<String, Object>) stateData;

          // Check if clothing data is present and validate it
          if (stateObject.containsKey("cl")) {
            Object clothingData = stateObject.get("cl");
            if (clothingData instanceof Map) {
              @SuppressWarnings("unchecked")
              Map<Integer, ObjectMap<String, Object>> clothes =
                  (Map<Integer, ObjectMap<String, Object>>) clothingData;

              // Validate clothing data
              try {
                ClothingValidationService validationService =
                    ClothingValidationService.createValidationService();

                Session session = HibernateUtil.getSessionFactory().openSession();
                try {
                  validationService.validateSharedObjectClothingData(clothes, session);
                } finally {
                  if (session != null && session.isOpen()) {
                    session.close();
                  }
                }
              } catch (SecurityException e) {
                UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
                String userLogin = userAdapter.getLogin();
                Long userId = userAdapter.getUserId();

                logger.error(
                    "Clothing validation failed for user "
                        + userLogin
                        + " (ID: "
                        + userId
                        + ") in isSendAllowed: "
                        + e.getMessage()
                        + ". Blocking shared object send.");

                kickOutUser("Clothing validation failed: " + e.getMessage());
                return false;
              }
            }
          }
        }
      }
    }

    return true;
  }

  private boolean isUserSuperUser() {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    if (adapter == null) {
      return false;
    }

    Session session = null;
    try {
      session = HibernateUtil.getSessionFactory().openSession();
      UserDAO userDAO = new UserDAO(session);
      User user = userDAO.findById(adapter.getUserId());
      if (user == null) {
        return false;
      }

      return Boolean.TRUE.equals(user.getSuperUser());
    } catch (Exception e) {
      logger.error("Error checking superuser status: " + e.getMessage(), e);
      return false;
    } finally {
      if (session != null && session.isOpen()) {
        session.close();
      }
    }
  }

  private String getCurrentUserLogin() {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    return adapter != null ? adapter.getLogin() : "unknown";
  }

  private boolean isRestrictedRoom(String roomName) {
    for (String restrictedRoom : RESTRICTED_ROOMS) {
      if (restrictedRoom.equals(roomName)) {
        return true;
      }
    }
    return false;
  }

  private boolean isUserConnectedToSharedObject(ISharedObject so) {
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    if (adapter == null) {
      return false;
    }

    SOListener listener = SOListener.getListener(so);

    if (listener == null) {
      return false;
    }

    // Check if the current user is in the connected users list
    String currentUserLogin = getCurrentUserLogin();
    return listener.getConnectedChars().contains(currentUserLogin);
  }

  private String getStackTrace() {
    StringBuilder sb = new StringBuilder();
    StackTraceElement[] elements = Thread.currentThread().getStackTrace();
    for (int i = 0; i < Math.min(elements.length, 10); i++) {
      sb.append(elements[i].toString()).append("\n");
    }
    return sb.toString();
  }

  private void kickOutUser(String reason) {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (userAdapter != null) {
      logger.warn("Kicking out user " + userAdapter.getLogin() + " for reason: " + reason);
      userAdapter.kickOut(reason, false);
    }
  }
}
