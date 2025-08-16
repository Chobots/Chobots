package com.kavalok.dao;

import java.util.List;

import org.hibernate.Session;

import com.kavalok.dao.common.DAO;
import com.kavalok.db.Server;

public class ServerDAO extends DAO<Server> {

  public ServerDAO(Session session) {
    super(session);
  }

  public List<Server> findAvailable() {
    return findAllByParameters(new String[] {"available", "running"}, new Object[] {true, true});
  }

  public List<Server> findRunning() {
    return findAllByParameter("running", true);
  }

  public Server findByName(String name) {
    if (name.startsWith("Serv")) {
      String idString = name.substring(4);
      try {
        Long id = Long.parseLong(idString);
        return findByParameter("id", id);
      } catch (NumberFormatException e) {
        return null;
      }
    }

    return null;
  }

  public Server findById(Long id) {
    return findByParameter("id", id);
  }
}
