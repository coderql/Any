package com.leo.districts;

import java.util.ArrayList;
import java.util.List;

public class City extends BaseModel {

  private List<District> districts;

  public City() {
  }

  public City(String id, String name, List<District> districts) {
    super(id, name);
    this.districts = districts;
  }

  public List<District> getDistricts() {
    return districts;
  }

  public void setDistricts(List<District> districts) {
    this.districts = districts;
  }

  public void addDistrict(District district) {
    if (districts == null) {
      districts = new ArrayList<District>();
    }
    districts.add(district);
  }

}
