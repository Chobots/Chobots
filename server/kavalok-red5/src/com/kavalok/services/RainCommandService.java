package com.kavalok.services;

import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

import org.hibernate.Session;
import org.red5.io.utils.ObjectMap;
import org.red5.server.api.so.ISharedObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.ServerDAO;
import com.kavalok.dao.StuffTypeDAO;
import com.kavalok.db.Server;
import com.kavalok.db.StuffType;
import com.kavalok.permissions.AccessAdmin;
import com.kavalok.services.stuff.RainTokenManager;
import com.kavalok.sharedObjects.SOListener;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.xmlrpc.RemoteServer;

public class RainCommandService {

  private static final Logger logger = LoggerFactory.getLogger(RainCommandService.class);

  /**
   * Generates rain tokens and sends rain commands to all connected users.
   *
   * @param session The Hibernate session to use for database operations
   * @param fileName The file name of the item to rain
   * @param count The number of items to rain per user
   * @param source The source of the rain event (e.g., "admin", "magic")
   * @throws IllegalArgumentException if the item is not rainable
   */
  public static void triggerRainEvent(
      Session session, String fileName, Integer count, String source) {
    triggerRainEvent(session, fileName, count, source, null, null);
  }

  /**
   * Generates rain tokens and sends rain commands to a specific location (for admin rain).
   *
   * @param session The Hibernate session to use for database operations
   * @param fileName The file name of the item to rain
   * @param count The number of items to rain per user
   * @param source The source of the rain event (e.g., "admin", "magic")
   * @param serverId The server ID to target (for admin rain)
   * @param remoteId The location ID to target (for admin rain)
   * @throws IllegalArgumentException if the item is not rainable
   */
  public static void triggerRainEvent(
      Session session,
      String fileName,
      Integer count,
      String source,
      Integer serverId,
      String remoteId) {
    // Get the stuff type
    StuffTypeDAO stuffTypeDAO = new StuffTypeDAO(session);
    StuffType stuffType = stuffTypeDAO.findByFileName(fileName);

    if (stuffType == null || !stuffType.getRainable()) {
      throw new IllegalArgumentException("Item is not rainable: " + fileName);
    }

    // Get current server
    ServerDAO serverDAO = new ServerDAO(session);
    Server currentServer =
        serverDAO.findByScopeName(KavalokApplication.getInstance().getCurrentServerPath());

    List<String> connectedUsers;
    String userLocation;

    // Get the current user adapter for access type checking
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();

    if ("admin".equals(source)
        && serverId != null
        && remoteId != null
        && AccessAdmin.class.equals(userAdapter.getAccessType())) {
      // Admin rain: target specific location
      userLocation = remoteId;

      // Get the shared object to access connected users
      ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(userLocation);
      if (sharedObject == null) {
        logger.warn("Shared object not found for location: " + userLocation);
        return;
      }

      SOListener listener = SOListener.getListener(sharedObject);
      connectedUsers = listener.getConnectedChars();
    } else if ("magic".equals(source)) {
      // Magic rain: use current user's location
      // Get the user's current location from their shared objects
      List<String> userSharedObjects = userAdapter.getSharedObjects();

      if (userSharedObjects.isEmpty()) {
        logger.warn("User has no shared objects - cannot determine location");
        return;
      }

      // Use the first shared object as the user's current location
      userLocation = userSharedObjects.get(0);

      // Get the shared object to access connected users
      ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(userLocation);
      if (sharedObject == null) {
        logger.warn("Shared object not found for location: " + userLocation);
        return;
      }

      SOListener listener = SOListener.getListener(sharedObject);
      connectedUsers = listener.getConnectedChars();
    } else {
      // Invalid source
      logger.error("Invalid rain source: " + source + ". Only 'admin' and 'magic' are supported.");
      return;
    }

    // Generate unique tokens and colors for each user, for each item
    for (String userLogin : connectedUsers) {
      for (int i = 0; i < count; i++) {
        // Generate unique color for this specific user and item
        // Use userLogin + itemId + iteration to ensure uniqueness
        int uniqueColor = ThreadLocalRandom.current().nextInt(0xFFFFFF);

        // Generate unique token for this specific user and item with the color
        String rainToken =
            RainTokenManager.getInstance().generateToken(stuffType.getId().intValue(), uniqueColor);

        // Create rain command with token and color for this specific user
        ObjectMap<String, Object> rainCommand = new ObjectMap<String, Object>();
        rainCommand.put("className", "com.kavalok.location.commands::StuffRainCommand");
        rainCommand.put("itemId", stuffType.getId());
        rainCommand.put("fileName", stuffType.getFileName());
        rainCommand.put("stuffType", stuffType.getType());
        rainCommand.put("rainToken", rainToken);
        rainCommand.put("color", uniqueColor);

        try {
          new RemoteServer().sendCommand(userLogin, "StuffRainServerCommand", rainCommand);
        } catch (Exception e) {
          logger.error("Failed to send command to user: " + userLogin, e);
        }
      }
    }
  }
}
