package com.kavalok.dto.stuff;

import org.red5.io.utils.ObjectMap;

import com.kavalok.cache.StuffTypeWrapper;
import com.kavalok.db.RobotType;
import com.kavalok.db.StuffType;
import com.kavalok.services.stuff.StuffTypes;

public class StuffTypeTO extends StuffTOBase {

  private Integer count;
  private String placement;
  private Boolean enabled = true;
  private Boolean premium;
  private ObjectMap<String, Object> robotInfo;
  private ObjectMap<String, Object> skuInfo;
  private String rainToken;

  public StuffTypeTO() {
    super();
  }

  public StuffTypeTO(RobotType type) {
    super();
    setId(type.getId());
    setFileName(type.getName());
    setType(StuffTypes.ROBOT);
    setName(type.getName());
    setPrice(type.getPrice());
    setHasColor(type.getHasColor());
    setPlacement(type.getPlacement());
    setPremium(type.getPremium());
  }

  public StuffTypeTO(StuffType type) {
    super();
    setId(type.getId());
    setFileName(type.getFileName());
    setType(type.getType());
    setName(type.getName());
    setPrice(type.getPrice());
    setHasColor(type.getHasColor());
    this.placement = type.getPlacement();
    this.premium = type.getPremium();
  }

  public StuffTypeTO(StuffTypeWrapper type) {
    super();
    setId(type.getId());
    setFileName(type.getFileName());
    setType(type.getType());
    setName(type.getName());
    setPrice(type.getPrice());
    setHasColor(type.getHasColor());
    this.placement = type.getPlacement();
    this.premium = type.getPremium();
  }

  public Boolean getEnabled() {
    return enabled;
  }

  public void setEnabled(Boolean enabled) {
    this.enabled = enabled;
  }

  public String getPlacement() {
    return placement;
  }

  public void setPlacement(String placement) {
    this.placement = placement;
  }

  public Boolean getPremium() {
    return premium;
  }

  public void setPremium(Boolean premium) {
    this.premium = premium;
  }

  public ObjectMap<String, Object> getRobotInfo() {
    return robotInfo;
  }

  public void setRobotInfo(ObjectMap<String, Object> robotInfo) {
    this.robotInfo = robotInfo;
  }

  public ObjectMap<String, Object> getSkuInfo() {
    return skuInfo;
  }

  public void setSkuInfo(ObjectMap<String, Object> skuInfo) {
    this.skuInfo = skuInfo;
  }

  public Integer getCount() {
    return count;
  }

  public void setCount(Integer count) {
    this.count = count;
  }

  public String getRainToken() {
    return rainToken;
  }

  public void setRainToken(String rainToken) {
    this.rainToken = rainToken;
  }
}
