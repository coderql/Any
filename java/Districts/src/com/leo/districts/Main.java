package com.leo.districts;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;

import org.dom4j.DocumentException;

public class Main {

  public static void main(String[] args) throws DocumentException, IOException {
    List<Province> provinces = DistrictsXMLProcessor.parseOutProvinces();
    String json = DistrictsJSONProcessor.toJSON(provinces);
    BufferedWriter writer = null;
    try {
      writer = new BufferedWriter(new FileWriter("json"));
      writer.write(json);
    } finally {
      if (writer != null) {
        writer.close();
      }
    }
  }
}
