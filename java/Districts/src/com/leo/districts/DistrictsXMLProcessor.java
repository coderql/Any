package com.leo.districts;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class DistrictsXMLProcessor {

  private static final String XML_FOLDER = "resources/";
  private static final String PROVINCE_XML_FILENAME = "Provinces.xml";
  private static final String CITIES_XML_FILENAME = "Cities.xml";
  private static final String DISTRICTS_XML_FILENAME = "Districts.xml";

  public static List<Province> parseOutProvinces() throws DocumentException {
    SAXReader provinceReader = new SAXReader();
    Document provinceDocument = provinceReader.read(new File(XML_FOLDER
        + PROVINCE_XML_FILENAME));
    Element provinceRoot = provinceDocument.getRootElement();

    SAXReader cityReader = new SAXReader();
    Document cityDocument = cityReader.read(new File(XML_FOLDER
        + CITIES_XML_FILENAME));
    Element cityRoot = cityDocument.getRootElement();

    SAXReader districtReader = new SAXReader();
    Document districtDocument = districtReader.read(new File(XML_FOLDER
        + DISTRICTS_XML_FILENAME));
    Element districtRoot = districtDocument.getRootElement();

    // traverse province
    List provincesNodes = provinceRoot.elements("Province");
    List<Province> provinces = new ArrayList<Province>();
    Iterator provincesIter = provincesNodes.iterator();
    while (provincesIter.hasNext()) {
      Element provinceNode = (Element) provincesIter.next();
      Province province = new Province();
      province.setId(provinceNode.attributeValue("ID"));
      province.setName(provinceNode.attributeValue("ProvinceName"));
      // find its cities
      List<City> cities = getCities(province.getId(), cityRoot, districtRoot);
      province.setCities(cities);
      // System.out.println(province);
      provinces.add(province);
    }
    return provinces;
  }

  private static List<City> getCities(String provinceId, Element cityXMLRoot,
      Element districtXMLRoot) {
    String xpath = "/Cities/City[@PID='" + provinceId + "']";
    List nodes = cityXMLRoot.selectNodes(xpath);
    List<City> cities = new ArrayList<City>();
    Iterator citiesIter = nodes.iterator();
    while (citiesIter.hasNext()) {
      Element cityNode = (Element) citiesIter.next();
      City city = new City();
      city.setId(cityNode.attributeValue("ID"));
      city.setName(cityNode.attributeValue("CityName"));
      // find its districts
      List<District> districts = getDistricts(city.getId(), districtXMLRoot);
      city.setDistricts(districts);
      // System.out.println(city);
      cities.add(city);
    }
    return cities;
  }

  private static List<District> getDistricts(String cityId,
      Element districtXMLRoot) {
    String xpath = "/Districts/District[@CID='" + cityId + "']";
    List nodes = districtXMLRoot.selectNodes(xpath);
    List<District> districts = new ArrayList<District>();
    Iterator districtsIter = nodes.iterator();
    while (districtsIter.hasNext()) {
      Element districtNode = (Element) districtsIter.next();
      District district = new District();
      district.setId(districtNode.attributeValue("ID"));
      district.setName(districtNode.attributeValue("DistrictName"));
      // System.out.println(district);
      districts.add(district);
    }
    return districts;
  }
}
