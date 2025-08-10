package com.kavalok.utils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.AnnotationConfiguration;
import org.red5.logging.Red5LoggerFactory;
import org.slf4j.Logger;

import com.kavalok.KavalokApplication;

public class HibernateUtil {

  private static Logger logger = Red5LoggerFactory.getLogger(HibernateUtil.class);

  private static String CONFIG_FILE_LOCATION = "/hibernate.cfg.xml";

  private static final SessionFactory sessionFactory;

  static {
    try {
      AnnotationConfiguration configuration = new AnnotationConfiguration();
      File config =
          new File(KavalokApplication.getInstance().getClassesPath() + CONFIG_FILE_LOCATION);
      configuration.configure(config);
      sessionFactory = configuration.buildSessionFactory();
    } catch (Throwable ex) {
      logger.error(ex.getMessage(), ex);
      throw new ExceptionInInitializerError(ex);
    }
  }

  public static SessionFactory getSessionFactory() {
    return sessionFactory;
  }

  public static Object deserialize(byte[] buf) {
    Object result = null;
    try {
      ObjectInputStream objectIn = new ObjectInputStream(new ByteArrayInputStream(buf));
      result = objectIn.readObject();
    } catch (IOException e) {
      logger.error(e.getMessage(), e);
    } catch (ClassNotFoundException e) {
      logger.error(e.getMessage(), e);
    }
    return result;
  }

  public static byte[] serialize(Object command) {
    ByteArrayOutputStream stream = new ByteArrayOutputStream();
    ObjectOutputStream outputStream;

    try {
      outputStream = new ObjectOutputStream(stream);
      outputStream.writeObject(command);
      outputStream.close();
    } catch (IOException e) {
      logger.error(e.getMessage(), e);
    }

    return stream.toByteArray();
  }
}
