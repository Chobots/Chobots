package com.kavalok.messages;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.kavalok.transactions.TransactionUtil;
import com.kavalok.utils.timer.TimerUtil;

public class WordsCache {
  private static final int RELOAD_TIME = 120 * 60 * 1000;

  private static final int SAFE_RELOAD_TIME = 24 * 60 * 60 * 1000;

  private static WordsCache instance;

  private HashMap<MessageSafety, List<String>> words = new HashMap<MessageSafety, List<String>>();

  public static WordsCache getInstance() {
    synchronized (WordsCache.class) {
      if (instance == null) instance = new WordsCache();
    }
    return instance;
  }

  public WordsCache() {
    loadUnSafe();
    loadSafe();
  }

  public List<String> get(MessageSafety safety) {
    return words.get(safety);
  }

  public void loadUnSafe() {
    TransactionUtil.callTransaction(new UnSafeWordsLoader(words), "load", new ArrayList<Object>());
    TimerUtil.callAfter(this, "loadUnSafe", RELOAD_TIME);
  }

  public void loadSafe() {
    TransactionUtil.callTransaction(new SafeWordsLoader(words), "load", new ArrayList<Object>());
    TimerUtil.callAfter(this, "loadSafe", SAFE_RELOAD_TIME);
  }
}
