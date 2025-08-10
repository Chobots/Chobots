package com.kavalok.sharedObjects;

import java.util.Timer;

import org.red5.server.api.so.ISharedObjectBase;

public class NichosRopeSOListener extends SOListener {

  private static final float MAX_ROPE_POSITION = 30;

  private static final String ID = "NichosRopeEntryPoint";

  private float currentPosition = 0;

  private Timer timer;

  protected boolean stopTimer = false;

  private NichosRopeTimer nichosRopeTimer;

  public NichosRopeSOListener() {
    super();
    Timer timer = new Timer("NichosRopeSOListener timer");
    nichosRopeTimer = new NichosRopeTimer(timer, this);
    timer.schedule(nichosRopeTimer, 200);
  }

  public void moveRope() {
    if (currentPosition < 0) {
      rMoveRope(1);
    }
  }

  public Boolean rMoveRope(Integer diff) {
    currentPosition += diff;
    callClient(ID, "rSetRopePosition", currentPosition, -currentPosition);
    if (Math.abs(currentPosition) > MAX_ROPE_POSITION) {
      callClient(ID, "rEndGame", "Left");
      currentPosition = 0;
      callClient(ID, "rSetRopePosition", currentPosition, -currentPosition);
    }
    return true;
  }

  public void onSharedObjectDestroy(ISharedObjectBase so) {
    stopTimer = true;
    try {
      // base class does not define destroy hook in 0.8.0; just ensure timer cleanup
    } finally {
      timer.cancel();
      nichosRopeTimer.cancel();
    }
  }
}
