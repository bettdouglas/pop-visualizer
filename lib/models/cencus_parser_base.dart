import 'dart:io';
import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:df/df.dart';
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';

/// Checks if you are awesome. Spoiler: you are.
class Awesome {

  static Future<List<County>> readGeoJSON(String fileName) async {

    final geoJsonFile = File(fileName);
    final fileContent = await geoJsonFile.readAsString();

    final geoJson = GeoJson();

    try {
      await geoJson.parse(fileContent);
    } catch (e) {
      print(e);
    }
    final counties = <County>[];
    var countyData = await readCountyPopData('assets/unicef-data.csv');
    print(countyData.length);
    // geoJson.features.fir
    geoJson.features.forEach((feature) {
      var county = County.fromGeoJSON(feature,countyData);
      counties.add(county);
    });
    return counties;
  }

  static Future<String> readFileAsString(String fileName) async {
    return await rootBundle.loadString(fileName);
  }

  static Future<List<dynamic>> readCountyPopData(String fileName) async {
    var d = FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);
    var csvString = await readFileAsString(fileName);
    var places =
        CsvToListConverter().convert(csvString, csvSettingsDetector: d);
    return places.skip(1).toList();
  }

  static Future<List<Map<String, dynamic>>> readAsDF(String fileName) async {
    var df = await DataFrame.fromCsv('assets/unicef-data.csv');
    return df.rows;
  }
}

class County {
  int countyId;
  String countyName;
  double area;
  GeoJsonMultiPolygon polygon;
  Map<int,int> yearlyStats;

  County({
    this.countyId,this.countyName,this.area,this.polygon,this.yearlyStats
  });

  factory County.fromGeoJSON(GeoJsonFeature feature,List<List<dynamic>> stats) {
    var countyID = feature.properties['COUNTY_COD'];
    return County(
      countyId: countyID,
      area: feature.properties['Shape_Area'],
      countyName: feature.properties['COUNTY_NAM'],
      polygon: feature.geometry as GeoJsonMultiPolygon,
      yearlyStats: readStatsFile(stats,countyID)
    );
  }

  static Map<int,int> readStatsFile(List<List<dynamic>> allStats,int countyId) {
    print(countyId);
  var stats = allStats.firstWhere((element) => element[1] == countyId,orElse: ()=> null);

    var p2009 = int.parse(_removeCommas(stats[3]));
    var p2010 = int.parse(_removeCommas(stats[4]));
    var p2011 = int.parse(_removeCommas(stats[5]));
    var p2012 = int.parse(_removeCommas(stats[6]));
    var p2013 = int.parse(_removeCommas(stats[7]));
    var p2014 = int.parse(_removeCommas(stats[8]));
    var p2015 = int.parse(_removeCommas(stats[9]));
    var p2016 = int.parse(_removeCommas(stats[10]));
    var p2017 = int.parse(_removeCommas(stats[11]));
    var p2018 = int.parse(_removeCommas(stats[12]));
    var p2019 = int.parse(_removeCommas(stats[13]));

    return {
      2009: p2009,
      2010: p2010,
      2011: p2011,
      2012: p2012,
      2013: p2013,
      2014: p2014,
      2015: p2015,
      2016: p2016,
      2017: p2017,
      2018: p2018,
      2019: p2019,
    };

  }

  static String _removeCommas(String str) {
    return str.replaceAll(',', '');
  }

  @override
  String toString() => 'County($countyId,$countyName)';
}
