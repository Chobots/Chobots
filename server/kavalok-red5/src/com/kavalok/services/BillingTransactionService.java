package com.kavalok.services;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.beanutils.BeanUtils;
import org.red5.io.utils.ObjectMap;

import com.kavalok.KavalokApplication;
import com.kavalok.billing.transaction.BillingTransactionUtil;
import com.kavalok.billing.transaction.CitizenMembershipProduct;
import com.kavalok.dao.RobotSKUDAO;
import com.kavalok.dao.SKUDAO;
import com.kavalok.dao.UserDAO;
import com.kavalok.db.RobotSKU;
import com.kavalok.db.RobotTransaction;
import com.kavalok.db.RobotType;
import com.kavalok.db.SKU;
import com.kavalok.db.Transaction;
import com.kavalok.db.User;
import com.kavalok.dto.membership.SKUTO;
import com.kavalok.services.common.DataServiceBase;
import com.kavalok.user.UserAdapter;
import com.kavalok.user.UserManager;

public class BillingTransactionService extends DataServiceBase {

  public ObjectMap<String, Object> requestMembership(
      String successMessage, Integer skuId, String source, Integer partnerUserId) throws Exception {
    SKUDAO skuDao = new SKUDAO(getSession());
    SKU sku = skuDao.findById(skuId.longValue());
    CitizenMembershipProduct product = new CitizenMembershipProduct(sku.getTerm());
    UserDAO userDAO = new UserDAO(getSession());
    User user = null;
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (userAdapter != null) {
      user = userDAO.findById(userAdapter.getUserId());
    }
    if (user == null && partnerUserId > 0) {
      user = userDAO.findById(partnerUserId.longValue());
    }
    Transaction trans = makeNewTransaction(user, sku, null, product, successMessage, source);
    return KavalokApplication.getInstance()
        .getApplicationConfig()
        .getBillingGateway()
        .generateBillingForm(trans);
  }

  public ObjectMap<String, Object> requestRobotsItem(Integer skuId, String source)
      throws Exception {
    User user = null;
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (userAdapter != null) {
      user = new UserDAO(getSession()).findById(userAdapter.getUserId());
    }
    RobotTransaction trans =
        BillingTransactionUtil.createRobotTransaction(getSession(), user, skuId, source);
    return KavalokApplication.getInstance()
        .getApplicationConfig()
        .getRobotsBillingGateway()
        .generateBillingForm(trans);
  }

  public ObjectMap<String, Object> requestPayedItem(Integer skuId, String source) throws Exception {
    User user = null;
    UserAdapter userAdapter = UserManager.getInstance().getCurrentUser();
    if (userAdapter != null) {
      user = new UserDAO(getSession()).findById(userAdapter.getUserId());
    }
    Transaction trans = makeNewTransaction(user, skuId, source);
    return KavalokApplication.getInstance()
        .getApplicationConfig()
        .getPremiumItemBillingGateway()
        .generateBillingForm(trans);
  }

  public ObjectMap<String, Object> requestMembershipNoUser(
      String successMessage, Integer skuId, String source, Integer partnerUserId) throws Exception {
    SKUDAO skuDao = new SKUDAO(getSession());
    SKU sku = skuDao.findById(skuId.longValue());
    CitizenMembershipProduct product = new CitizenMembershipProduct(sku.getTerm());
    Transaction trans = makeNewTransaction(null, sku, null, product, successMessage, source);
    return KavalokApplication.getInstance()
        .getApplicationConfig()
        .getBillingGateway()
        .generateBillingForm(trans);
  }

  private Transaction makeNewTransaction(
      User user, SKU sku, Integer type, Object product, String successMessage, String source)
      throws Exception {
    System.out.println(
        String.format(
            "Creating transaction for user %1s, id: %2s, product: %3s",
            user != null ? user.getLogin() : "",
            user != null ? user.getId() : "",
            product.toString()));
    return BillingTransactionUtil.createTransaction(
        getSession(), user, successMessage, sku, product, source);
  }

  private Transaction makeNewTransaction(User user, Integer skuId, String source) throws Exception {
    System.out.println(
        String.format(
            "Creating transaction for user %1s, id: %2s",
            user != null ? user.getLogin() : "", user != null ? user.getId() : ""));
    return BillingTransactionUtil.createTransaction(
        getSession(), user, null, skuId.longValue(), null, source);
  }

  public List<SKUTO> getPayedItemSKU(Integer typeId)
      throws IllegalAccessException, InvocationTargetException {
    SKUDAO dao = new SKUDAO(getSession());
    List<SKUTO> result = new ArrayList<SKUTO>();
    addSKU(dao, result, typeId, false);
    addSKU(dao, result, typeId, true);

    return result;
  }

  public List<SKUTO> getRobotsSKU(Integer itemId)
      throws IllegalAccessException, InvocationTargetException {
    RobotSKUDAO dao = new RobotSKUDAO(getSession());
    List<SKUTO> result = new ArrayList<SKUTO>();
    addSKU(dao, result, itemId, false);
    addSKU(dao, result, itemId, true);

    return result;
  }

  public List<SKUTO> getMembershipSKUs() throws IllegalAccessException, InvocationTargetException {
    SKUDAO dao = new SKUDAO(getSession());
    List<SKUTO> result = new ArrayList<SKUTO>();
    addSKU(dao, result, 1, false);
    addSKU(dao, result, 6, false);
    addSKU(dao, result, 12, false);

    addSKU(dao, result, 1, true);
    addSKU(dao, result, 6, true);
    addSKU(dao, result, 12, true);

    return result;
  }

  private void addSKU(SKUDAO dao, List<SKUTO> result, Integer typeId, boolean specialOffer)
      throws IllegalAccessException, InvocationTargetException {
    SKU sku = dao.findActiveStuffSKU(typeId.longValue(), specialOffer);
    if (sku != null) {
      SKUTO to = new SKUTO();
      BeanUtils.copyProperties(to, sku);
      result.add(to);
    } else {
      result.add(null);
    }
  }

  private void addSKU(RobotSKUDAO dao, List<SKUTO> result, Integer itemId, boolean specialOffer)
      throws IllegalAccessException, InvocationTargetException {
    RobotType rt = new RobotType(itemId.longValue());
    RobotSKU sku = dao.findActiveSKU(rt, specialOffer);
    if (sku != null) {
      SKUTO to = new SKUTO();
      BeanUtils.copyProperties(to, sku);
      result.add(to);
    } else {
      result.add(null);
    }
  }

  private void addSKU(SKUDAO dao, List<SKUTO> result, int period, boolean specialOffer)
      throws IllegalAccessException, InvocationTargetException {
    SKU sku = dao.findActiveMemebershipSKU(period, specialOffer);
    if (sku != null) {
      SKUTO to = new SKUTO();
      BeanUtils.copyProperties(to, sku);
      result.add(to);
    } else {
      result.add(null);
    }
  }
}
