package com.kavalok.permissions;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to mark methods that require moderator access.
 * Methods annotated with this will automatically check for moderator privileges.
 * Access is granted to:
 * - Users with AccessAdmin.class access type (admin users)
 * - Regular users with moderator=true
 * - Regular users with superUser=true
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequireModerator {
} 