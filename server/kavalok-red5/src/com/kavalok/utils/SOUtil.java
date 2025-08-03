package com.kavalok.utils;

import java.util.ArrayList;
import java.util.LinkedHashMap;

import org.red5.io.utils.ObjectMap;
import org.red5.server.api.so.ISharedObject;

import com.kavalok.KavalokApplication;
import com.kavalok.sharedObjects.SOListener;

public class SOUtil {

  public static final Integer getNumConnectedChars(String sharedObjectId) {
    ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(sharedObjectId);
    if (sharedObject != null) {
      SOListener listener = SOListener.getListener(sharedObject);
      return listener.getConnectedChars().size();
    } else {
      return 0;
    }
  }

  public static final void sendToSharedObject(
      String sharedObjectId,
      String clientId,
      String method,
      String stateName,
      ObjectMap<String, Object> state) {

    LinkedHashMap<Integer, Object> methodArgs = new LinkedHashMap<Integer, Object>();
    methodArgs.put(0, stateName);
    methodArgs.put(1, state);

    ArrayList<Object> args = new ArrayList<Object>();
    args.add(clientId);
    args.add(method);
    args.add(methodArgs);

    ISharedObject so = KavalokApplication.getInstance().getSharedObject(sharedObjectId);
    if (so != null) {
      so.sendMessage(SOListener.SEND_STATE, args);
    } else {
      org.slf4j.LoggerFactory.getLogger(SOUtil.class)
          .warn("Shared object not found: " + sharedObjectId);
    }
  }

  public static final void callSharedObject(String sharedObjectId, String clientId, String method, Object... params) {
    ISharedObject so = KavalokApplication.getInstance().getSharedObject(sharedObjectId);

    if (so != null) {
      callSharedObject(so, clientId, method, params);
    } else {
      // Log warning when shared object is not found
      org.slf4j.LoggerFactory.getLogger(SOUtil.class)
          .warn("Shared object not found: " + sharedObjectId);
    }
  }

  public static void sendState(
      ISharedObject so,
      String clientId,
      String method,
      String stateName,
      ObjectMap<String, Object> state) {
    if (so == null) {
      org.slf4j.LoggerFactory.getLogger(SOUtil.class)
          .warn("Cannot send state to null shared object");
      return;
    }

    ArrayList<Object> args = new ArrayList<Object>();
    args.add(clientId);
    args.add(method);
    LinkedHashMap<Integer, Object> methodArgs = new LinkedHashMap<Integer, Object>();
    args.add(methodArgs);
    methodArgs.put(0, stateName);
    methodArgs.put(1, state);
    methodArgs.put(2, false);

    so.sendMessage(SOListener.SEND_STATE, args);
  }

  public static void callSharedObject(
      ISharedObject so, String clientId, String method, Object... params) {
    if (so == null) {
      org.slf4j.LoggerFactory.getLogger(SOUtil.class)
          .warn("Cannot call shared object method " + method + " on null shared object");
      return;
    }

    ArrayList<Object> args = new ArrayList<Object>();
    args.add(clientId);
    args.add(method);
    LinkedHashMap<Integer, Object> methodArgs = new LinkedHashMap<Integer, Object>();
    for (int i = 0; i < params.length; i++) methodArgs.put(i, params[i]);

    args.add(methodArgs);
    so.sendMessage(SOListener.SEND, args);
  }
}
