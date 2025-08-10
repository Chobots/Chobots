package com.kavalok.sharedObjects;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;

import org.red5.io.utils.ObjectMap;
import org.red5.server.api.so.ISharedObjectBase;

import com.kavalok.db.InfoPanel;
import com.kavalok.services.InfoPanelService;
import com.kavalok.transactions.ITransactionStrategy;
import com.kavalok.transactions.TransactionUtil;
import com.kavalok.utils.timer.ReflectionTimerTask;

public class InfoPanelListener extends SOListener {

  public static final String PANEL_ID = "infoPanel";

  public static final String DATA_STATE = "dataState";

  public static final long UPDATE_INTERVAL = 60 * 1000;

  private Timer timer;

  private List<InfoPanel> infoList;

  private int currentIndex = 0;

  public InfoPanelListener() {
    super();
    createTimer();
    updateInfo();
  }

  private void createTimer() {
    timer = new Timer("InfoPanelListener timer");
    timer.schedule(new ReflectionTimerTask(null, this, "updateInfo"), 1000, UPDATE_INTERVAL);
  }

  public void updateInfo() {
    currentIndex++;
    if (infoList == null || currentIndex >= infoList.size()) {
      getNewList();
      currentIndex = 0;
    }
    if (this.connectedUsers.size() > 0) {
      ObjectMap<String, Object> state = new ObjectMap<String, Object>();
      if (currentIndex < infoList.size()) {
        state.put("data", infoList.get(currentIndex).getData());
      }
      sendState(PANEL_ID, "rInfoData", DATA_STATE, state);
    }
  }

  public void onSharedObjectDestroy(ISharedObjectBase so) {
    try {
      // base class does not define destroy hook in 0.8.0; just ensure timer cleanup
    } finally {
      timer.cancel();
    }
  }

  @SuppressWarnings("unchecked")
  private void getNewList() {
    ITransactionStrategy service = new InfoPanelService();
    infoList =
        (List<InfoPanel>)
            TransactionUtil.callTransaction(service, "getAvailableList", new ArrayList<Object>());
  }
}
