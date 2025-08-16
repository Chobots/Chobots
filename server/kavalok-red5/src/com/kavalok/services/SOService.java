package com.kavalok.services;

import org.hibernate.Session;
import org.red5.server.api.so.ISharedObject;

import com.kavalok.KavalokApplication;
import com.kavalok.dao.ServerDAO;
import com.kavalok.db.Server;
import com.kavalok.dto.StateInfoTO;
import com.kavalok.services.common.ServiceBase;
import com.kavalok.sharedObjects.SOListener;
import com.kavalok.utils.HibernateUtil;
import com.kavalok.utils.SOUtil;
import com.kavalok.xmlrpc.RemoteClient;
import com.kavalok.utils.SessionManager;

public class SOService extends ServiceBase {

  public StateInfoTO getState(String sharedObjectId) {
    ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(sharedObjectId);
    
    // Handle case where shared object has been garbage collected
    if (sharedObject == null) {
      // Return empty state when shared object is not available
      return new StateInfoTO(new org.red5.io.utils.ObjectMap<String, Object>(), new java.util.ArrayList<String>());
    }
    
    // Acquire the shared object to prevent premature garbage collection
    if (!sharedObject.isAcquired()) {
      sharedObject.acquire();
    }
    
    SOListener listener = SOListener.getListener(sharedObject);
    
    // Additional null check for listener
    if (listener == null) {
      // Return empty state when listener is not available
      return new StateInfoTO(new org.red5.io.utils.ObjectMap<String, Object>(), new java.util.ArrayList<String>());
    }
    
    return new StateInfoTO(listener.getState(), listener.getConnectedChars());
  }

  public Integer getNumConnectedChars(String sharedObjectId, String serverName) {
    if (serverName.length() == 0) {
      return SOUtil.getNumConnectedChars(sharedObjectId);
    } else {
      Session session = SessionManager.getCurrentSession();
      Server server = new ServerDAO(session).findByName((String) serverName);

      RemoteClient client = new RemoteClient(server);
      return client.getNumConnectedChars(sharedObjectId);
    }
  }

  /**
   * Manually release a shared object when it's no longer needed.
   * This should be called when the shared object is no longer required.
   */
  public void releaseSharedObject(String sharedObjectId) {
    ISharedObject sharedObject = KavalokApplication.getInstance().getSharedObject(sharedObjectId);
    if (sharedObject != null) {
      SOListener listener = SOListener.getListener(sharedObject);
      if (listener != null) {
        listener.releaseSharedObject();
      }
      // Also release through the application
      KavalokApplication.getInstance().releaseSharedObject(sharedObjectId);
    }
  }
}
