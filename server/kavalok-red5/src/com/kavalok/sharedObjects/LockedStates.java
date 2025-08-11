package com.kavalok.sharedObjects;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Collections;

import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;

public class LockedStates {

  private HashMap<String, HashMap<String, String>> lockedStates =
      new HashMap<String, HashMap<String, String>>();

  public synchronized void clear() {
    lockedStates.clear();
  }

  public synchronized void unlockStates(String charId) {
    for (String client : lockedStates.keySet()) {
      HashMap<String, String> clientStates = lockedStates.get(client);
      ArrayList<String> statesToRemove = new ArrayList<String>();
      for (Map.Entry<String, String> entry : clientStates.entrySet()) {
        if (charId.equals(entry.getValue())) {
          statesToRemove.add(entry.getKey());
        }
      }
      for (String state : statesToRemove) {
        clientStates.remove(state);
      }
    }
  }

  public synchronized void lockState(String client, String state) {
    if (!lockedStates.containsKey(client)) {
      lockedStates.put(client, new HashMap<String, String>());
    }
    HashMap<String, String> clientStates = lockedStates.get(client);
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    clientStates.put(state, adapter.getLogin());
  }

  public synchronized void unlockState(String client, String state) {
    if (!lockedStates.containsKey(client)) return;

    HashMap<String, String> clientStates = lockedStates.get(client);
    if (clientStates.containsKey(state)) {
      clientStates.remove(state);
    }
  }

  public synchronized boolean canReset(String client, String state) {
    if (!lockedStates.containsKey(client)) return true;
    HashMap<String, String> clientStates = lockedStates.get(client);
    if (!clientStates.containsKey(state)) return true;

    String lockChar = clientStates.get(state);
    UserAdapter adapter = UserManager.getInstance().getCurrentUser();
    return adapter.getLogin().equals(lockChar);
  }
}
