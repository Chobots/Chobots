package com.kavalok.services;

import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

import org.hibernate.Session;
import org.red5.io.utils.ObjectMap;
import org.red5.server.api.so.ISharedObject;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

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
import com.kavalok.xmlrpc.RemoteClient;
import com.kavalok.xmlrpc.RemoteServer;

public class RainCommandService {

  private static final Logger logger = Red5LoggerFactory.getLogger(RainCommandService.class);

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
    Server currentServer = KavalokApplication.getInstance().getServer();

    // Get the current user adapter for access type checking
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();

    if ("admin".equals(source)
        && serverId != null
        && remoteId != null
        && AccessAdmin.class.equals(userAdapter.getAccessType())) {
      // Admin rain: target specific location on selected servers
      triggerAdminRain(session, stuffType, count, serverId, remoteId);
    } else if ("magic".equals(source)) {
      // Magic rain: use current user's location
      triggerMagicRain(session, stuffType, count, userAdapter);
    } else {
      // Invalid source
      logger.error("Invalid rain source: " + source + ". Only 'admin' and 'magic' are supported.");
    }
  }

  private static void triggerAdminRain(
      Session session, StuffType stuffType, Integer count, Integer serverId, String remoteId) {
    // Get the list of target servers based on serverId
    List<Server> targetServers = getServerList(session, serverId);
    
    // For each target server, trigger rain on the location
    for (Server targetServer : targetServers) {
      try {
        logger.info("Triggering rain on server " + targetServer.getId() + " for location " + remoteId);
        
        // Use RemoteClient to call the triggerRainOnLocation method on the target server
        RemoteClient remoteClient = new RemoteClient(targetServer);
        remoteClient.triggerRainOnLocation(remoteId, stuffType.getFileName(), count.intValue());
        
        logger.info("Successfully triggered rain on server " + targetServer.getId() + " for location " + remoteId);
      } catch (Exception e) {
        logger.error("Failed to trigger rain on server " + targetServer.getId() + " for location " + remoteId, e);
      }
    }
  }

  private static void triggerMagicRain(Session session, StuffType stuffType, Integer count, UserAdapter userAdapter) {
    // Get the user's current location from their shared objects
    List<String> userSharedObjects = userAdapter.getSharedObjects();

    if (userSharedObjects.isEmpty()) {
      logger.warn("User has no shared objects - cannot determine location");
      return;
    }

    // Use the first shared object as the user's current location
    String userLocation = userSharedObjects.get(0);

    // Get the shared object to access connected users
    ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(userLocation);
    if (sharedObject == null) {
      logger.warn("Shared object not found for location: " + userLocation);
      return;
    }

    SOListener listener = SOListener.getListener(sharedObject);
    List<String> connectedUsers = listener.getConnectedChars();

    // Send rain commands to all connected users
    sendRainCommandsToUsers(connectedUsers, stuffType, count);
  }

  public static void sendRainCommandsToUsers(List<String> connectedUsers, StuffType stuffType, Integer count) {
    for (String userLogin : connectedUsers) {
      for (int i = 0; i < count; i++) {
        // Generate unique color for this specific user and item
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
  
  /**
   * Get the list of target servers based on serverId.
   * 
   * @param session The Hibernate session
   * @param serverId The server ID (-1 for all available servers, otherwise specific server)
   * @return List of target servers
   */
  private static List<Server> getServerList(Session session, Integer serverId) {
    List<Server> result;
    if (serverId.equals(-1)) {
      result = new ServerDAO(session).findAvailable();
    } else {
      result = new java.util.ArrayList<Server>();
      result.add(new ServerDAO(session).findById(Long.valueOf(serverId), false));
    }
    return result;
  }
}
