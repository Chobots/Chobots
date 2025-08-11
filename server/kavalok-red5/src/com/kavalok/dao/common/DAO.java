package com.kavalok.dao.common;

import java.lang.reflect.ParameterizedType;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.LockMode;
import org.hibernate.Session;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.Example;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

public abstract class DAO<T> implements IDAO<T> {

  private Class<T> persistentClass;

  private Session session;

  @SuppressWarnings("unchecked")
  public DAO(Session session) {
    super();
    this.session = session;
    this.persistentClass =
        (Class<T>)
            ((ParameterizedType) getClass().getGenericSuperclass()).getActualTypeArguments()[0];
  }

  public void setSession(Session s) {
    this.session = s;
  }

  protected Session getSession() {
    if (session == null)
      throw new IllegalStateException("Session has not been set on DAO before usage");
    return session;
  }

  public Class<T> getPersistentClass() {
    return persistentClass;
  }

  public Integer size() {
    Criteria criteria = getSizeCriteria();
    return ((Number) criteria.uniqueResult()).intValue();
  }

  protected Criteria getSizeCriteria() {
    Criteria criteria = createCriteria();
    criteria.setProjection(Projections.rowCount());
    return criteria;
  }

  @SuppressWarnings("unchecked")
  public T findById(Long id, boolean lock) {
    T entity;
    if (lock) entity = (T) getSession().load(getPersistentClass(), id, LockMode.UPGRADE);
    else entity = (T) getSession().load(getPersistentClass(), id);

    return entity;
  }

  public T findById(Long id) {
    return findById(id, false);
  }

  @SuppressWarnings("unchecked")
  public List<T> findAll(int firstResult, int maxResults) {
    Criteria criteria = createCriteria();
    criteria.setFirstResult(firstResult);
    criteria.setMaxResults(maxResults);
    return criteria.list();
  }

  @SuppressWarnings("unchecked")
  public List<T> findAll(int maxResults) {
    Criteria criteria = createCriteria();
    criteria.setMaxResults(maxResults);
    return criteria.list();
  }

  public List<T> findAll() {
    return findByCriteria();
  }

  @SuppressWarnings("unchecked")
  public List<T> findByExample(T exampleInstance, String[] excludeProperty) {
    Criteria crit = createCriteria();
    Example example = Example.create(exampleInstance);
    for (String exclude : excludeProperty) {
      example.excludeProperty(exclude);
    }
    crit.add(example);
    return crit.list();
  }

  public T makePersistent(T entity) {
    getSession().saveOrUpdate(entity);
    return entity;
  }

  public void makeTransient(Long id) {
    makeTransient(findById(id, false));
  }

  public void makeTransient(T entity) {
    getSession().delete(entity);
  }

  public void flush() {
    getSession().flush();
  }

  public void clear() {
    getSession().clear();
  }

  @SuppressWarnings("unchecked")
  protected List<T> findAllByParameters(String[] names, Object[] values) {
    return createCriteria(names, values).list();
  }

  @SuppressWarnings("unchecked")
  protected List<T> findAllByParameterValues(String name, Object[] values) {
    return createInCriteria(name, values).list();
  }

  @SuppressWarnings("unchecked")
  protected T findByParameters(String[] names, Object[] values) {
    Criteria criteria = createCriteria(names, values);
    return (T) criteria.uniqueResult();
  }

  protected Criteria createCriteria(String[] names, Object[] values, Order order) {
    Criteria result = createCriteria(names, values);
    result.addOrder(order);
    return result;
  }

  protected Criteria createCriteria(String[] names, Object[] values) {
    Criteria criteria = createCriteria();
    for (int i = 0; i < names.length; i++) {
      criteria.add(Restrictions.eq(names[i], values[i]));
    }
    return criteria;
  }

  protected Criteria createInCriteria(String name, Object[] values) {
    Criteria criteria = createCriteria();
    criteria.add(Restrictions.in(name, values));
    return criteria;
  }

  protected List<T> findAllByParameter(String name, Object value) {
    return findAllByParameters(new String[] {name}, new Object[] {value});
  }

  protected T findByParameter(String name, Object value) {
    return findByParameters(new String[] {name}, new Object[] {value});
  }

  /** Use this inside subclasses as a convenience method. */
  protected Criteria createCriteria() {
    return getSession().createCriteria(getPersistentClass());
  }

  @SuppressWarnings("unchecked")
  protected List<T> findByCriteria(Criterion... criterion) {
    Criteria crit = createCriteria();
    for (Criterion c : criterion) {
      crit.add(c);
    }
    return crit.list();
  }

  @SuppressWarnings("unchecked")
  protected T findByCriteriaUnique(Criterion... criterion) {
    Criteria crit = createCriteria();
    for (Criterion c : criterion) {
      crit.add(c);
    }
    return (T) crit.uniqueResult();
  }
}
