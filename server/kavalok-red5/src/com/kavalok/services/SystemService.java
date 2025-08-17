package com.kavalok.services;

import java.util.Date;

import com.kavalok.dto.ServerPropertiesTO;
import com.kavalok.services.common.DataServiceNotTransactionBase;
import com.kavalok.user.UserManager;
import com.kavalok.user.UserAdapter;

/**
 * Service for system-level operations that don't require database transactions.
 */
public class SystemService extends DataServiceNotTransactionBase {

    public ServerPropertiesTO getServerProperties() {
        return new ServerPropertiesTO();
    }

    public void clientTick() {
      UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
      if (userAdapter != null) {
          userAdapter.setLastTick(new Date());
      }
    }

    public Date getSystemDate() {
        return new Date();
    }
}
