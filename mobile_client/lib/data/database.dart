import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:http/http.dart' as http;

class GlobalDatabase {
  final _myBox = Hive.box('globalDatabase');

  Future<void> fetchDataFromBackend() async {
    const String backendRoute = "http://10.0.2.2:3000/residents";
    Uri uri = Uri.parse(backendRoute);

    try {
      final Response response = await http.get(uri);
      List<dynamic> responseBody = jsonDecode(response.body);

      List<Resident> residents = [];
      for (dynamic residentMapObject in responseBody) {
        DateTime birthdate = DateTime.now();
        try {
          birthdate = DateTime.parse(residentMapObject["birthdate"]);
        } catch (e) {
          birthdate = DateTime.now();
        }

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
            birthdate: birthdate,
            isNew: false,
            isMarkedForRemoval: false,
            wasModified: false);

        residents.add(resident);
      }

      // const String collectsBackendEndpoint = "http://10.0.2.2:3000/collects";
      // Uri collectsUri = Uri.parse(collectsBackendEndpoint);

      // final Response collectsResponse = await http.get(collectsUri);
      // List<dynamic> collectsResponseBody = jsonDecode(collectsResponse.body);

      // List<Collect> collects = [];
      // for (dynamic collectMapObject in collectsResponseBody) {
      //   Collect collect = Collect(
      //       id: collectMapObject["id"],
      //       ammount: double.parse(collectMapObject["ammount"]),
      //       collectedOn: DateTime.parse(collectMapObject["collected_on"]),
      //       residentId: collectMapObject["resident_id"],
      //       isNew: false);

      //   collects.add(collect);
      // }

      _myBox.put("RESIDENTS", residents);
    } catch (e) {
      // TODO: treat any problema that may occur with the HTTP request
      if (kDebugMode) {
        print("deu bosta ao salvar");
        print(e);
      }
    }
  }

  // // load the data from the database
  // void loadData() {
  //   List<dynamic> residentsDynamicList = _myBox.get("RESIDENTS");
  //   List<Resident> residentsList = [];
  //   for (dynamic resident in residentsDynamicList) {
  //     residentsList.add(resident as Resident);
  //   }

  //   List<dynamic> collectsDynamicList = _myBox.get("COLLECTS");
  //   List<Collect> collectsList = [];
  //   for (dynamic collect in collectsDynamicList) {
  //     collectsList.add(collect as Collect);
  //   }

  //   residents = residentsList;
  //   collects = collectsList;
  // }

  // Future<void> saveNewCollect(Collect collect) async {
  //   const String backendRoute = "http://10.0.2.2:3000/collects";
  //   Uri uri = Uri.parse(backendRoute);

  //   Map data = {
  //     "collected_on": collect.collectedOn.toIso8601String(),
  //     "resident_id": collect.residentId,
  //     "ammount": collect.ammount
  //   };

  //   var body = json.encode(data);

  //   try {
  //     await http.post(uri,
  //         headers: {"Content-Type": "application/json"}, body: body);
  //   } catch (e) {
  //     // TODO: treat any problema that may occur with the HTTP request
  //     if (kDebugMode) {
  //       print("deu bosta");
  //     }
  //   }
  // }

  //   Future<void> updateCollect(Collect collect) async {
  //   const String backendRoute = "http://10.0.2.2:3000/collects";
  //   Uri uri = Uri.parse(backendRoute);

  //   Map data = {
  //     "collected_on": collect.collectedOn.toIso8601String(),
  //     "resident_id": collect.residentId,
  //     "ammount": collect.ammount
  //   };

  //   var body = json.encode(data);

  //   try {
  //     await http.post(uri,
  //         headers: {"Content-Type": "application/json"}, body: body);
  //   } catch (e) {
  //     // TODO: treat any problema that may occur with the HTTP request
  //     if (kDebugMode) {
  //       print("deu bosta");
  //     }
  //   }
  // }

  void saveNewResident(Resident resident) {
    List<dynamic> residentsList = _myBox.get("RESIDENTS") ?? [];
    residentsList.add(resident);
    _myBox.put("RESIDENTS", residentsList);
  }

  void updateResident(Resident resident) {
    List<dynamic> residentsList = _myBox.get("RESIDENTS") ?? [];

    for (dynamic r in residentsList) {
      if (r.name == resident.name) {
        r.address = resident.address;
        r.collects = resident.collects;
        r.hasPlaque = resident.hasPlaque;
        r.isOnWhatsappGroup = resident.isOnWhatsappGroup;
        r.livesInJN = resident.livesInJN;
        r.name = resident.name;
        r.observations = resident.observations;
        r.phone = resident.phone;
        r.profession = resident.profession;
        r.referencePoint = resident.referencePoint;
        r.registrationYear = resident.registrationYear;
        r.residentsInTheHouse = resident.residentsInTheHouse;
        r.rokaId = resident.rokaId;
        r.situation = resident.situation;
        r.birthdate = resident.birthdate;
        r.isMarkedForRemoval = resident.isMarkedForRemoval;
        r.wasModified = true;
        r.isNew = resident.isNew;

        break;
      }
    }

    _myBox.put("RESIDENTS", residentsList);
  }

  void deleteResident(int id) {
    List<dynamic> residentsList = _myBox.get("RESIDENTS") ?? [];

    List<dynamic> filteredList = residentsList.map((resident) {
      if (resident.id != id) {
        return resident;
      } else {
        return Resident(
          id: id,
          address: resident.address,
          collects: resident.collects,
          hasPlaque: resident.hasPlaque,
          isOnWhatsappGroup: resident.isOnWhatsappGroup,
          livesInJN: resident.livesInJN,
          name: resident.name,
          observations: resident.observations,
          phone: resident.phone,
          profession: resident.profession,
          referencePoint: resident.referencePoint,
          registrationYear: resident.registrationYear,
          residentsInTheHouse: resident.residentsInTheHouse,
          rokaId: resident.rokaId,
          situation: resident.situation,
          birthdate: resident.birthdate,
          isMarkedForRemoval: true,
          wasModified: false,
          isNew: true,
        );
      }
    }).toList();

    _myBox.put("RESIDENTS", filteredList);
  }

  void saveNewCollect(Collect collect) {
    List<dynamic> collectsList = _myBox.get("COLLECTS") ?? [];
    collectsList.add(collect);
    _myBox.put("COLLECTS", collectsList);
  }

  void updateCollect(Collect collect) {
    List<dynamic> collectsList = _myBox.get("COLLECTS") ?? [];

    for (dynamic c in collectsList) {
      if (c.residentId == collect.residentId) {
        c.collectedOn = collect.collectedOn;
        c.residentId = collect.residentId;
        c.ammount = collect.ammount;
        break;
      }
    }

    _myBox.put("COLLECTS", collectsList);
  }

  void deleteCollect(int residentId) {
    List<dynamic> collectsList = _myBox.get("COLLECTS") ?? [];

    List<dynamic> filteredList = collectsList
        .where((collect) => collect.residentId != residentId)
        .toList();

    _myBox.put("COLLECTS", filteredList);
  }

  Resident? getResidentById(int id) {
    List<dynamic> residentsDynamicList = _myBox.get("RESIDENTS");
    List<Resident> residentsList = [];
    for (dynamic resident in residentsDynamicList) {
      residentsList.add(resident as Resident);
    }

    for (Resident resident in residentsList) {
      if (resident.id == id) {
        return resident;
      }
    }

    return null;
  }
}
