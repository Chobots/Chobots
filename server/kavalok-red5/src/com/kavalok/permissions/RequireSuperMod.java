package com.kavalok.permissions;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to mark methods that require SUPER_MOD permission level (4).
 * Methods annotated with this will automatically check for super moderator privileges.
 * 
 * Access is granted to:
 * - Users with AccessAdmin.class access type (admin users) - have access to everything
 * - Regular users with superUser=true - equivalent to SUPER_MOD level
 * - Admin users with permission level >= 4
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequireSuperMod {
} 