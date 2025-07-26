package com.kavalok.permissions;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to mark methods that require a specific permission level.
 * Methods annotated with this will automatically check for the specified permission level.
 * 
 * Permission Levels:
 * - 0: EXTERNAL_MODER - External moderators
 * - 1: PARTNER - Partners
 * - 2: HALF_MODER - Half moderators  
 * - 3: MODER - Full moderators
 * - 4: SUPER_MODER - Super moderators (superusers)
 * 
 * Access is granted to:
 * - Users with AccessAdmin.class access type (admin users) - have access to everything
 * - Regular users with moderator=true - equivalent to MODER level
 * - Regular users with superUser=true - equivalent to SUPER_MODER level
 * - Admin users with matching or higher permission level
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequirePermissionLevel {
    /**
     * The minimum permission level required to access this method.
     * @return the permission level (0-4)
     */
    int value();
} 