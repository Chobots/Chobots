package com.kavalok.services;

import java.util.Date;
import java.util.List;

import com.kavalok.dao.CompetitionDAO;
import com.kavalok.dao.CompetitionResultDAO;
import com.kavalok.db.Competition;
import com.kavalok.db.User;
import com.kavalok.dto.CompetitionResultTO;
import com.kavalok.dto.CompetitionTO;
import com.kavalok.dto.PagedResult;
import com.kavalok.services.common.DataServiceNotTransactionBase;
import com.kavalok.user.UserAdapter;
import com.kavalok.utils.ReflectUtil;

public class CompetitionDataService extends DataServiceNotTransactionBase {

  public List<CompetitionResultTO> getMyCompetitionResult(
      String competitionName, Integer firstResult, Integer maxResults) {
    Competition competition = new CompetitionDAO(getSession()).findByName(competitionName);
    List<CompetitionResultTO> list =
        getCompetitionResults(competitionName, firstResult, maxResults).getData();
    Date now = new Date();
    if (competition == null) return null;
    if (list.size() == 0
        && (competition.getFinish().before(now) || competition.getStart().after(now))) return null;

    UserAdapter adapter = getAdapter();

    Object[] result = null;
    if (adapter.getPersistent()) {
      User user = new User();
      user.setId(adapter.getUserId());
      // user = new UserDAO(getSession()).findById(adapter.getUserId());
      result = new CompetitionResultDAO(getSession()).getCompetitionResult(competition, user);
    }
    CompetitionResultTO myResult =
        (result == null)
            ? new CompetitionResultTO(
                competitionName, competition.getFinish(), adapter.getLogin(), 0.0)
            : new CompetitionResultTO(result);

    list.add(myResult);
    return list;
  }

  // Overloaded method to handle Double parameters from Flash client
  public List<CompetitionResultTO> getMyCompetitionResult(
      String competitionName, Double firstResult, Double maxResults) {
    return getMyCompetitionResult(competitionName, 
        firstResult != null ? firstResult.intValue() : null, 
        maxResults != null ? maxResults.intValue() : null);
  }

  @SuppressWarnings("unchecked")
  public PagedResult<CompetitionResultTO> getCompetitionResults(
      String competitionName, Integer firstResult, Integer maxResults) {
    Competition competition = new CompetitionDAO(getSession()).findByName(competitionName);
    CompetitionResultDAO competitionResultDAO = new CompetitionResultDAO(getSession());
    List<?> list = competitionResultDAO.getCompetitionResults(competition, firstResult, maxResults);
    List<CompetitionResultTO> result =
        ReflectUtil.convertBeansByConstructor(list, CompetitionResultTO.class);
    return new PagedResult<CompetitionResultTO>(
        competitionResultDAO.sizeOfCompetitionResults(competition).intValue(), result);
  }

  // Overloaded method to handle Double parameters from Flash client
  @SuppressWarnings("unchecked")
  public PagedResult<CompetitionResultTO> getCompetitionResults(
      String competitionName, Double firstResult, Double maxResults) {
    return getCompetitionResults(competitionName, 
        firstResult != null ? firstResult.intValue() : null, 
        maxResults != null ? maxResults.intValue() : null);
  }

  @SuppressWarnings("unchecked")
  public List<CompetitionTO> getCompetitions() {
    List<Competition> list = new CompetitionDAO(getSession()).findAll();
    return ReflectUtil.convertBeansByConstructor(list, CompetitionTO.class);
  }

  public void clearCompetition(String name) {
    CompetitionDAO competitionDAO = new CompetitionDAO(getSession());
    Competition competition = competitionDAO.findByName(name);
    new CompetitionResultDAO(getSession()).clearCompetition(competition);
  }

  public void startCompetition(String name, Date start, Date finish) {
    CompetitionDAO competitionDAO = new CompetitionDAO(getSession());
    Competition competition = competitionDAO.findByName(name);
    if (competition == null) {
      competition = new Competition(name, start, finish);
    } else {
      competition.setStart(start);
      competition.setFinish(finish);
    }
    competitionDAO.makePersistent(competition);
  }
}
