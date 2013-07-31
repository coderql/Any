package com.leo.districts;

import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

public class DistrictsJSONProcessor {

  public static String toJSON(List<Province> provinces) {
    JSONObject outer = new JSONObject();
    JSONArray provinceArr = new JSONArray();
    for (Province province : provinces) {
      JSONObject provinceObj = new JSONObject();
      provinceObj.put("id", province.getId());
      provinceObj.put("name", province.getName());
      JSONArray cityArray = new JSONArray();
      List<City> cities = province.getCities();
      for (City city : cities) {
        JSONObject cityObj = new JSONObject();
        cityObj.put("id", city.getId());
        cityObj.put("name", city.getName());
        JSONArray districtArray = new JSONArray();
        List<District> districts = city.getDistricts();
        for (District district : districts) {
          JSONObject districtObj = new JSONObject();
          districtObj.put("id", district.getId());
          districtObj.put("name", district.getName());
          districtArray.put(districtObj);
        }
        cityObj.put("disctricts", districtArray);
        cityArray.put(cityObj);
      }
      provinceObj.put("cities", cityArray);
      provinceArr.put(provinceObj);
    }
    outer.put("provinces", provinceArr);
    return outer.toString(2);
  }

}
