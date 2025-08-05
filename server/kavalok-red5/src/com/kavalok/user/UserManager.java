package com.kavalok.user;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.red5.server.api.IClient;
import org.red5.server.api.Red5;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.KavalokApplication;

public class UserManager {
  public static String ADAPTER = "adapter";

  private static final Logger logger = LoggerFactory.getLogger(UserManager.class);

  private static UserManager instance;

  public static UserManager getInstance() {
    if (instance == null) {
      instance = new UserManager();
    }
    return instance;
  }

  public UserManager() {
    super();
  }

  public UserAdapter getCurrentUser() {
    IClient client = null;
    try {
      client = new Red5().getClient();
    } catch (Exception e) {
      return null;
    }
    if (client == null) {
      return null;
    }
    UserAdapter adapter = getUser(client);
    if (adapter == null) {
      adapter = new UserAdapter();
      client.setAttribute(ADAPTER, adapter);
    }
    return adapter;
  }

  public List<UserAdapter> getUsers() {
    List<UserAdapter> users = new ArrayList<UserAdapter>();
    Set<IClient> clients = KavalokApplication.getInstance().getClients();
    for (IClient client : clients) {
      UserAdapter user = getUser(client);
      if (user != null) {
        users.add(user);
      }
    }
    return users;
  }

  public UserAdapter getUser(String login) {
    Set<IClient> clients = KavalokApplication.getInstance().getClients();
    for (IClient client : clients) {
      UserAdapter user = getUser(client);
      if (user != null && user.getLogin() != null && user.getLogin().equals(login)) {
        return user;
      }
    }
    return null;
  }

  private UserAdapter getUser(IClient client) {
    return (UserAdapter) client.getAttribute(ADAPTER);
  }
}
