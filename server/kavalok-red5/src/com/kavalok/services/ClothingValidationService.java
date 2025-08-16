package com.kavalok.services;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.red5.io.utils.ObjectMap;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.dao.StuffItemDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.db.GameChar;
import com.kavalok.db.StuffItem;
import com.kavalok.db.User;
import com.kavalok.services.common.DataServiceBase;
import com.kavalok.services.stuff.StuffTypes;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;

/**
 * Service for validating clothing items to ensure security and data integrity. Addresses three main
 * security concerns: 1. Ownership verification - ensures users only broadcast clothes they own 2.
 * Item existence check - validates that clothing items exist in database 3. Data integrity -
 * prevents client-side manipulation
 */
public class ClothingValidationService extends DataServiceBase {

  private static final Logger logger = Red5LoggerFactory.getLogger(ClothingValidationService.class);

  /**
   * Validates that a user owns the clothing items they're trying to broadcast.
   *
   * @param clothesData The clothing data from the client
   * @param session The Hibernate session to use
   * @return Validated clothing data with only items the user actually owns
   * @throws SecurityException if validation fails
   */
  public Map<Integer, ObjectMap<String, Object>> validateClothingOwnership(
      Map<Integer, ObjectMap<String, Object>> clothesData, org.hibernate.Session session) {

    // Check if clothing data is empty
    if (clothesData == null || clothesData.isEmpty()) {
      // Check if user actually has clothing items in database
      UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
      if (userAdapter == null) {
        throw new SecurityException("User not authenticated");
      }

      User user = new UserDAO(session).findById(userAdapter.getUserId());
      if (user == null) {
        throw new SecurityException("User not found in database");
      }

      GameChar gameChar = user.getGameChar();
      if (gameChar == null) {
        throw new SecurityException("Game character not found for user");
      }

      // Check if user has any clothing items in database
      List<StuffItem> ownedItems = gameChar.getStuffItems();
      boolean hasClothingItems = false;
      for (StuffItem item : ownedItems) {
        try {
          if (StuffTypes.CLOTHES.equals(item.getType().getType())) {
            hasClothingItems = true;
            break;
          }
        } catch (org.hibernate.ObjectNotFoundException e) {
          // Race condition: StuffType was deleted from database after StuffItem was loaded
          logger.warn("StuffType for StuffItem {} was deleted from database - skipping orphaned item", item.getId());
          continue;
        }
      }

      if (hasClothingItems) {
        // User has clothing items but sent empty data - this is suspicious
        logger.warn(
            "User "
                + user.getLogin()
                + " has clothing items but sent empty clothing data - possible security violation");
        throw new SecurityException("Empty clothing data from user with clothing items");
      } else {
        // User has no clothing items, so empty data is legitimate
        logger.debug(
            "Empty clothing data received from user "
                + user.getLogin()
                + " - user has no clothing items");
        return new HashMap<>();
      }
    }

    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (userAdapter == null) {
      throw new SecurityException("User not authenticated");
    }

    User user = new UserDAO(session).findById(userAdapter.getUserId());
    if (user == null) {
      throw new SecurityException("User not found in database");
    }

    GameChar gameChar = user.getGameChar();
    if (gameChar == null) {
      throw new SecurityException("Game character not found for user");
    }

    // Get all items the user actually owns
    List<StuffItem> ownedItems = gameChar.getStuffItems();
    Map<Long, StuffItem> ownedItemsMap = new HashMap<>();
    for (StuffItem item : ownedItems) {
      ownedItemsMap.put(item.getId(), item);
    }

    // Validate each clothing item
    Map<Integer, ObjectMap<String, Object>> validatedClothes = new HashMap<>();

    for (Map.Entry<Integer, ObjectMap<String, Object>> entry : clothesData.entrySet()) {
      ObjectMap<String, Object> clothe = entry.getValue();
      Integer itemId = (Integer) clothe.get("id");

      if (itemId == null) {
        throw new SecurityException("Clothing item missing ID");
      }

      Long longItemId = Long.valueOf(itemId);
      StuffItem ownedItem = ownedItemsMap.get(longItemId);

      if (ownedItem == null) {
        throw new SecurityException(
            "User attempting to use clothing item they don't own: " + itemId);
      }

      // Additional validation: ensure it's actually a clothing item
      try {
        if (!StuffTypes.CLOTHES.equals(ownedItem.getType().getType())) {
          throw new SecurityException(
              "User attempting to use non-clothing item as clothing: " + itemId);
        }
      } catch (org.hibernate.ObjectNotFoundException e) {
        // Race condition: StuffType was deleted from database after StuffItem was loaded
        logger.warn("StuffType for StuffItem {} was deleted from database - user cannot use orphaned item", itemId);
        throw new SecurityException(
            "Clothing item type no longer exists in database: " + itemId);
      }

      // Validation passed - add to validated clothes
      validatedClothes.put(entry.getKey(), clothe);
    }

    return validatedClothes;
  }

  /**
   * Validates that clothing items exist in the database and are valid.
   *
   * @param itemIds List of item IDs to validate
   * @param session The Hibernate session to use
   * @return Map of valid item IDs to their StuffItem objects
   * @throws SecurityException if validation fails
   */
  public Map<Long, StuffItem> validateItemExistence(
      List<Long> itemIds, org.hibernate.Session session) {
    if (itemIds == null || itemIds.isEmpty()) {
      return new HashMap<>();
    }

    if (session == null) {
      throw new SecurityException("No session provided for clothing validation");
    }

    StuffItemDAO itemDAO = new StuffItemDAO(session);
    Map<Long, StuffItem> validItems = new HashMap<>();

    for (Long itemId : itemIds) {
      if (itemId == null) {
        continue;
      }

      StuffItem item = itemDAO.findById(itemId, false);
      if (item == null) {
        throw new SecurityException("Clothing item does not exist in database: " + itemId);
      }

      // Validate item type - handle race condition where StuffType was deleted
      try {
        if (!StuffTypes.CLOTHES.equals(item.getType().getType())) {
          throw new SecurityException("Item is not a clothing item: " + itemId);
        }
      } catch (org.hibernate.ObjectNotFoundException e) {
        // Race condition: StuffType was deleted from database after StuffItem was loaded
        logger.warn("StuffType for StuffItem {} was deleted from database - removing orphaned item", itemId);
        throw new SecurityException("Clothing item type no longer exists in database: " + itemId);
      }

      validItems.put(itemId, item);
    }

    return validItems;
  }

  /**
   * Validates clothing data integrity and prevents client-side manipulation.
   *
   * @param clothesData The clothing data from client
   * @return Sanitized and validated clothing data
   * @throws SecurityException if data integrity check fails
   */
  public Map<Integer, ObjectMap<String, Object>> validateDataIntegrity(
      Map<Integer, ObjectMap<String, Object>> clothesData) {

    if (clothesData == null) {
      return new HashMap<>();
    }

    Map<Integer, ObjectMap<String, Object>> sanitizedData = new HashMap<>();

    for (Map.Entry<Integer, ObjectMap<String, Object>> entry : clothesData.entrySet()) {
      ObjectMap<String, Object> clothe = entry.getValue();

      // Validate required fields
      if (!validateRequiredFields(clothe)) {
        throw new SecurityException("Clothing item missing required fields");
      }

      // Validate data types and ranges
      if (!validateDataTypes(clothe)) {
        throw new SecurityException("Clothing item has invalid data types");
      }

      // Sanitize the data
      ObjectMap<String, Object> sanitizedClothe = sanitizeClothingData(clothe);
      sanitizedData.put(entry.getKey(), sanitizedClothe);
    }

    return sanitizedData;
  }

  /** Validates that all required fields are present in clothing data. */
  private boolean validateRequiredFields(ObjectMap<String, Object> clothe) {
    return clothe.containsKey("id")
        && clothe.containsKey("used")
        && clothe.containsKey("x")
        && clothe.containsKey("y");
  }

  /** Validates data types and ranges for clothing data. */
  private boolean validateDataTypes(ObjectMap<String, Object> clothe) {
    try {
      // Validate ID
      Object idObj = clothe.get("id");
      if (!(idObj instanceof Integer) && !(idObj instanceof Long)) {
        return false;
      }

      // Validate used flag
      Object usedObj = clothe.get("used");
      if (!(usedObj instanceof Boolean)) {
        return false;
      }

      // Validate coordinates
      Object xObj = clothe.get("x");
      Object yObj = clothe.get("y");
      if (!(xObj instanceof Integer) || !(yObj instanceof Integer)) {
        return false;
      }

      // Validate coordinate ranges (reasonable bounds)
      Integer x = (Integer) xObj;
      Integer y = (Integer) yObj;
      if (x < -1000 || x > 1000 || y < -1000 || y > 1000) {
        return false;
      }

      return true;
    } catch (Exception e) {
      return false;
    }
  }

  /** Sanitizes clothing data to prevent injection and ensure consistency. */
  private ObjectMap<String, Object> sanitizeClothingData(ObjectMap<String, Object> clothe) {
    ObjectMap<String, Object> sanitized = new ObjectMap<>();

    // Copy only allowed fields
    sanitized.put("id", clothe.get("id"));
    sanitized.put("used", clothe.get("used"));
    sanitized.put("x", clothe.get("x"));
    sanitized.put("y", clothe.get("y"));

    return sanitized;
  }

  /**
   * Validates shared object clothing data format (p=placement, c=color, n=fileName). This is used
   * for validating clothing data sent through shared objects.
   *
   * @param clothesData The clothing data from shared object (with p, c, n fields)
   * @param session The Hibernate session to use
   * @return Validated clothing data
   * @throws SecurityException if validation fails
   */
  public Map<Integer, ObjectMap<String, Object>> validateSharedObjectClothingData(
      Map<Integer, ObjectMap<String, Object>> clothesData, org.hibernate.Session session) {

    // Check if clothing data is empty
    if (clothesData == null || clothesData.isEmpty()) {
      // Check if user actually has clothing items in database
      UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
      if (userAdapter == null) {
        throw new SecurityException("User not authenticated");
      }

      User user = new UserDAO(session).findById(userAdapter.getUserId());
      if (user == null) {
        throw new SecurityException("User not found in database");
      }

      GameChar gameChar = user.getGameChar();
      if (gameChar == null) {
        throw new SecurityException("Game character not found for user");
      }

      // Check if user has any clothing items in database
      List<StuffItem> ownedItems = gameChar.getStuffItems();
      boolean hasClothingItems = false;
      for (StuffItem item : ownedItems) {
        try {
          if (StuffTypes.CLOTHES.equals(item.getType().getType())) {
            hasClothingItems = true;
            break;
          }
        } catch (org.hibernate.ObjectNotFoundException e) {
          // Race condition: StuffType was deleted from database after StuffItem was loaded
          logger.warn("StuffType for StuffItem {} was deleted from database - skipping orphaned item", item.getId());
          continue;
        }
      }

      if (hasClothingItems) {
        // User has clothing items but sent empty data - this is suspicious
        logger.warn(
            "User "
                + user.getLogin()
                + " has clothing items but sent empty clothing data - possible security violation");
        throw new SecurityException("Empty clothing data from user with clothing items");
      } else {
        // User has no clothing items, so empty data is legitimate
        logger.debug(
            "Empty clothing data received from user "
                + user.getLogin()
                + " - user has no clothing items");
        return new HashMap<>();
      }
    }

    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (userAdapter == null) {
      throw new SecurityException("User not authenticated");
    }

    User user = new UserDAO(session).findById(userAdapter.getUserId());
    if (user == null) {
      throw new SecurityException("User not found in database");
    }

    GameChar gameChar = user.getGameChar();
    if (gameChar == null) {
      throw new SecurityException("Game character not found for user");
    }

    // Get all clothing items the user actually owns
    List<StuffItem> ownedItems = gameChar.getStuffItems();
    Map<String, StuffItem> ownedClothingByFileName = new HashMap<>();
    for (StuffItem item : ownedItems) {
      try {
        if (StuffTypes.CLOTHES.equals(item.getType().getType())) {
          // Use fileName as key since that's what we get from the client
          String fileName = item.getType().getFileName();
          if (fileName != null) {
            ownedClothingByFileName.put(fileName, item);
          }
        }
      } catch (org.hibernate.ObjectNotFoundException e) {
        // Race condition: StuffType was deleted from database after StuffItem was loaded
        logger.warn("StuffType for StuffItem {} was deleted from database - skipping orphaned item", item.getId());
        continue;
      }
    }

    // Validate each clothing item
    Map<Integer, ObjectMap<String, Object>> validatedClothes = new HashMap<>();

    for (Map.Entry<Integer, ObjectMap<String, Object>> entry : clothesData.entrySet()) {
      ObjectMap<String, Object> clothe = entry.getValue();

      // Validate required fields for shared object format
      if (!validateSharedObjectRequiredFields(clothe)) {
        throw new SecurityException("Clothing item missing required fields (p, c, n)");
      }

      // Validate data types for shared object format
      if (!validateSharedObjectDataTypes(clothe)) {
        throw new SecurityException("Clothing item has invalid data types");
      }

      // Get the fileName from the 'n' field and color from 'c' field
      String fileName = (String) clothe.get("n");
      Integer color = (Integer) clothe.get("c");

      if (fileName == null || color == null) {
        throw new SecurityException("Invalid clothing item data: missing fileName or color");
      }

      // Check if user owns a clothing item with this fileName
      StuffItem ownedItem = ownedClothingByFileName.get(fileName);
      if (ownedItem == null) {
        throw new SecurityException(
            "User attempting to use clothing item they don't own: " + fileName);
      }

      // Additional validation: ensure the color matches (optional - some items might have different
      // colors)
      // For now, we'll just validate ownership by fileName
      // TODO: Add color validation if needed

      // Validation passed - add to validated clothes
      validatedClothes.put(entry.getKey(), clothe);
    }

    return validatedClothes;
  }

  /** Validates that all required fields are present in shared object clothing data. */
  private boolean validateSharedObjectRequiredFields(ObjectMap<String, Object> clothe) {
    return clothe.containsKey("p") // placement
        && clothe.containsKey("c") // color/id
        && clothe.containsKey("n"); // name
  }

  /** Validates data types and ranges for shared object clothing data. */
  private boolean validateSharedObjectDataTypes(ObjectMap<String, Object> clothe) {
    try {
      // Validate placement (p)
      Object placementObj = clothe.get("p");
      if (!(placementObj instanceof String)) {
        return false;
      }

      // Validate color/id (c)
      Object colorIdObj = clothe.get("c");
      if (!(colorIdObj instanceof Integer) && !(colorIdObj instanceof Long)) {
        return false;
      }

      // Validate name (n)
      Object nameObj = clothe.get("n");
      if (!(nameObj instanceof String)) {
        return false;
      }

      // Validate placement string length
      String placement = (String) placementObj;
      if (placement.length() > 10) {
        return false;
      }

      // Validate name string length
      String name = (String) nameObj;
      if (name.length() > 50) {
        return false;
      }

      return true;
    } catch (Exception e) {
      return false;
    }
  }

  /**
   * Comprehensive validation method that combines all security checks with explicit session.
   *
   * @param clothesData Raw clothing data from client
   * @param session The Hibernate session to use
   * @return Fully validated and sanitized clothing data
   * @throws SecurityException if any validation fails
   */
  public Map<Integer, ObjectMap<String, Object>> validateClothingData(
      Map<Integer, ObjectMap<String, Object>> clothesData, org.hibernate.Session session) {

    // Step 1: Validate data integrity
    Map<Integer, ObjectMap<String, Object>> integrityValidated = validateDataIntegrity(clothesData);

    // If integrity validation returns empty, it means no clothing data to validate
    if (integrityValidated.isEmpty()) {
      return integrityValidated;
    }

    // Step 2: Validate item existence
    List<Long> itemIds = new ArrayList<>();
    for (ObjectMap<String, Object> clothe : integrityValidated.values()) {
      Object idObj = clothe.get("id");
      if (idObj instanceof Integer) {
        itemIds.add(Long.valueOf((Integer) idObj));
      } else if (idObj instanceof Long) {
        itemIds.add((Long) idObj);
      }
    }

    Map<Long, StuffItem> existingItems = validateItemExistence(itemIds, session);

    // Step 3: Validate ownership
    Map<Integer, ObjectMap<String, Object>> ownershipValidated =
        validateClothingOwnership(integrityValidated, session);

    return ownershipValidated;
  }

  /**
   * Creates a validation service instance that can be used outside of the service framework. This
   * method should be used when the service is not being called through the normal service
   * framework.
   *
   * @return A new ClothingValidationService instance
   */
  public static ClothingValidationService createValidationService() {
    return new ClothingValidationService();
  }
}
