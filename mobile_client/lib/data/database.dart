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
      await fetchAllResidents();
      await fetchAllCurrencyHandouts();
      await fetchAllCollects();
      await fetchAllReceipts();
      await _myBox.put("COLLECTS", []);
      await _myBox.put("RECEIPTS", []);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> fetchAllResidents() async {
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

      final receiptsResponse = residentMapObject["receipts"];
      List<Receipt> receipts = [];
      for (dynamic r in receiptsResponse) {
        receipts.add(Receipt(
            id: r["id"],
            value: double.tryParse(r["value"]) ?? 0,
            handoutDate: DateTime.tryParse(r["handout_date"]) ?? DateTime.now(),
            residentId: r["resident_id"],
            currencyHandoutId: r["currency_handout_id"],
            isNew: false,
            wasModified: false,
            isMarkedForRemoval: false));
      }

      receipts.sort(
          (Receipt a, Receipt b) => b.handoutDate.compareTo(a.handoutDate));

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
          needsCollectOnTheHouse:
              residentMapObject["needs_collect_on_the_house"],
          receipts: receipts,
          isNew: false,
          isMarkedForRemoval: false,
          wasModified: false);

      residents.add(resident);
    }

    residents.sort((Resident a, Resident b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    await _myBox.put("RESIDENTS", residents);
  }

  Future<void> fetchAllCurrencyHandouts() async {
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

    currencyHandouts.sort((CurrencyHandout a, CurrencyHandout b) =>
        b.startDate.compareTo(a.startDate));

    if (currencyHandouts.isNotEmpty) {
      await _myBox.put("LAST_CURRENCY_HANDOUT", currencyHandouts[0]);
    }

    await _myBox.put("CURRENCY_HANDOUTS", currencyHandouts);
  }

  Future<void> fetchAllCollects() async {
    try {
      const String backendRoute = "http://10.0.2.2:3000/collects";
      Uri uri = Uri.parse(backendRoute);

      final Response response = await http.get(uri);
      List<dynamic> responseBody = jsonDecode(response.body);

      List<Collect> collects = [];
      for (dynamic collectsMapObject in responseBody) {
        Collect collect = Collect(
            id: collectsMapObject["id"],
            ammount: double.tryParse(collectsMapObject["ammount"]) ?? 0.0,
            collectedOn: DateTime.parse(collectsMapObject["collected_on"]),
            residentId: collectsMapObject["resident_id"],
            isNew: false,
            isMarkedForRemoval: false,
            wasModified: false);

        collects.add(collect);
      }

      await _myBox.put("ALL_DATABASE_COLLECTS", collects);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> fetchAllReceipts() async {
    try {
      const String backendRoute = "http://10.0.2.2:3000/receipts.json";
      Uri uri = Uri.parse(backendRoute);

      final Response response = await http.get(uri);
      List<dynamic> responseBody = jsonDecode(response.body);

      List<Receipt> receipts = [];
      for (dynamic receiptsMapObject in responseBody) {
        Receipt receipt = Receipt(
            id: receiptsMapObject["id"],
            handoutDate: DateTime.parse(receiptsMapObject["handout_date"]),
            value: double.tryParse(receiptsMapObject["value"]) ?? 0.0,
            residentId: receiptsMapObject["resident_id"],
            currencyHandoutId: receiptsMapObject["currency_handout_id"],
            isNew: false,
            isMarkedForRemoval: false,
            wasModified: false);

        receipts.add(receipt);
      }

      await _myBox.put("ALL_DATABASE_RECEIPTS", receipts);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> sendDataToBackend() async {
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

      List<dynamic> oldCollectsList = _myBox.get("ALL_DATABASE_COLLECTS") ?? [];
      for (dynamic c in oldCollectsList) {
        if (c.wasModified && !c.isNew && !c.isMarkedForRemoval) {
          updateOldCollectOnBackend(c as Collect);
        } else if (c.isMarkedForRemoval) {
          deleteOldCollectOnBackend(c as Collect);
        }
      }

      List<dynamic> oldReceiptsList = _myBox.get("ALL_DATABASE_RECEIPTS") ?? [];
      for (dynamic r in oldReceiptsList) {
        if (r.wasModified && !r.isNew && !r.isMarkedForRemoval) {
          updateOldReceiptOnBackend(r as Receipt);
        } else if (r.isMarkedForRemoval) {
          deleteOldReceiptOnBackend(r as Receipt);
        }
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
      "situation": situation,
      "needs_collect_on_the_house": resident.needsCollectOnTheHouse
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
      "observations": resident.observations,
      "needs_collect_on_the_house": resident.needsCollectOnTheHouse
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

    residentsList.sort((dynamic a, dynamic b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    _myBox.put("RESIDENTS", residentsList);
  }

  void updateResident(Resident resident) {
    List<dynamic> residentsList = _myBox.get("RESIDENTS") ?? [];

    resident.receipts
        .sort((Receipt a, Receipt b) => b.handoutDate.compareTo(a.handoutDate));

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
        r.needsCollectOnTheHouse = resident.needsCollectOnTheHouse;
        break;
      }
    }

    residentsList.sort((dynamic a, dynamic b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()));

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
            receipts: resident.receipts,
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
            wasModified: true,
            isNew: resident.isNew,
            needsCollectOnTheHouse: resident.needsCollectOnTheHouse);
      }
    }).toList();

    residentsList.sort((dynamic a, dynamic b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()));

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

    Resident resident = getResidentById(receipt.residentId)!;
    resident.receipts.add(receipt);
    updateResident(resident);

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

  void updateOldReceipt(Receipt receipt) {
    List<dynamic> receiptsList = _myBox.get("ALL_DATABASE_RECEIPTS") ?? [];

    for (dynamic r in receiptsList) {
      if (r.id == receipt.id) {
        r.handoutDate = receipt.handoutDate;
        r.value = receipt.value;
        r.residentId = receipt.residentId;
        r.currencyHandoutId = receipt.currencyHandoutId;
        r.isNew = receipt.isNew;
        r.wasModified = receipt.wasModified;
        r.isMarkedForRemoval = receipt.isMarkedForRemoval;
        break;
      }
    }

    _myBox.put("ALL_DATABASE_RECEIPTS", receiptsList);
  }

  void deleteOldReceipt(int receiptId) {
    List<dynamic> collectsList = _myBox.get("ALL_DATABASE_RECEIPTS") ?? [];

    List<dynamic> filteredList = collectsList.map((receipt) {
      if (receipt.id != receiptId) {
        return receipt;
      } else {
        return Receipt(
          id: receiptId,
          value: receipt.value,
          handoutDate: receipt.handoutDate,
          residentId: receipt.residentId,
          currencyHandoutId: receipt.currencyHandoutId,
          isMarkedForRemoval: true,
          wasModified: receipt.wasModified,
          isNew: receipt.isNew,
        );
      }
    }).toList();

    _myBox.put("ALL_DATABASE_RECEIPTS", filteredList);
  }

  Future<void> updateOldReceiptOnBackend(Receipt receipt) async {
    String backendRoute = "http://10.0.2.2:3000/collects/${receipt.id}";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": receipt.id,
      "value": receipt.value,
      "handout_date": receipt.handoutDate.toIso8601String(),
      "resident_id": receipt.residentId,
      "currency_handout_id": receipt.currencyHandoutId,
    };

    var body = json.encode(data);

    try {
      await http.put(uri,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteOldReceiptOnBackend(Receipt receipt) async {
    String backendRoute = "http://10.0.2.2:3000/receipts/${receipt.id}";
    Uri uri = Uri.parse(backendRoute);

    try {
      await http.delete(uri);
    } catch (e) {
      throw Exception(e);
    }
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
        c.isNew = collect.isNew;
        c.wasModified = collect.wasModified;
        c.isMarkedForRemoval = collect.isMarkedForRemoval;
        break;
      }
    }

    _myBox.put("COLLECTS", collectsList);
  }

  void deleteCollect(int collectId) {
    List<dynamic> collectsList = _myBox.get("COLLECTS") ?? [];

    List<dynamic> filteredList =
        collectsList.where((collect) => collect.id != collectId).toList();

    _myBox.put("COLLECTS", filteredList);
  }

  void deleteOldCollect(int collectId) {
    List<dynamic> collectsList = _myBox.get("ALL_DATABASE_COLLECTS") ?? [];

    List<dynamic> filteredList = collectsList.map((collect) {
      if (collect.id != collectId) {
        return collect;
      } else {
        return Collect(
          id: collectId,
          ammount: collect.ammount,
          collectedOn: collect.collectedOn,
          residentId: collect.residentId,
          isMarkedForRemoval: true,
          wasModified: collect.wasModified,
          isNew: collect.isNew,
        );
      }
    }).toList();

    _myBox.put("ALL_DATABASE_COLLECTS", filteredList);
  }

  void updateOldCollect(Collect collect) {
    List<dynamic> collectsList = _myBox.get("ALL_DATABASE_COLLECTS") ?? [];

    for (dynamic c in collectsList) {
      if (c.id == collect.id) {
        c.collectedOn = collect.collectedOn;
        c.residentId = collect.residentId;
        c.ammount = collect.ammount;
        c.isNew = collect.isNew;
        c.wasModified = collect.wasModified;
        c.isMarkedForRemoval = collect.isMarkedForRemoval;
        break;
      }
    }

    _myBox.put("ALL_DATABASE_COLLECTS", collectsList);
  }

  Future<void> updateOldCollectOnBackend(Collect collect) async {
    String backendRoute = "http://10.0.2.2:3000/collects/${collect.id}";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": collect.id,
      "ammount": collect.ammount,
      "collected_on": collect.collectedOn.toIso8601String(),
      "resident_id": collect.residentId,
    };

    var body = json.encode(data);

    try {
      await http.put(uri,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteOldCollectOnBackend(Collect collect) async {
    String backendRoute = "http://10.0.2.2:3000/collects/${collect.id}";
    Uri uri = Uri.parse(backendRoute);

    try {
      await http.delete(uri);
    } catch (e) {
      throw Exception(e);
    }
  }

  Resident? getResidentById(int id) {
    List<dynamic> residentsDynamicList = _myBox.get("RESIDENTS") ?? [];
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
    List<dynamic> currencyHandoutsDynamicList =
        _myBox.get("CURRENCY_HANDOUTS") ?? [];
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
