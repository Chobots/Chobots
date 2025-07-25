package com.kavalok.db;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.ManyToOne;
import javax.persistence.Transient;
import javax.validation.constraints.NotNull;

import org.red5.io.utils.ObjectMap;

import com.kavalok.utils.HibernateUtil;

@Entity
public class Message extends ModelBase implements Serializable {

  private static final long serialVersionUID = 1L;

  private GameChar recipient;

  private byte[] serialized;

  private Date dateTime = new Date();

  public Message() {
    super();
    // TODO Auto-generated constructor stub
  }

  public Message(GameChar recipient, ObjectMap<String, Object> command) {
    setRecipient(recipient);
    setCommand(command);
  }

  @NotNull
  @ManyToOne(fetch = FetchType.LAZY)
  public GameChar getRecipient() {
    return recipient;
  }

  public void setRecipient(GameChar recipient) {
    this.recipient = recipient;
  }

  @Transient
  public Object getCommand() {

    byte[] buf = serialized;

    return HibernateUtil.deserialize(buf);
  }

  @Transient
  public void setCommand(Object command) {
    this.serialized = HibernateUtil.serialize(command);
  }

  @NotNull
  public Date getDateTime() {
    return dateTime;
  }

  public void setDateTime(Date dateTime) {
    this.dateTime = dateTime;
  }

  @NotNull
  @Column(columnDefinition = "BLOB")
  public byte[] getSerialized() {
    return serialized;
  }

  public void setSerialized(byte[] serialized) {
    this.serialized = serialized;
  }
}
