package com.kavalok.utils;

import org.hibernate.Session;

import com.kavalok.dao.ShopDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.db.Shop;
import com.kavalok.db.User;
import com.kavalok.db.UserPermission;
import com.kavalok.permissions.AccessAdmin;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;

public class ShopAccessUtil {

  /**
   * Gets the user's permission level based on their status
   *
   * @param userAdapter The user adapter to check
   * @return The user's permission level
   */
  private static UserPermission getUserPermission(UserAdapter userAdapter) {
    // Check if user is logged in as an admin - admins get full access
    if (AccessAdmin.class.equals(userAdapter.getAccessType())) {
      return UserPermission.SUPERUSER;
    }

    // Regular user permission checks
    Session session = null;
    try {
      session = HibernateUtil.getSessionFactory().openSession();
      UserDAO userDAO = new UserDAO(session);
      User user = userDAO.findById(userAdapter.getUserId());

      if (user != null) {
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
    } catch (Exception e) {
      org.slf4j.LoggerFactory.getLogger(ShopAccessUtil.class)
          .error("Error checking user privileges", e);
    } finally {
      if (session != null && session.isOpen()) {
        session.close();
      }
    }

    // Default to PUBLIC if we can't determine the user's permission
    return UserPermission.PUBLIC;
  }

  /**
   * Checks if the current user has access to a shop/catalog
   *
   * @param session The Hibernate session
   * @param shopName The name of the shop to check
   * @throws SecurityException if access is denied
   */
  public static void checkShopAccess(Session session, String shopName) {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();

    // Get user's permission level
    UserPermission userPermission = getUserPermission(userAdapter);

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
   *
   * @param session The Hibernate session
   * @param shop The shop to check
   * @throws SecurityException if access is denied
   */
  public static void checkShopAccessForBuy(Session session, Shop shop) {
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();

    // Get user's permission level
    UserPermission userPermission = getUserPermission(userAdapter);

    // Check if user has sufficient permission
    if (!userPermission.isSufficient(shop.getRequiredPermission())) {
      throw new SecurityException("Access denied: Insufficient permission level");
    }
  }
}
