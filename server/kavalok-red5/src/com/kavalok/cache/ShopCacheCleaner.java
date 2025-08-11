package com.kavalok.cache;

import java.util.TimerTask;

import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

public class ShopCacheCleaner extends TimerTask {

  public static final int DELAY = 60 * 60 * 1000;

  public static Logger logger = Red5LoggerFactory.getLogger(ShopCacheCleaner.class);

  @Override
  public void run() {
    logger.debug("ShopCacheCleaner start");
    StuffTypeCache.getInstance().clear();
    logger.debug("ShopCacheCleaner end");
  }
}
