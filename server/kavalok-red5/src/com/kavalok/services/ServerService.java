package com.kavalok.services;

import java.util.List;

import com.kavalok.dao.ServerDAO;
import com.kavalok.dao.UserServerDAO;
import com.kavalok.db.Server;
import com.kavalok.dto.ServerTO;
import com.kavalok.services.common.DataServiceNotTransactionBase;
import com.kavalok.utils.ReflectUtil;

public class ServerService extends DataServiceNotTransactionBase {

  public String getServerAddress(String name) {
    return new ServerDAO(getSession()).findByName(name).getScopeName();
  }

  @SuppressWarnings("unchecked")
  public List<ServerTO> getAllServers() {
    List<Server> servers = new ServerDAO(getSession()).findAll();
    List<ServerTO> tos = ReflectUtil.convertBeansByConstructor(servers, ServerTO.class);
    fillTos(servers, tos);
    return tos;
  }

  private void fillTos(List<Server> servers, List<ServerTO> tos) {
    UserServerDAO usDAO = new UserServerDAO(getSession());
    for (int i = 0; i < servers.size(); i++) {
      Server server = servers.get(i);
      ServerTO to = tos.get(i);
      to.setLoad(usDAO.countByServer(server).intValue());
    }
  }

  @SuppressWarnings("unchecked")
  public List<ServerTO> getServers() {
    List<Server> servers = new ServerDAO(getSession()).findAvailable();
    List<ServerTO> tos = ReflectUtil.convertBeansByConstructor(servers, ServerTO.class);
    fillTos(servers, tos);
    return tos;
  }
}
