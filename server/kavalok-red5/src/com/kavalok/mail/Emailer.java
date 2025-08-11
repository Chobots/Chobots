package com.kavalok.mail;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Properties;

import javax.activation.DataHandler;
import javax.mail.Message;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.KavalokApplication;
import com.sun.mail.smtp.SMTPTransport;

public final class Emailer {

  private static final String RETURN_PATH_FORMAT = "bounce+chp.e%1$s@em1.chobots.com";

  private static Logger logger = Red5LoggerFactory.getLogger(Emailer.class);

  /** Send a single email. */
  public void sendEmail(Properties properties, String toEmailAddr, String subject, String body) {
    Properties currentProperties = (Properties) properties.clone();
    // Thread.currentThread().setContextClassLoader(Emailer.class.getClassLoader());
    String md5;
    try {
      md5 = getMd5(toEmailAddr);
      currentProperties.put("mail.smtp.from", String.format(RETURN_PATH_FORMAT, md5)); // set
      // return-path
      // header
      // to
      // track
      // email
      // bounces
    } catch (NoSuchAlgorithmException e) {
      logger.error(e.getMessage(), e);
    }

    Session session =
        Session.getInstance(
            currentProperties,
            new PasswordAuthenticatior(
                currentProperties.getProperty("mail.smtp.user"),
                currentProperties.getProperty("mail.smtp.password")));
    session.setDebug(true);
    try {
      MimeMessage message = new MimeMessage(session);
      message.addFrom(
          InternetAddress.parse(
              KavalokApplication.getInstance().getApplicationConfig().getEmailsenderName()
                  + " <"
                  + KavalokApplication.getInstance().getApplicationConfig().getEmailsenderAddress()
                  + ">"));
      message.setSubject(subject, MailUtil.ENCODING);
      message.setText(body, MailUtil.ENCODING);
      message.addRecipient(Message.RecipientType.TO, new InternetAddress(toEmailAddr));
      message.setDataHandler(new DataHandler(new ByteArrayDataSource(body, "text/plain")));
      message.setHeader("Content-Type", "text/plain; charset=UTF-8");
      message.saveChanges(); // don't forget this
      SMTPTransport.send(message);
    } catch (Exception e) {
      logger.error("Cannot send email. ", e);
      logger.error("Mail send failed");
    }
  }

  private String getMd5(String toEmailAddr) throws NoSuchAlgorithmException {
    MessageDigest m = MessageDigest.getInstance("MD5");
    m.update(toEmailAddr.getBytes(), 0, toEmailAddr.length());
    String md5 = new BigInteger(1, m.digest()).toString(16);
    while (md5.length() < 32) md5 = "0" + md5;
    return md5;
  }
}
