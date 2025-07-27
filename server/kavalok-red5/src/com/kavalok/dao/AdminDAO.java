package com.kavalok.dao;

import org.hibernate.Session;

import com.kavalok.db.Admin;

public class AdminDAO extends LoginDAOBase<Admin> {

  public AdminDAO(Session session) {
    super(session);
  }

  public Admin findByLogin(String login) {
    return findByParameter("login", login);
  }
}
