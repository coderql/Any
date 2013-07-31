package com.leo.districts;

import java.util.ArrayList;
import java.util.List;

public class Province extends BaseModel {

  private List<City> cities;

  public Province() {

  }

  public Province(String id, String name, List<City> cities) {
    super(id, name);
    this.cities = cities;
  }

  public List<City> getCities() {
    return cities;
  }

  public void setCities(List<City> cities) {
    this.cities = cities;
  }

  public void addCity(City city) {
    if (cities == null) {
      cities = new ArrayList<City>();
    }
    cities.add(city);
  }

}
