package com.kavalok.billing;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;
import org.red5.io.utils.ObjectMap;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import com.kavalok.dto.membership.SKUTO;
import com.kavalok.dto.stuff.StuffTypeTO;
import com.kavalok.services.BillingTransactionService;
import com.kavalok.services.StuffServiceNT;

public class MembershipPageService {

  private static final Map<String, String> CURRENCY_SIGNS = new HashMap<String, String>();

  private static final Map<String, String> CURRENCY_TEXT = new HashMap<String, String>();

  static {
    CURRENCY_SIGNS.put("usdSign", "$");
    CURRENCY_SIGNS.put("euroSign", "EUR");
    CURRENCY_SIGNS.put("inrSign", "Rs");

    CURRENCY_TEXT.put("usd", "USD");
    CURRENCY_TEXT.put("usdCents", "cents");
    CURRENCY_TEXT.put("euro", "EUR");
    CURRENCY_TEXT.put("euroCents", "cents");
    CURRENCY_TEXT.put("inr", "INR");
    CURRENCY_TEXT.put("inrCents", "cents");
  }

  public static List<SKUHtml> getSKUs() {

    List<SKUHtml> result = new ArrayList<SKUHtml>(3);
    result.add(null);
    result.add(null);
    result.add(null);

    List<StuffTypeTO> itemsOfTheMonth = new ArrayList<StuffTypeTO>(3);
    itemsOfTheMonth.add(null);
    itemsOfTheMonth.add(null);
    itemsOfTheMonth.add(null);

    Logger logger = Red5LoggerFactory.getLogger(MembershipPageService.class);

    StuffServiceNT stuffService = new StuffServiceNT();
    try {
      stuffService.beforeCall();
      itemsOfTheMonth = stuffService.getItemOfTheMonthType();
      stuffService.afterCall();
    } catch (Exception e) {
      stuffService.afterError(e);
      logger.error("Error processing transaction", e);
      e.printStackTrace();
    }

    BillingTransactionService billingTransactionService = new BillingTransactionService();
    try {
      billingTransactionService.beforeCall();

      List<SKUTO> skus = billingTransactionService.getMembershipSKUs();

      result.set(
          0,
          getSkuHTML(
              skus.get(0), skus.get(3), false, itemsOfTheMonth.get(0), billingTransactionService));
      result.set(
          1,
          getSkuHTML(
              skus.get(1), skus.get(4), false, itemsOfTheMonth.get(1), billingTransactionService));
      result.set(
          2,
          getSkuHTML(
              skus.get(2), skus.get(5), true, itemsOfTheMonth.get(2), billingTransactionService));

      billingTransactionService.afterCall();
    } catch (Exception e) {
      billingTransactionService.afterError(e);
      logger.error("Error processing transaction", e);
    }

    return result;
  }

  @SuppressWarnings("unchecked")
  private static SKUHtml getSkuHTML(
      SKUTO sku,
      SKUTO skuOffer,
      boolean dayMonthSpecialPrice,
      StuffTypeTO stuffTypeTO,
      BillingTransactionService billingTransactionService)
      throws Exception {
    if (sku == null) {
      return null;
    }
    SKUHtml result = new SKUHtml();
    BeanUtils.copyProperties(result, sku);
    if (skuOffer != null) {
      result.setSpecialOfferName(skuOffer.getSpecialOfferName());
      result.setDiscountPrice(skuOffer.getPrice());
      result.setDiscountPriceStr(skuOffer.getPriceStr());
      result.setDiscount(true);
      result.setId(skuOffer.getId());
    } else {
      result.setSpecialOfferName("");
    }
    if (stuffTypeTO != null) {
      result.setFileName(stuffTypeTO.getFileName());
      result.setItemOfTheMonthName(stuffTypeTO.getName());
    }

    ObjectMap<String, Object> params =
        billingTransactionService.requestMembershipNoUser(
            "Memberhsip for " + result.getTerm() + " month bought",
            result.getId().intValue(),
            "site",
            0);
    result.setUrl((String) params.get("url"));
    StringBuffer formHidden = new StringBuffer("");
    ObjectMap<String, String> parameters = (ObjectMap<String, String>) params.get("parameters");
    for (Iterator iterator = parameters.entrySet().iterator(); iterator.hasNext(); ) {
      Map.Entry<String, String> entry = (Map.Entry<String, String>) iterator.next();
      formHidden
          .append("<input type='hidden' name=\"")
          .append(entry.getKey())
          .append("\" value=\"")
          .append(entry.getValue())
          .append("\">\n");
    }
    result.setParams(formHidden.toString());

    Double specialPrice;
    Integer specialPriceInt;
    boolean useCents = false;

    Double specialPriceOffer = 0d;
    Integer specialPriceIntOffer = 0;

    Double specialPeriod = dayMonthSpecialPrice ? sku.getTerm() : sku.getTerm() * 30.5;

    specialPrice = sku.getPrice() / specialPeriod;
    if (skuOffer != null) {
      specialPriceOffer = skuOffer.getPrice() / specialPeriod;
    }
    if (specialPrice < 1) {
      useCents = true;
      specialPrice = specialPrice * 100;
      specialPriceInt = (int) (specialPrice + 1);

      if (skuOffer != null) {
        specialPriceOffer = specialPriceOffer * 100;
        specialPriceIntOffer = (int) (specialPriceOffer + 1);
      }
    } else {
      specialPriceInt = (int) (specialPrice + 1);

      if (skuOffer != null) {
        specialPriceIntOffer = (int) (specialPriceOffer + 1);
      }
    }
    result.setDayMonth(dayMonthSpecialPrice);
    result.setUseCents(useCents);
    result.setOfferPrice(specialPriceInt);
    result.setOfferDiscountPrice(specialPriceIntOffer);

    result.setOfferCurrency(
        useCents
            ? CURRENCY_TEXT.get(result.getCurrencyCentsText())
            : CURRENCY_TEXT.get(result.getCurrencyText()));

    result.setCurrencySign(CURRENCY_SIGNS.get(result.getCurrencySign()));

    return result;
  }
}
