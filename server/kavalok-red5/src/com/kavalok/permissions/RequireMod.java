package com.kavalok.permissions;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to mark methods that require MOD permission level (3).
 * Methods annotated with this will automatically check for full moderator privileges.
 * 
 * Access is granted to:
 * - Users with AccessAdmin.class access type (admin users) - have access to everything
 * - Regular users with moderator=true - equivalent to MOD level
 * - Regular users with superUser=true - equivalent to SUPER_MOD level
 * - Admin users with permission level >= 3
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequireMod {
} 