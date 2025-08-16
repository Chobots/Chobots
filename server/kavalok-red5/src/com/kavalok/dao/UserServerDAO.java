package com.kavalok.dao;

import java.sql.SQLException;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.criterion.Projections;

import com.kavalok.dao.common.DAO;
import com.kavalok.db.Server;
import com.kavalok.db.User;
import com.kavalok.db.UserServer;

public class UserServerDAO extends DAO<UserServer> {

  public UserServerDAO(Session session) {
    super(session);
  }

  @SuppressWarnings("unchecked")
  public Server getServer(Long userId) {
    UserServer us = findByParameter("userId", userId);
    if (us != null) {
      return us.getServer();
    }
    return null;
  }

  @SuppressWarnings("unchecked")
  public Server getServer(User user) {
    UserServer us = findByParameter("user", user);
    if (us != null) {
      return us.getServer();
    }
    return null;
  }

  @SuppressWarnings("unchecked")
  public List<UserServer> getUserServerByUserIds(Object[] userIds) {
    return findAllByParameterValues("userId", userIds);
  }

  @SuppressWarnings("unchecked")
  public List<UserServer> getUserServerByUsers(Object[] users) {
    return findAllByParameterValues("user", users);
  }

  @SuppressWarnings("unchecked")
  public List<UserServer> getAllUserServer(User user) {
    return findAllByParameter("user", user);
  }

  @SuppressWarnings("unchecked")
  public List<UserServer> getAllUserServer(Server server) {
    return findAllByParameter("server", server);
  }

  @SuppressWarnings("unchecked")
  public List<UserServer> getAllUserServerByServerId(Long serverId) {
    return findAllByParameter("serverId", serverId);
  }

  @SuppressWarnings("unchecked")
  public List<UserServer> getAllUserServer(Long userId) {
    return findAllByParameter("userId", userId);
  }

  @SuppressWarnings("unchecked")
  public UserServer getUserServer(User user) {
    return findByParameter("user", user);
  }

  @SuppressWarnings("unchecked")
  public UserServer getUserServer(Long userId) {
    return findByParameter("userId", userId);
  }

  public Long countByServer(Server value) {
    Criteria criteria = createCriteria(new String[] {"server"}, new Object[] {value});
    criteria.setProjection(Projections.rowCount());
    return (Long) criteria.uniqueResult();
  }

  @SuppressWarnings("unchecked")
  public List<Object[]> getServerLoad() throws HibernateException, SQLException {
    String sqlQuery =
        "select s.id, count(*) from UserServer u join Server s on serverId=s.id where s.available=1 group by serverId order by count(*) desc;";
    SQLQuery query = getSession().createSQLQuery(sqlQuery);
    List<Object[]> result = query.list();
    return result;
  }
}
