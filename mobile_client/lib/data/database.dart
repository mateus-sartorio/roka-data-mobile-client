import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:http/http.dart' as http;

class GlobalDatabase {
  List<Resident> residents = [];
  List<Collect> collects = [];

  final _myBox = Hive.box('globalDatabase');

  Future<void> fetchDataFromBackend() async {
    const String backendRoute = "http://10.0.2.2:3000/residents";
    Uri uri = Uri.parse(backendRoute);

    try {
      final Response response = await http.get(uri);
      List<dynamic> responseBody = jsonDecode(response.body);

      List<Resident> residents = [];
      for (dynamic residentMapObject in responseBody) {
        Resident resident = Resident(
            id: residentMapObject["id"],
            address: residentMapObject["address"],
            collects: [],
            hasPlaque: residentMapObject["has_plaque"],
            isOnWhatsappGroup: residentMapObject["is_on_whatsapp_group"],
            livesInJN: residentMapObject["lives_in_JN"],
            name: residentMapObject["name"],
            observations: residentMapObject["observations"],
            phone: residentMapObject["phone"],
            profession: residentMapObject["profession"],
            referencePoint: residentMapObject["reference_point"],
            registrationYear: residentMapObject["registration_year"],
            residentsInTheHouse: residentMapObject["residents_in_the_house"],
            rokaId: residentMapObject["roka_id"],
            situation: Situation.active,
            isNew: false);

        residents.add(resident);
      }

      const String collectsBackendEndpoint = "http://10.0.2.2:3000/collects";
      Uri collectsUri = Uri.parse(collectsBackendEndpoint);

      final Response collectsResponse = await http.get(collectsUri);
      List<dynamic> collectsResponseBody = jsonDecode(collectsResponse.body);

      List<Collect> collects = [];
      for (dynamic collectMapObject in collectsResponseBody) {
        Collect collect = Collect(
            id: collectMapObject["id"],
            ammount: double.parse(collectMapObject["ammount"]),
            collectedOn: DateTime.parse(collectMapObject["collected_on"]),
            residentId: collectMapObject["resident_id"],
            isNew: false);

        collects.add(collect);
      }

      saveData(residents, collects);
      loadData();
    } catch (e) {
      // TODO: treat any problema that may occur with the HTTP request
      if (kDebugMode) {
        print("deu bosta ao salvar");
        print(e);
      }
    }
  }

  void saveData(List<Resident> residents, List<Collect> collects) {
    _myBox.put("RESIDENTS", residents);
    _myBox.put("COLLECTS", collects);
  }

  // load the data from the database
  void loadData() {
    List<dynamic> residentsDynamicList = _myBox.get("RESIDENTS");
    List<Resident> residentsList = [];
    for (dynamic resident in residentsDynamicList) {
      residentsList.add(resident as Resident);
    }

    List<dynamic> collectsDynamicList = _myBox.get("COLLECTS");
    List<Collect> collectsList = [];
    for (dynamic collect in collectsDynamicList) {
      collectsList.add(collect as Collect);
    }

    residents = residentsList;
    collects = collectsList;
  }

  Future<void> saveNewCollect(Collect collect) async {
    const String backendRoute = "http://10.0.2.2:3000/collects";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "collected_on": collect.collectedOn.toIso8601String(),
      "resident_id": collect.residentId,
      "ammount": collect.ammount
    };

    var body = json.encode(data);

    try {
      await http.post(uri,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      // TODO: treat any problema that may occur with the HTTP request
      if (kDebugMode) {
        print("deu bosta");
      }
    }
  }
}
