package com.kavalok.services.common;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.LinkedHashMap;

import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.mail.MailUtil;

public class SimpleEncryptor {
  private static Logger logger = Red5LoggerFactory.getLogger(SimpleEncryptor.class);

  private static final int KEY_LENGTH = 16;

  private Byte[] key;

  public static Byte[] generateKey() {
    ArrayList<Byte> result = new ArrayList<Byte>();
    while (result.size() < KEY_LENGTH) {
      result.add((Double.valueOf(Math.random() * Byte.MAX_VALUE)).byteValue());
    }
    return result.toArray(new Byte[KEY_LENGTH]);
  }

  public SimpleEncryptor(Byte[] key) {
    super();
    this.key = key;
  }

  public Integer[] encrypt(String value) {
    byte[] bytes = null;
    try {
      bytes = (value + value).getBytes(MailUtil.ENCODING);
      Integer[] result = new Integer[bytes.length];
      for (int i = 0; i < bytes.length; i++) {
        result[i] = bytes[i] ^ key[i % key.length];
      }
      return result;
    } catch (UnsupportedEncodingException e) {
      logger.error(e.getMessage(), e);
      return null;
    }
  }

  public String decrypt(LinkedHashMap<Integer, Integer> source) {
    Integer[] bytes = new Integer[source.size()];
    bytes = source.values().toArray(bytes);
    return decrypt(bytes);
  }

  public String decrypt(Integer[] source) {
    StringBuilder stringBuilder = new StringBuilder();
    for (int i = 0; i < source.length; i++) {
      source[i] ^= key[i % key.length];
      stringBuilder.append((char) source[i].byteValue());
    }
    String result = stringBuilder.toString();
    String[] parts =
        new String[] {
          result.substring(0, result.length() / 2),
          result.substring(result.length() / 2, result.length())
        };
    if (!parts[0].equals(parts[1])) throw new IllegalArgumentException("Illegal message format");
    return parts[0];
  }
}
