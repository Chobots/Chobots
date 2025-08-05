package com.kavalok.db;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Transient;
import javax.validation.constraints.NotNull;

import com.kavalok.permissions.AccessUser;
import com.kavalok.utils.StringUtil;

@Entity
public class User extends LoginModelBase {

  private String email;

  private boolean enabled = true;

  private boolean baned = false;

  private String banReason;

  private boolean chatEnabled = true; // used to control chat by parent

  private boolean helpEnabled = true;

  private User invitedBy;

  private GameChar gameChar;

  private MarketingInfo marketingInfo;

  private boolean parent;

  private boolean agent;

  private boolean moderator;

  private Boolean guest = false;

  private String activationKey;

  private String locale;

  private Date citizenExpirationDate;

  private int citizenTryCount;

  private Boolean activated;

  private Boolean acceptRequests = true;

  private Boolean drawEnabled = true;

  private int soundVolume = 50;

  private int musicVolume = 50;

  private Boolean showTips = false;

  private Boolean deleted;

  private List<UserDance> dances;

  private MembershipInfo membershipInfo;

  private UserExtraInfo userExtraInfo;

  private List<User> friends = new ArrayList<User>();

  private Boolean superUser = false;

  private RobotTeam robotTeam;

  private Long robotTeam_id;

  private Long gameChar_id;

  private String salt;

  private String loginToken;

  public User() {
    super();
  }

  public User(Long id) {
    super();
    this.setId(id);
  }

  public User(Long id, String login) {
    super();
    this.setId(id);
    this.setLogin(login);
  }

  public User(String login, String password) {
    super();
    setLogin(login);
    setPassword(password);
  }

  @SuppressWarnings("unchecked")
  @Override
  @Transient
  public Class getAccessType() {
    return AccessUser.class;
  }

  @NotNull
  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  @OneToOne(fetch = FetchType.LAZY)
  public GameChar getGameChar() {
    return gameChar;
  }

  @Transient
  public GameChar getGameCharIdentifier() {
    if (getGameChar_id() == null) return null;
    GameChar result = new GameChar();
    result.setId(getGameChar_id());
    return result;
  }

  public void setGameChar(GameChar character) {
    this.gameChar = character;
  }

  @Column(columnDefinition = "boolean default true")
  public boolean isEnabled() {
    return enabled;
  }

  public void setEnabled(boolean enabled) {
    this.enabled = enabled;
  }

  @Column(columnDefinition = "boolean default true")
  public boolean isChatEnabled() {
    return chatEnabled;
  }

  public void setChatEnabled(boolean chatEnabled) {
    this.chatEnabled = chatEnabled;
  }

  @Column(columnDefinition = "boolean default true")
  public boolean isHelpEnabled() {
    return helpEnabled;
  }

  public void setHelpEnabled(boolean helpEnabled) {
    this.helpEnabled = helpEnabled;
  }

  @Column(columnDefinition = "boolean default false")
  public boolean isBaned() {
    return baned;
  }

  public void setBaned(boolean baned) {
    this.baned = baned;
  }

  @Column(columnDefinition = "boolean default false")
  public boolean isParent() {
    return parent;
  }

  public void setParent(boolean parent) {
    this.parent = parent;
  }

  @Transient
  public Boolean isActive() {
    return (activated == null) ? StringUtil.isEmptyOrNull(getActivationKey()) : activated;
  }

  public String getActivationKey() {
    return activationKey;
  }

  public void setActivationKey(String activationKey) {
    this.activationKey = activationKey;
  }

  public String getLocale() {
    return locale;
  }

  public void setLocale(String locale) {
    this.locale = locale;
  }

  @Column(columnDefinition = "boolean default false")
  public boolean isAgent() {
    return agent;
  }

  public void setAgent(boolean agent) {
    this.agent = agent;
  }

  @Column(columnDefinition = "boolean default false")
  public boolean isModerator() {
    return moderator;
  }

  public void setModerator(boolean moderator) {
    this.moderator = moderator;
  }

  @OneToOne(fetch = FetchType.LAZY)
  public MarketingInfo getMarketingInfo() {
    return marketingInfo;
  }

  public void setMarketingInfo(MarketingInfo marketingInfo) {
    this.marketingInfo = marketingInfo;
  }

  public Date getCitizenExpirationDate() {
    return citizenExpirationDate;
  }

  public void setCitizenExpirationDate(Date citizenExpirationDate) {
    this.citizenExpirationDate = citizenExpirationDate;
  }

  @Column(columnDefinition = "boolean default true")
  public Boolean getAcceptRequests() {
    return acceptRequests;
  }

  public void setAcceptRequests(Boolean acceptPrivateMessages) {
    this.acceptRequests = acceptPrivateMessages;
  }

  @Column(columnDefinition = "boolean default true")
  public Boolean getDrawEnabled() {
    return drawEnabled;
  }

  public void setDrawEnabled(Boolean drawEnabled) {
    this.drawEnabled = drawEnabled;
  }

  @Transient
  public boolean isCitizen() {
    return citizenExpirationDate != null && citizenExpirationDate.after(new Date());
  }

  public String getBanReason() {
    return banReason;
  }

  public void setBanReason(String banReason) {
    this.banReason = banReason;
  }

  @Column(nullable = false, columnDefinition = "int(11) default 0")
  public int getCitizenTryCount() {
    return citizenTryCount;
  }

  public void setCitizenTryCount(int citizenTryCount) {
    this.citizenTryCount = citizenTryCount;
  }

  public Boolean getActivated() {
    return activated;
  }

  public void setActivated(Boolean active) {
    this.activated = (active == null) ? StringUtil.isEmptyOrNull(getActivationKey()) : active;
  }

  public Boolean getGuest() {
    return guest;
  }

  public void setGuest(Boolean guest) {
    this.guest = guest == null ? false : guest;
  }

  @Column(nullable = false, columnDefinition = "int(3) default 50")
  public int getSoundVolume() {
    return soundVolume;
  }

  public void setSoundVolume(int soundVolume) {
    this.soundVolume = soundVolume;
  }

  @Column(nullable = false, columnDefinition = "int(3) default 50")
  public int getMusicVolume() {
    return musicVolume;
  }

  public void setMusicVolume(int musicVolume) {
    this.musicVolume = musicVolume;
  }

  @Column(nullable = false, columnDefinition = "bit(3) default true")
  public Boolean getShowTips() {
    return showTips;
  }

  public void setShowTips(Boolean showTips) {
    this.showTips = showTips;
  }

  @OneToOne(fetch = FetchType.LAZY)
  public User getInvitedBy() {
    return invitedBy;
  }

  public void setInvitedBy(User invitedBy) {
    this.invitedBy = invitedBy;
  }

  @Column(nullable = false, columnDefinition = "bit(3) default false")
  public Boolean getDeleted() {
    return deleted;
  }

  public void setDeleted(Boolean deleted) {
    this.deleted = deleted;
  }

  @OneToOne(fetch = FetchType.LAZY)
  public MembershipInfo getMembershipInfo() {
    return membershipInfo;
  }

  public void setMembershipInfo(MembershipInfo membershipInfo) {
    this.membershipInfo = membershipInfo;
  }

  @OneToOne(fetch = FetchType.LAZY)
  public UserExtraInfo getUserExtraInfo() {
    return userExtraInfo;
  }

  public void setUserExtraInfo(UserExtraInfo userExtraInfo) {
    this.userExtraInfo = userExtraInfo;
  }

  @Transient
  public List<String> getDancesData() {
    List<String> result = new ArrayList<String>();
    for (UserDance dance : getDances()) {
      result.add(dance.getDance());
    }
    return result;
  }

  @OneToMany(fetch = FetchType.LAZY)
  public List<UserDance> getDances() {
    return dances;
  }

  public void setDances(List<UserDance> dances) {
    this.dances = dances;
  }

  @NotNull
  @ManyToMany(fetch = FetchType.LAZY)
  public List<User> getFriends() {
    return friends;
  }

  public void setFriends(List<User> friends) {
    this.friends = friends;
  }

  @Column(nullable = false, columnDefinition = "bit(3) default false")
  public Boolean getSuperUser() {
    return superUser;
  }

  public void setSuperUser(Boolean superUser) {
    this.superUser = superUser;
  }

  @ManyToOne(fetch = FetchType.LAZY)
  public RobotTeam getRobotTeam() {
    return robotTeam;
  }

  public void setRobotTeam(RobotTeam robotTeam) {
    this.robotTeam = robotTeam;
  }

  @Column(insertable = false, updatable = false)
  public Long getRobotTeam_id() {
    return robotTeam_id;
  }

  public void setRobotTeam_id(Long robotTeam_id) {
    this.robotTeam_id = robotTeam_id;
  }

  @Column(insertable = false, updatable = false)
  public Long getGameChar_id() {
    return gameChar_id;
  }

  public void setGameChar_id(Long gameChar_id) {
    this.gameChar_id = gameChar_id;
  }

  @Column(length = 64)
  public String getSalt() {
    return salt;
  }

  public void setSalt(String salt) {
    this.salt = salt;
  }

  public String getLoginToken() {
    return loginToken;
  }

  public void setLoginToken(String loginToken) {
    this.loginToken = loginToken;
  }
}
