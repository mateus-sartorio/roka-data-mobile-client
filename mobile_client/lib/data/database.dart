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

      saveData(residents);
    } catch (e) {
      // TODO: treat any problema that may occur with the HTTP request
      if (kDebugMode) {
        print("deu bosta");
      }
    }
  }

  void saveData(List<Resident> residents) {
    _myBox.put("LOCALSTORAGE", residents);
  }

  // load the data from the database
  void loadData() {
    List<dynamic> dynamicList = _myBox.get("LOCALSTORAGE");

    List<Resident> residentsList = [];
    for (dynamic resident in dynamicList) {
      residentsList.add(resident as Resident);
    }

    residents = residentsList;
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
      final Response response = await http.post(uri,
          headers: {"Content-Type": "application/json"}, body: body);
      print(response.reasonPhrase);
    } catch (e) {
      // TODO: treat any problema that may occur with the HTTP request
      print("deu bosta");
    }
  }
}
