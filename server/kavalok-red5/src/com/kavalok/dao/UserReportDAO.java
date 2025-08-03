package com.kavalok.dao;

import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.ProjectionList;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

import com.kavalok.dao.common.DAO;
import com.kavalok.db.User;
import com.kavalok.db.UserReport;

public class UserReportDAO extends DAO<UserReport> {

  public UserReportDAO(Session session) {
    super(session);
  }

  public Integer notProcessedSize() {
    Criteria criteria = createNotProcessedCriteria();
    criteria.setProjection(Projections.rowCount());
    Object result = criteria.uniqueResult();
    return result != null ? ((Number) result).intValue() : 0;
  }

  @SuppressWarnings("unchecked")
  public List<UserReport> findNotProcessedByUserAndReporter(User user, User reporter) {
    Criteria criteria = createNotProcessedCriteria();
    criteria.add(Restrictions.eq("user", user));
    criteria.add(Restrictions.eq("reporter", reporter));
    return criteria.list();
  }

  @SuppressWarnings("unchecked")
  public List<UserReport> findNotProcessedByUser(User user) {
    Criteria criteria = createNotProcessedCriteria();
    criteria.add(Restrictions.eq("user", user));
    return criteria.list();
  }

  @SuppressWarnings("unchecked")
  public List<Object[]> findNotProcessed(Integer firstResult, Integer maxResults) {
    Criteria criteria = createNotProcessedCriteria();
    ProjectionList projectionList = Projections.projectionList();
    projectionList.add(Projections.groupProperty("user"));
    projectionList.add(Projections.rowCount(), "count");
    //    projectionList.add(Projections.sqlProjection("GROUP_CONCAT(text) as text", new
    // String[]{"text"}, new Type[]{Hibernate.CHARACTER_ARRAY}));
    criteria.addOrder(Order.desc("count"));
    criteria.setProjection(projectionList);
    criteria.setFirstResult(firstResult);
    criteria.setMaxResults(maxResults);
    return criteria.list();
  }

  private Criteria createNotProcessedCriteria() {
    Criteria criteria = createCriteria();
    criteria.add(Restrictions.eq("processed", false));
    return criteria;
  }
}
