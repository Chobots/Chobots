package com.kavalok.services.stuff;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RainTokenManager {
  private static RainTokenManager instance;
  private final Map<String, RainToken> tokens = new ConcurrentHashMap<>();
  private final String serverSecret;
  private final long tokenLifetimeMs = 60000;
  private static final Logger logger = LoggerFactory.getLogger(RainTokenManager.class);

  private RainTokenManager(String serverSecret) {
    this.serverSecret = serverSecret;
    startCleanupThread();
  }

  public static void initialize(String serverSecret) {
    if (instance == null) {
      instance = new RainTokenManager(serverSecret);
    }
  }

  public static RainTokenManager getInstance() {
    if (instance == null) throw new IllegalStateException("RainTokenManager not initialized");
    return instance;
  }

  public String generateToken(Integer itemId, Integer color) {
    String salt = UUID.randomUUID().toString();
    String data = itemId + ":" + (color != null ? color : "") + ":" + salt + ":" + serverSecret;
    String hash = sha256(data);
    tokens.put(hash, new RainToken(itemId, color, System.currentTimeMillis() + tokenLifetimeMs));

    return hash;
  }

  public Integer getTokenColor(String token) {
    if (token == null) {
      logger.warn("Token is null");
      return null;
    }
    RainToken rainToken = tokens.get(token);
    if (rainToken == null) {
      logger.warn("Token not found in storage: " + token);
      return null;
    }
    if (rainToken.isExpired()) {
      logger.warn("Token expired: " + token);
      return null;
    }
    return rainToken.color;
  }

  public boolean validateAndSpendToken(String token, Integer itemId, Integer color) {
    if (token == null) {
      logger.warn("Token is null");
      return false;
    }
    RainToken rainToken = tokens.get(token);
    if (rainToken == null) {
      logger.warn("Token not found in storage: " + token);
      return false;
    }
    if (rainToken.spent) {
      logger.warn("Token already spent: " + token);
      return false;
    }
    if (rainToken.isExpired()) {
      logger.warn("Token expired: " + token);
      return false;
    }
    if (!rainToken.itemId.equals(itemId)) {
      logger.warn("Token itemId mismatch: expected=" + rainToken.itemId + ", got=" + itemId);
      return false;
    }
    // If token was generated with null color, allow any color
    if (rainToken.color != null && (color == null || !rainToken.color.equals(color))) {
      logger.warn("Token color mismatch: expected=" + rainToken.color + ", got=" + color);
      return false;
    }
    rainToken.spent = true;
    return true;
  }

  private void startCleanupThread() {
    Thread cleanup =
        new Thread(
            () -> {
              while (true) {
                try {
                  Thread.sleep(30000);
                } catch (InterruptedException ignored) {
                }
                long now = System.currentTimeMillis();
                tokens.entrySet().removeIf(e -> e.getValue().isExpired() || e.getValue().spent);
              }
            });
    cleanup.setDaemon(true);
    cleanup.start();
  }

  private String sha256(String data) {
    try {
      MessageDigest digest = MessageDigest.getInstance("SHA-256");
      byte[] hash = digest.digest(data.getBytes());
      return Base64.getEncoder().encodeToString(hash);
    } catch (NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
  }

  private static class RainToken {
    final Integer itemId;
    final Integer color;
    final long expiresAt;
    boolean spent = false;

    RainToken(Integer itemId, Integer color, long expiresAt) {
      this.itemId = itemId;
      this.color = color;
      this.expiresAt = expiresAt;
    }

    boolean isExpired() {
      return System.currentTimeMillis() > expiresAt;
    }
  }
}
