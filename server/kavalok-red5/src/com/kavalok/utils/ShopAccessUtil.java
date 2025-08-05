package com.kavalok.utils;

import org.hibernate.Session;

import com.kavalok.dao.ShopDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.db.Shop;
import com.kavalok.db.User;
import com.kavalok.db.UserPermission;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;

public class ShopAccessUtil {

  /**
   * Gets the user's permission level based on their status
   * @param user The user to check
   * @return The user's permission level
   */
  private static UserPermission getUserPermission(User user) {
    if (Boolean.TRUE.equals(user.getSuperUser())) {
      return UserPermission.SUPERUSER;
    } else if (user.isModerator()) {
      return UserPermission.MODERATOR;
    } else if (user.isAgent()) {
      return UserPermission.AGENT;
    } else {
      return UserPermission.PUBLIC;
    }
  }

  /**
   * Checks if the current user has access to a shop/catalog
   * @param session The Hibernate session
   * @param shopName The name of the shop to check
   * @throws SecurityException if access is denied
   */
  public static void checkShopAccess(Session session, String shopName) {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    User user = new UserDAO(session).findById(userAdapter.getUserId());
    
    // Get user's permission level
    UserPermission userPermission = getUserPermission(user);
    
    // Check if shop is public
    ShopDAO shopDAO = new ShopDAO(session);
    Shop shop = shopDAO.findByName(shopName);
    
    if (shop == null) {
      throw new SecurityException("Shop not found: " + shopName);
    }
    
    // Check if user has sufficient permission
    if (!userPermission.isSufficient(shop.getRequiredPermission())) {
      throw new SecurityException("Access denied: Insufficient permission level");
    }
  }

  /**
   * Checks if the current user can buy from a shop
   * @param session The Hibernate session
   * @param shop The shop to check
   * @throws SecurityException if access is denied
   */
  public static void checkShopAccessForBuy(Session session, Shop shop) {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    User user = new UserDAO(session).findById(userAdapter.getUserId());
    
    // Get user's permission level
    UserPermission userPermission = getUserPermission(user);
    
    // Check if user has sufficient permission
    if (!userPermission.isSufficient(shop.getRequiredPermission())) {
      throw new SecurityException("Access denied: Insufficient permission level");
    }
  }
} 