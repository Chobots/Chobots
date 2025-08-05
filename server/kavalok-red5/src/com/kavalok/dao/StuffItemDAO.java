package com.kavalok.dao;

import java.util.Date;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.Restrictions;

import com.kavalok.dao.common.DAO;
import com.kavalok.db.GameChar;
import com.kavalok.db.StuffItem;
import com.kavalok.db.StuffType;

public class StuffItemDAO extends DAO<StuffItem> {

  public StuffItemDAO(Session session) {
    super(session);
  }

  @SuppressWarnings("unchecked")
  public List<Object[]> findForDates(Date minDate, Date maxDate) {
    Query query = getSession().getNamedQuery(QueriesNames.PURCHASE_STATISTICS_SELECT_FOR_STUFF);
    query.setParameter("minDate", minDate);
    query.setParameter("maxDate", maxDate);
    return query.list();
  }

  @SuppressWarnings("unchecked")
  public List<StuffItem> findItems(StuffType type, GameChar gameChar) {
    return findAllByParameters(new String[] {"type", "gameChar"}, new Object[] {type, gameChar});
  }

  @SuppressWarnings("unchecked")
  public List<StuffItem> findByTypes(GameChar gameChar, String[] types, boolean usedOnly) {
    Criteria criteria = createCriteria();
    Criteria typeCriteria = criteria.createCriteria("type");
    Criterion typesCriterion = null;
    for (String type : types) {
      if (typesCriterion == null) typesCriterion = Restrictions.eq("type", type);
      else typesCriterion = Restrictions.or(typesCriterion, Restrictions.eq("type", type));
    }
    typeCriteria.add(typesCriterion);
    if (usedOnly) {
      criteria.add(Restrictions.eq("used", true));
    }
    criteria.add(Restrictions.eq("gameChar", gameChar));
    return criteria.list();
  }

  @SuppressWarnings("unchecked")
  public List<StuffItem> findByGameCharAndUsed(GameChar gameChar, boolean used) {
    Criteria criteria = createCriteria();
    criteria.add(Restrictions.eq("gameChar", gameChar));
    criteria.add(Restrictions.eq("used", used));
    return criteria.list();
  }
  // @SuppressWarnings("unchecked")
  // public List<StuffItem> findByEmailAndType(String email, String type)
  // {
  // Criteria criteria = createCriteria();
  // Criteria typeCriteria = criteria.createCriteria("type");
  // typeCriteria.add(Restrictions.eq("type", type));
  // Criteria gameCharCriteria = criteria.createCriteria("gameChar");
  // Criteria userCriteria = gameCharCriteria.createCriteria("user");
  // userCriteria.add(Restrictions.eq("email", email));
  // return criteria.list();
  // }

}
