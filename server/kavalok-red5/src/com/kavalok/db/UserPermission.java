package com.kavalok.db;

public enum UserPermission {
  PUBLIC,
  AGENT,
  MODERATOR,
  SUPERUSER;

  /**
   * Checks if this permission level is sufficient for the required level
   *
   * @param required The required permission level
   * @return true if this permission level is sufficient, false otherwise
   */
  public boolean isSufficient(UserPermission required) {
    return this.ordinal() >= required.ordinal();
  }
}
