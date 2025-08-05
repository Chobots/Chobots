package com.kavalok.utils;

import java.util.ArrayList;

import org.red5.server.api.so.ISharedObject;
import org.red5.server.api.so.ISharedObjectServiceListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.kavalok.sharedObjects.ClassFactory;
import com.kavalok.sharedObjects.CombatListener;
import com.kavalok.sharedObjects.GameEnterFactory;
import com.kavalok.sharedObjects.InfoPanelListener;
import com.kavalok.sharedObjects.KavalokSharedObjectSecurity;
import com.kavalok.sharedObjects.NichosRopeSOListener;
import com.kavalok.sharedObjects.RopeSOListener;
import com.kavalok.sharedObjects.SOListener;
import com.kavalok.sharedObjects.SpaceRacingSOListener;
import com.kavalok.sharedObjects.TradeListener;

public class SOManager implements ISharedObjectServiceListener {

  public static Logger logger = LoggerFactory.getLogger(SOManager.class);

  private ArrayList<ListenerEntry> factories = new ArrayList<ListenerEntry>();

  public SOManager() {
    super();
    initialize();
  }

  public void initialize() {
    registerFactory("|gameSpaceRacing", new ClassFactory(SpaceRacingSOListener.class));
    registerFactory("trade|", new ClassFactory(TradeListener.class));
    registerFactory("locationRope", new ClassFactory(RopeSOListener.class));
    registerFactory("missionNichos", new ClassFactory(NichosRopeSOListener.class));
    registerFactory("gameSweetBattle", new GameEnterFactory(3));
    registerFactory("gameSpaceRacing", new GameEnterFactory(5));
    registerFactory("gameGarbageCollector", new GameEnterFactory(6));
    registerFactory("gameHunting", new GameEnterFactory(2));
    registerFactory("robotCombat", new GameEnterFactory(2));
    registerFactory(InfoPanelListener.PANEL_ID, new ClassFactory(InfoPanelListener.class));
    registerFactory(CombatListener.REMOTE_PREFIX, new ClassFactory(CombatListener.class));
  }

  private void registerFactory(String prefix, ISOFactory factory) {
    factories.add(new ListenerEntry(prefix, factory));
  }

  @Override
  public void onSharedObjectCreate(ISharedObject sharedObject) {
    SOListener listener = null;
    for (ListenerEntry entry : factories) {
      if (sharedObject.getName().startsWith(entry.getPrefix())) {
        ISOFactory factory = entry.getFactory();
        listener = factory.create();
        break;
      }
    }
    if (listener == null) listener = new SOListener();

    // Register the security handler with the shared object
    sharedObject.registerSharedObjectSecurity(new KavalokSharedObjectSecurity());

    sharedObject.addSharedObjectListener(listener);
    listener.initialize(sharedObject);
  }
}

class ListenerEntry {
  private String prefix;
  private ISOFactory factory;

  public ListenerEntry(String prefix, ISOFactory factory) {
    super();
    this.prefix = prefix;
    this.factory = factory;
  }

  public String getPrefix() {
    return prefix;
  }

  public void setPrefix(String prefix) {
    this.prefix = prefix;
  }

  public ISOFactory getFactory() {
    return factory;
  }

  public void setFactory(ISOFactory factory) {
    this.factory = factory;
  }
}
