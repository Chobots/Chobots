package com.kavalok.services.common;

import java.lang.reflect.Method;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.dao.AdminDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.db.Admin;
import com.kavalok.db.User;
import com.kavalok.permissions.AccessAdmin;
import com.kavalok.permissions.RequireAdmin;
import com.kavalok.permissions.RequireModerator;
import com.kavalok.permissions.RequireSuperUser;
import com.kavalok.permissions.RequirePermissionLevel;
import com.kavalok.permissions.RequireExternalMod;
import com.kavalok.permissions.RequirePartner;
import com.kavalok.permissions.RequireHalfMod;
import com.kavalok.permissions.RequireMod;
import com.kavalok.permissions.RequireSuperMod;
import com.kavalok.user.UserAdapter;

/**
 * Base class for admin services that provides automatic access control.
 * Methods annotated with privilege annotations will automatically check for appropriate privileges.
 * 
 * Permission Levels (0-4):
 * - 0: EXTERNAL_MODER - External moderators
 * - 1: PARTNER - Partners
 * - 2: HALF_MODER - Half moderators  
 * - 3: MOD - Full moderators
 * - 4: SUPER_MOD - Super moderators (superusers)
 * 
 * Access is granted to:
 * - Users with AccessAdmin.class access type (admin users) - have access based on their permission level
 * - Regular users with moderator=true - equivalent to MOD level (3)
 * - Regular users with superUser=true - equivalent to SUPER_MOD level (4)
 */
public abstract class AdminServiceBase extends DataServiceBase {
    
    private static final Logger logger = LoggerFactory.getLogger(AdminServiceBase.class);
    
    // Permission level constants matching client-side PermissionLevels
    public static final int EXTERNAL_MODER = 0;
    public static final int PARTNER = 1;
    public static final int HALF_MODER = 2;
    public static final int MOD = 3;
    public static final int SUPER_MOD = 4;
    
    /**
     * Checks if the current user has admin access.
     * Access is granted to:
     * - Users with AccessAdmin.class access type (admin users)
     * - Regular users with moderator=true
     * - Regular users with superUser=true
     * 
     * @return true if the user has admin access, false otherwise
     */
    protected boolean checkAdminAccess() {
        return checkPrivilegeLevel(PrivilegeLevel.ADMIN);
    }
    
    /**
     * Checks if the current user has moderator access.
     * Access is granted to:
     * - Users with AccessAdmin.class access type (admin users)
     * - Regular users with moderator=true
     * - Regular users with superUser=true
     * 
     * @return true if the user has moderator access, false otherwise
     */
    protected boolean checkModeratorAccess() {
        return checkPrivilegeLevel(PrivilegeLevel.MODERATOR);
    }
    
    /**
     * Checks if the current user has superUser access.
     * Access is granted to:
     * - Users with AccessAdmin.class access type (admin users)
     * - Regular users with superUser=true
     * 
     * @return true if the user has superUser access, false otherwise
     */
    protected boolean checkSuperUserAccess() {
        return checkPrivilegeLevel(PrivilegeLevel.SUPER_USER);
    }
    
    /**
     * Checks if the current user has the specified permission level.
     * 
     * @param requiredLevel the minimum permission level required (0-4)
     * @return true if the user has the required permission level, false otherwise
     */
    protected boolean checkPermissionLevel(int requiredLevel) {
        return checkPrivilegeLevel(PrivilegeLevel.PERMISSION_LEVEL, requiredLevel);
    }
    
    /**
     * Internal method to check privilege levels
     */
    private boolean checkPrivilegeLevel(PrivilegeLevel requiredLevel) {
        return checkPrivilegeLevel(requiredLevel, 0);
    }
    
    /**
     * Internal method to check privilege levels with specific permission level
     */
    private boolean checkPrivilegeLevel(PrivilegeLevel requiredLevel, int permissionLevel) {
        UserAdapter userAdapter = getAdapter();
        if (userAdapter == null) {
            logger.warn("Unauthorized access attempt by unknown user");
            return false;
        }
        
        // Check if user has admin access type
        if (AccessAdmin.class.equals(userAdapter.getAccessType())) {
            // For admin users, check their permission level
            try {
                AdminDAO adminDAO = new AdminDAO(getSession());
                Admin admin = adminDAO.findById(userAdapter.getUserId());
                if (admin != null) {
                    int adminPermissionLevel = admin.getPermissionLevel() != null ? admin.getPermissionLevel() : 0;
                    
                    if (requiredLevel == PrivilegeLevel.PERMISSION_LEVEL) {
                        // Check specific permission level
                        if (adminPermissionLevel >= permissionLevel) {
                            logger.debug("Permission level access granted to admin user " + admin.getLogin() + " with level " + adminPermissionLevel + " (required: " + permissionLevel + ")");
                            return true;
                        }
                    } else {
                        // For legacy privilege levels, admin users always have access
                        logger.debug("Admin access granted to admin user " + admin.getLogin() + " with level " + adminPermissionLevel);
                        return true;
                    }
                }
            } catch (Exception e) {
                logger.error("Error checking admin privileges", e);
            }
        }
        
        // Check if regular user has appropriate privileges
        try {
            UserDAO userDAO = new UserDAO(getSession());
            User user = userDAO.findById(userAdapter.getUserId());
            if (user != null) {
                boolean isSuperUser = Boolean.TRUE.equals(user.getSuperUser());
                boolean isModerator = user.isModerator();
                
                if (requiredLevel == PrivilegeLevel.PERMISSION_LEVEL) {
                    // Map user privileges to permission levels
                    int userPermissionLevel = 0; // Default level
                    if (isSuperUser) {
                        userPermissionLevel = SUPER_MOD; // Level 4
                    } else if (isModerator) {
                        userPermissionLevel = MOD; // Level 3
                    }
                    
                    if (userPermissionLevel >= permissionLevel) {
                        logger.debug("Permission level access granted to user " + user.getLogin() + " with level " + userPermissionLevel + " (required: " + permissionLevel + ")");
                        return true;
                    }
                } else {
                    // Legacy privilege level checks
                    switch (requiredLevel) {
                        case ADMIN:
                        case MODERATOR:
                            if (isModerator || isSuperUser) {
                                logger.debug("Access granted to user " + user.getLogin() + " with privileges: moderator=" + isModerator + ", superUser=" + isSuperUser);
                                return true;
                            }
                            break;
                        case SUPER_USER:
                            if (isSuperUser) {
                                logger.debug("SuperUser access granted to user " + user.getLogin() + " with superUser=" + isSuperUser);
                                return true;
                            }
                            break;
                    }
                }
            }
        } catch (Exception e) {
            logger.error("Error checking user privileges for access", e);
        }
        
        logger.warn("Unauthorized access attempt by user: " + userAdapter.getLogin() + " (accessType: " + userAdapter.getAccessType() + ", requiredLevel: " + (requiredLevel == PrivilegeLevel.PERMISSION_LEVEL ? "PERMISSION_LEVEL_" + permissionLevel : requiredLevel) + ")");
        return false;
    }
    
    /**
     * Checks admin access and throws SecurityException if unauthorized.
     * @throws SecurityException if the current user is not an admin
     */
    protected void requireAdminAccess() {
        if (!checkAdminAccess()) {
            throw new SecurityException("Admin access required");
        }
    }
    
    /**
     * Checks moderator access and throws SecurityException if unauthorized.
     * @throws SecurityException if the current user is not a moderator
     */
    protected void requireModeratorAccess() {
        if (!checkModeratorAccess()) {
            throw new SecurityException("Moderator access required");
        }
    }
    
    /**
     * Checks superUser access and throws SecurityException if unauthorized.
     * @throws SecurityException if the current user is not a superUser
     */
    protected void requireSuperUserAccess() {
        if (!checkSuperUserAccess()) {
            throw new SecurityException("SuperUser access required");
        }
    }
    
    /**
     * Checks permission level access and throws SecurityException if unauthorized.
     * @param requiredLevel the minimum permission level required (0-4)
     * @throws SecurityException if the current user doesn't have the required permission level
     */
    protected void requirePermissionLevel(int requiredLevel) {
        if (!checkPermissionLevel(requiredLevel)) {
            throw new SecurityException("Permission level " + requiredLevel + " required");
        }
    }
    
    /**
     * Intercepts method calls to check for privilege annotations.
     * This method should be called at the beginning of each public method.
     * 
     * @param methodName the name of the method being called
     */
    protected void checkMethodAccess(String methodName) {
        try {
            Method method = this.getClass().getMethod(methodName);
            
            // Check for specific permission level annotation first
            if (method.isAnnotationPresent(RequirePermissionLevel.class)) {
                RequirePermissionLevel annotation = method.getAnnotation(RequirePermissionLevel.class);
                requirePermissionLevel(annotation.value());
            }
            // Check for convenience annotations
            else if (method.isAnnotationPresent(RequireSuperMod.class)) {
                requirePermissionLevel(SUPER_MOD);
            } else if (method.isAnnotationPresent(RequireMod.class)) {
                requirePermissionLevel(MOD);
            } else if (method.isAnnotationPresent(RequireHalfMod.class)) {
                requirePermissionLevel(HALF_MODER);
            } else if (method.isAnnotationPresent(RequirePartner.class)) {
                requirePermissionLevel(PARTNER);
            } else if (method.isAnnotationPresent(RequireExternalMod.class)) {
                requirePermissionLevel(EXTERNAL_MODER);
            }
            // Check for legacy privilege annotations
            else if (method.isAnnotationPresent(RequireSuperUser.class)) {
                requireSuperUserAccess();
            } else if (method.isAnnotationPresent(RequireModerator.class)) {
                requireModeratorAccess();
            } else if (method.isAnnotationPresent(RequireAdmin.class)) {
                requireAdminAccess();
            }
        } catch (NoSuchMethodException e) {
            // Method not found, continue without access check
            logger.debug("Method " + methodName + " not found for access control check");
        }
    }
    
    /**
     * Enum for privilege levels
     */
    private enum PrivilegeLevel {
        ADMIN,
        MODERATOR,
        SUPER_USER,
        PERMISSION_LEVEL
    }
} 