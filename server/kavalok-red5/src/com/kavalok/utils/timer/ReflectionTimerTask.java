package com.kavalok.utils.timer;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.utils.ReflectUtil;

public class ReflectionTimerTask extends TimerTask {

  private static final Logger logger = Red5LoggerFactory.getLogger(ReflectionTimerTask.class);

  private Object target;

  private String methodName;

  private List<Object> args;

  private Timer timer;

  public ReflectionTimerTask(Timer timer, Object target, String methodName, List<Object> args) {
    super();
    this.timer = timer;
    this.target = target;
    this.methodName = methodName;
    this.args = args;
  }

  public ReflectionTimerTask(Timer timer, Object target, String methodName) {
    super();
    this.timer = timer;
    this.target = target;
    this.methodName = methodName;
    this.args = new ArrayList<Object>();
  }

  @Override
  public void run() {
    if (timer != null) {
      try {
        timer.cancel();
      } catch (Throwable e) {
        logger.error("Problem while stopping ReflectionTimerTask timer" + e.getMessage(), e);
      }
    }
    try {
      ReflectUtil.callMethod(target, methodName, args);
    } catch (NoSuchMethodException e) {
      logger.error("Problem while running ReflectionTimerTask " + e.getMessage(), e);
    } catch (IllegalAccessException e) {
      logger.error("Problem while running ReflectionTimerTask " + e.getMessage(), e);
    } catch (InvocationTargetException e) {
      logger.error("Problem while running ReflectionTimerTask " + e.getMessage(), e);
    }
  }
}
