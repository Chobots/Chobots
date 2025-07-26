package com.kavalok.utils;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import org.apache.ws.commons.util.Base64;

import com.kavalok.mail.MailUtil;

public class StringUtil {

  private static final String ID_CHARS = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM_";

  public static boolean isEmptyOrNull(String string) {
    return string == null || string.trim().length() == 0;
  }

  public static String generateRandomString(Integer length) {
    StringBuilder result = new StringBuilder();
    for (int i = 0; i < length; i++) {
      int index = ((Double) (Math.random() * ID_CHARS.length())).intValue();
      result.append(ID_CHARS.charAt(index));
    }
    return result.toString();
  }

  public static String toBase64(String source) {
    byte[] bytes = null;
    try {
      bytes = source.getBytes(MailUtil.ENCODING);
    } catch (UnsupportedEncodingException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    return Base64.encode(bytes);
  }

  public static String hashPassword(String password, String salt) {
    try {
      MessageDigest md = MessageDigest.getInstance("SHA-256");
      md.update(salt.getBytes());
      byte[] hashed = md.digest(password.getBytes());
      StringBuilder sb = new StringBuilder();
      for (byte b : hashed) {
        sb.append(String.format("%02x", b));
      }
      return sb.toString();
    } catch (NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
  }

  public static String generateSalt(int length) {
    SecureRandom random = new SecureRandom();
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < length; i++) {
      int index = random.nextInt(ID_CHARS.length());
      sb.append(ID_CHARS.charAt(index));
    }
    return sb.toString();
  }
}
