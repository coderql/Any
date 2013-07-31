package com.leo.districts;

public abstract class BaseModel {

  public BaseModel() {
  }

  public BaseModel(String id, String name) {
    super();
    this.id = id;
    this.name = name;
  }

  private String id;
  private String name;

  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  @Override
  public String toString() {
    return this.getClass().getName() + " [id=" + id + ", name=" + name + "]";
  }

}
