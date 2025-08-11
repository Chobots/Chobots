package com.kavalok.mail;

import java.util.Properties;

import javax.mail.SendFailedException;

import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

public class MailSender implements Runnable {

  private static Logger logger = Red5LoggerFactory.getLogger(MailSender.class);

  private Email email;

  private String address;

  private Properties config;

  public MailSender(Properties config, String address, Email email) {
    super();
    this.address = address;
    this.email = email;
    this.config = config;
  }

  @Override
  public void run() {
    try {
      sendMail();
    } catch (Exception e) {
      logger.error(e.getMessage() + "failed to send mail to " + address, e);
    }
  }

  private void sendMail() throws SendFailedException {
    if (config != null) new Emailer().sendEmail(config, address, email.title, email.content);
  }
}
