package com.kavalok.services;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.Session;
import org.red5.io.utils.ObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.dao.UserDAO;
import com.kavalok.db.User;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;
import com.kavalok.utils.HibernateUtil;
import com.kavalok.services.common.ServiceBase;
import com.kavalok.utils.SOUtil;

public class GraphityService extends ServiceBase {

  private static final Logger logger = LoggerFactory.getLogger(GraphityService.class);

  private static final String CLIENT_ID = "WallClient";

  private static final int MAX_SHAPES = 400;

  private static ObjectMap<String, ArrayList<Object>> walls;

  public void sendShape(String wallId, ObjectMap<String, Object> state) {    
    List<Object> shapes = getShapes(wallId);
    shapes.add(state);
    if (shapes.size() > MAX_SHAPES) shapes.remove(0);
    SOUtil.callSharedObject(wallId, CLIENT_ID, "rShape", state);
  }

  public void clear(String wallId) {
    List<Object> shapes = getShapes(wallId);
    shapes.clear();
    SOUtil.callSharedObject(wallId, CLIENT_ID, "rClear", (Object) null);
  }

  public List<Object> getShapes(String wallId) {
    if (walls == null) {
      walls = new ObjectMap<String, ArrayList<Object>>();
    }
    if (!walls.containsKey(wallId)) {
      walls.put(wallId, new ArrayList<Object>());
    }
    return walls.get(wallId);
  }
}
