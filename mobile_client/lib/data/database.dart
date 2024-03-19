import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/currency_handout.dart';
import 'package:mobile_client/models/receipt.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:http/http.dart' as http;

class GlobalDatabase {
  final _myBox = Hive.box('globalDatabase');

  Future<void> fetchDataFromBackend() async {
    try {
      const String backendRoute = "http://10.0.2.2:3000/residents";
      Uri uri = Uri.parse(backendRoute);

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

        Situation situation = Situation.active;
        int receivedSituation = residentMapObject["situation"];
        if (receivedSituation == 0) {
          situation = Situation.active;
        } else if (receivedSituation == 1) {
          situation = Situation.inactive;
        } else {
          situation = Situation.noContact;
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
            situation: situation,
            birthdate: birthdate,
            isNew: false,
            isMarkedForRemoval: false,
            wasModified: false);

        residents.add(resident);
      }

      const String currencyHandoutsBackendRoute =
          "http://10.0.2.2:3000/currency_handouts.json";
      Uri currencyHandoutsUri = Uri.parse(currencyHandoutsBackendRoute);

      final Response currencyHandoutsResponse =
          await http.get(currencyHandoutsUri);
      List<dynamic> currencyHandoutsResponseBody =
          jsonDecode(currencyHandoutsResponse.body);

      List<CurrencyHandout> currencyHandouts = [];
      for (dynamic currencyHandoutMapObject in currencyHandoutsResponseBody) {
        DateTime startDate = DateTime.now();
        try {
          startDate = DateTime.parse(currencyHandoutMapObject["start_date"]);
        } catch (e) {
          startDate = DateTime.now();
        }

        CurrencyHandout currencyHandout = CurrencyHandout(
            id: currencyHandoutMapObject["id"],
            title: currencyHandoutMapObject["title"],
            startDate: startDate,
            isNew: false,
            isMarkedForRemoval: false,
            wasModified: false);

        currencyHandouts.add(currencyHandout);
      }

      await _myBox.put("RESIDENTS", residents);
      await _myBox.put("CURRENCY_HANDOUTS", currencyHandouts);
      await _myBox.put("COLLECTS", []);
      await _myBox.put("RECEIPTS", []);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> syncDataWithBackend() async {
    try {
      List<dynamic> residentsList = _myBox.get("RESIDENTS") ?? [];
      for (dynamic r in residentsList) {
        if (r.wasModified && !r.isNew && !r.isMarkedForRemoval) {
          updateResidentOnBackend(r as Resident);
        } else if (r.isNew && !r.isMarkedForRemoval) {
          createNewResidentOnBackend(r as Resident);
        } else if (r.isMarkedForRemoval) {
          deleteResidentInTheBackend(r as Resident);
        }
      }

      List<dynamic> collectsList = _myBox.get("COLLECTS") ?? [];
      for (dynamic c in collectsList) {
        createNewCollectOnBackend(c as Collect);
      }

      List<dynamic> currencyHandoutsList =
          _myBox.get("CURRENCY_HANDOUTS") ?? [];

      for (dynamic ch in currencyHandoutsList) {
        if (ch.wasModified && !ch.isNew && !ch.isMarkedForRemoval) {
          updateCurrencyHandoutOnBackend(ch as CurrencyHandout);
        } else if (ch.isNew && !ch.isMarkedForRemoval) {
          createNewCurrencyHandoutOnBackend(ch as CurrencyHandout);
        } else if (ch.isMarkedForRemoval) {
          deleteCurrencyHandoutInTheBackend(ch as CurrencyHandout);
        }
      }

      List<dynamic> receiptsList = _myBox.get("RECEIPTS") ?? [];
      for (dynamic r in receiptsList) {
        createNewReceiptOnBackend(r as Receipt);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createNewCurrencyHandoutOnBackend(
      CurrencyHandout currencyHandout) async {
    const String backendRoute = "http://10.0.2.2:3000/currency_handouts";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": currencyHandout.id,
      "title": currencyHandout.title,
      "start_date": currencyHandout.startDate.toIso8601String(),
    };

    var body = json.encode(data);

    try {
      await http.post(uri,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateCurrencyHandoutOnBackend(
      CurrencyHandout currencyHandout) async {
    String backendRoute =
        "http://10.0.2.2:3000/currency_handouts/${currencyHandout.id}";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": currencyHandout.id,
      "title": currencyHandout.title,
      "start_date": currencyHandout.startDate.toIso8601String(),
    };

    var body = json.encode(data);

    try {
      await http.put(uri,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteCurrencyHandoutInTheBackend(
      CurrencyHandout currencyHandout) async {
    String backendRoute =
        "http://10.0.2.2:3000/currency_handouts/${currencyHandout.id}";
    Uri uri = Uri.parse(backendRoute);

    try {
      await http.delete(uri);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createNewReceiptOnBackend(Receipt receipt) async {
    const String backendRoute = "http://10.0.2.2:3000/receipts/";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": receipt.id,
      "handout_date": receipt.handoutDate.toIso8601String(),
      "value": receipt.value,
      "resident_id": receipt.residentId,
      "currency_handout_id": receipt.currencyHandoutId
    };

    var body = json.encode(data);

    try {
      await http.post(uri,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createNewCollectOnBackend(Collect collect) async {
    const String backendRoute = "http://10.0.2.2:3000/collects";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": collect.id,
      "collected_on": collect.collectedOn.toIso8601String(),
      "resident_id": collect.residentId,
      "ammount": collect.ammount
    };

    var body = json.encode(data);

    try {
      await http.post(uri,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createNewResidentOnBackend(Resident resident) async {
    const String backendRoute = "http://10.0.2.2:3000/residents";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": resident.id,
      "name": resident.name,
      "roka_id": resident.rokaId,
      "has_plaque": resident.hasPlaque,
      "registration_year": resident.registrationYear,
      "address": resident.address,
      "reference_point": resident.referencePoint,
      "lives_in_JN": resident.livesInJN,
      "phone": resident.phone,
      "is_on_whatsapp_group": resident.isOnWhatsappGroup,
      "birthdate": resident.birthdate.toString(),
      "profession": resident.profession,
      "residents_in_the_house": resident.residentsInTheHouse,
      "observations": resident.observations,
      "situation": "ativo"
    };

    var body = json.encode(data);

    try {
      await http.post(uri,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateResidentOnBackend(Resident resident) async {
    String backendRoute = "http://10.0.2.2:3000/residents/${resident.id}";
    Uri uri = Uri.parse(backendRoute);

    int situation = 0;
    if (resident.situation == Situation.active) {
      situation = 0;
    } else if (resident.situation == Situation.inactive) {
      situation = 1;
    } else if (resident.situation == Situation.noContact) {
      situation = 2;
    }

    Map data = {
      "id": resident.id,
      "name": resident.name,
      "roka_id": resident.rokaId,
      "situation": situation,
      "has_plaque": resident.hasPlaque,
      "registration_year": resident.registrationYear,
      "address": resident.address,
      "reference_point": resident.referencePoint,
      "lives_in_JN": resident.livesInJN,
      "phone": resident.phone,
      "is_on_whatsapp_group": resident.isOnWhatsappGroup,
      "birthdate": resident.birthdate.toString(),
      "profession": resident.profession,
      "residents_in_the_house": resident.residentsInTheHouse,
      "observations": resident.observations
    };

    var body = json.encode(data);

    try {
      await http.put(uri,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteResidentInTheBackend(Resident resident) async {
    String backendRoute = "http://10.0.2.2:3000/residents/${resident.id}";
    Uri uri = Uri.parse(backendRoute);

    try {
      await http.delete(uri);
    } catch (e) {
      throw Exception(e);
    }
  }

  void saveNewResident(Resident resident) {
    List<dynamic> residentsList = _myBox.get("RESIDENTS") ?? [];
    residentsList.add(resident);
    _myBox.put("RESIDENTS", residentsList);
  }

  void updateResident(Resident resident) {
    List<dynamic> residentsList = _myBox.get("RESIDENTS") ?? [];

    for (dynamic r in residentsList) {
      if (r.id == resident.id) {
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
        r.wasModified = resident.wasModified;
        r.isNew = resident.isNew;
        break;
      }
    }

    _myBox.put("RESIDENTS", residentsList);
  }

  void deleteResident(int id, bool forReal) {
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
          situation: forReal ? resident.situation : Situation.inactive,
          birthdate: resident.birthdate,
          isMarkedForRemoval: forReal ? true : false,
          wasModified: true,
          isNew: resident.isNew,
        );
      }
    }).toList();

    _myBox.put("RESIDENTS", filteredList);
  }

  void saveNewCurrencyHandout(CurrencyHandout currencyHandout) {
    List<dynamic> currencyHandoutsList = _myBox.get("CURRENCY_HANDOUTS") ?? [];
    currencyHandoutsList.add(currencyHandout);
    _myBox.put("CURRENCY_HANDOUTS", currencyHandoutsList);
  }

  void updateCurrencyHandout(CurrencyHandout currencyHandout) {
    List<dynamic> currencyHandoutsList = _myBox.get("CURRENCY_HANDOUTS") ?? [];

    for (dynamic c in currencyHandoutsList) {
      if (c.id == currencyHandout.id) {
        c.title = currencyHandout.title;
        c.startDate = currencyHandout.startDate;
        c.isNew = currencyHandout.isNew;
        c.isMarkedForRemoval = currencyHandout.isMarkedForRemoval;
        c.wasModified = currencyHandout.wasModified;
        break;
      }
    }

    _myBox.put("CURRENCY_HANDOUTS", currencyHandoutsList);
  }

  void deleteCurrencyHandout(int id) {
    List<dynamic> currencyHandoutsList = _myBox.get("CURRENCY_HANDOUTS") ?? [];

    List<dynamic> filteredList = currencyHandoutsList.map((currencyHandout) {
      if (currencyHandout.id != id) {
        return currencyHandout;
      } else {
        return CurrencyHandout(
          id: id,
          title: currencyHandout.title,
          startDate: currencyHandout.startDate,
          isNew: currencyHandout.isNew,
          wasModified: currencyHandout.wasModified,
          isMarkedForRemoval: true,
        );
      }
    }).toList();

    _myBox.put("CURRENCY_HANDOUTS", filteredList);
  }

  void saveNewReceipt(Receipt receipt) {
    List<dynamic> receiptsList = _myBox.get("RECEIPTS") ?? [];
    receiptsList.add(receipt);
    _myBox.put("RECEIPTS", receiptsList);
  }

  void updateReceipt(Receipt receipt) {
    List<dynamic> receiptsList = _myBox.get("RECEIPTS") ?? [];

    for (dynamic r in receiptsList) {
      if (r.id == receipt.id) {
        r.handoutDate = receipt.handoutDate;
        r.residentId = receipt.residentId;
        r.currencyHandoutId = receipt.currencyHandoutId;
        r.value = receipt.value;

        break;
      }
    }

    _myBox.put("RECEIPTS", receiptsList);
  }

  void deleteReceipt(int receiptId) {
    List<dynamic> receiptsList = _myBox.get("RECEIPTS") ?? [];

    List<dynamic> filteredList =
        receiptsList.where((receipt) => receipt.id != receiptId).toList();

    _myBox.put("RECEIPTS", filteredList);
  }

  void saveNewCollect(Collect collect) {
    List<dynamic> collectsList = _myBox.get("COLLECTS") ?? [];
    collectsList.add(collect);
    _myBox.put("COLLECTS", collectsList);
  }

  void updateCollect(Collect collect) {
    List<dynamic> collectsList = _myBox.get("COLLECTS") ?? [];

    for (dynamic c in collectsList) {
      if (c.id == collect.id) {
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

  CurrencyHandout? getCurrencyHandoutById(int id) {
    List<dynamic> currencyHandoutsDynamicList = _myBox.get("CURRENCY_HANDOUTS");
    List<CurrencyHandout> currencyHandoutsList = [];
    for (dynamic currencyHandout in currencyHandoutsDynamicList) {
      currencyHandoutsList.add(currencyHandout as CurrencyHandout);
    }

    for (CurrencyHandout currencyHandout in currencyHandoutsList) {
      if (currencyHandout.id == id) {
        return currencyHandout;
      }
    }

    return null;
  }
}
