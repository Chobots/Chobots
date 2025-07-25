package com.kavalok.user;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.red5.server.api.IClient;
import org.red5.server.api.Red5;

import com.kavalok.KavalokApplication;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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

  /**
   * Returns the UserAdapter for the current Red5 client session.
   * If none exists, creates one and attaches it to the client.
   * Always returns a non-null UserAdapter.
   * Logs creation and retrieval for debugging.
   */
  public UserAdapter getCurrentUser() {
    IClient client = null;
    try {
      client = new Red5().getClient();
    } catch (Exception e) {
      logger.error("Could not get Red5 client", e);
    }
    if (client == null) {
      logger.error("No Red5 client found for current session");
      return null;
    }
    UserAdapter adapter = getUser(client);
    if (adapter == null) {
      logger.info("Creating new UserAdapter for client: {}", client.getId());
      adapter = new UserAdapter();
      client.setAttribute(ADAPTER, adapter);
    } else {
      logger.info("Found existing UserAdapter for client: {} userId: {}", client.getId(), adapter.getUserId());
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
