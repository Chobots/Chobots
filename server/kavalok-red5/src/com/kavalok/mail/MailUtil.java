package com.kavalok.mail;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Properties;

import org.simpleframework.xml.Serializer;
import org.simpleframework.xml.load.Persister;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.services.LoginService;
import com.kavalok.utils.ReflectUtil;

public class MailUtil {

  public static final String ENCODING = "UTF-8";

  public static final String PASSWORD_FILE = "mails/passwordMail.%1$s.xml";

  public static final String MEMBERSHIP_BOUGHT_FILE_PARENT =
      "mails/parentMembershipBoughtMail.%1$s.xml";

  public static final String MEMBERSHIP_BOUGHT_FILE_CHILD =
      "mails/childMembershipBoughtMail.%1$s.xml";

  public static final String ROBOT_ITEM_BOUGHT_FILE_PARENT =
      "mails/parentRobotItemBoughtMail.%1$s.xml";

  public static final String ROBOT_ITEM_BOUGHT_FILE_CHILD =
      "mails/childRobotItemBoughtMail.%1$s.xml";

  public static final String PARENT_PARTNER_ACTIVATION_FILE =
      "mails/parentPartnerActivationMail.%1$s.xml";

  public static final String CHILD_PARTNER_ACTIVATION_FILE =
      "mails/childPartnerActivationMail.%1$s.xml";

  public static final String PARENT_ACTIVATION_FILE = "mails/parentActivationMail.%1$s.xml";

  public static final String CHILD_ACTIVATION_FILE = "mails/childActivationMail.%1$s.xml";

  public static final String ADMIN_MAIL_FILE_NAME = "mails/newUser.xml";

  public static final String ADMIN_ADDRESS = "new-user@chobots.com";

  private static Logger logger = Red5LoggerFactory.getLogger(MailUtil.class);

  private static HashMap<String, Email> emails = new HashMap<String, Email>();

  public static Email getMail(String fileName, String locale) {

    String localeFileName = String.format(fileName, locale);

    if (emails.containsKey(localeFileName)) return emails.get(localeFileName);

    String pathFormat = ReflectUtil.getRootPath(LoginService.class) + "/" + localeFileName;

    Email result = null;

    try {
      result = getEmailFromFile(pathFormat);
    } catch (FileNotFoundException e) {
      logger.error(e.getMessage(), e);
    }

    if (result != null) emails.put(locale, result);

    return result;
  }

  private static Email getEmailFromFile(String fileName) throws FileNotFoundException {
    Email result = null;
    try {
      Serializer serializer = new Persister();
      FileInputStream inputStream = new FileInputStream(fileName);
      InputStreamReader reader = new InputStreamReader(inputStream, ENCODING);
      result = (Email) serializer.read(Email.class, reader);

    } catch (Exception e) {
      // TODO Auto-generated catch block
      logger.error(e.getMessage(), e);
    }
    return result;
  }

  public static void sendMail(Properties serverConfig, String address, Email email) {
    Thread thread = new Thread(new MailSender(serverConfig, address, email));
    thread.start();
  }
}
