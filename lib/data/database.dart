import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:mobile_client/configuration/endpoints.dart';
import 'package:mobile_client/enums/shift.dart';
import 'package:mobile_client/enums/status_codes.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/currency_handout.dart';
import 'package:mobile_client/models/receipt.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_client/utils/enum_conversion/shift.dart';
import 'package:mobile_client/utils/enum_conversion/situation.dart';
import 'package:mobile_client/utils/list_conversions.dart';
import 'package:mobile_client/utils/residents/serialize.dart';

class GlobalDatabase {
  final _myBox = Hive.box('globalDatabase');

  Future<void> createEmptyState() async {
    await _myBox.put("RESIDENTS", []);
    await _myBox.put("COLLECTS", []);
    await _myBox.put("RECEIPTS", []);
    await _myBox.put("LAST_ACTIVE_CURRENCY_HANDOUT", CurrencyHandout(id: 0, title: "", startDate: DateTime.now(), isNew: false, wasModified: false, isMarkedForRemoval: false, wasSuccessfullySentToBackendOnLastSync: false));
    await _myBox.put("CURRENCY_HANDOUTS", []);
    await _myBox.put("ALL_DATABASE_COLLECTS", []);
    await _myBox.put("ALL_DATABASE_RECEIPTS", []);
  }

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
    String backendRoute = "${Endpoints.baseUrl}/residents.json";
    Uri uri = Uri.parse(backendRoute);

    final Response response = await http.get(uri);
    List<dynamic> responseBody = jsonDecode(response.body);

    List<Resident> residents = [];
    for (dynamic residentMapObject in responseBody) {
      DateTime? birthdate = DateTime.tryParse(residentMapObject["birthdate"] ?? "");
      DateTime? registrationDate = DateTime.tryParse(residentMapObject["registration_date"] ?? "");
      DateTime? lastVisited = DateTime.tryParse(residentMapObject["last_visited"] ?? "");

      Situation situation = integerToSituation(residentMapObject["situation"]);

      Shift? shiftForCollectionOnTheHouse = (residentMapObject["shift_for_collection_on_the_house"] != null) ? getShiftFromInt(residentMapObject["shift_for_collection_on_the_house"]) : null;

      final collectsResponse = residentMapObject["collect"];
      List<Collect> collects = [];
      for (dynamic c in collectsResponse) {
        collects.add(Collect(
            ammount: double.tryParse(c["ammount"]) ?? 0,
            collectedOn: DateTime.tryParse(c["collected_on"]) ?? DateTime.now(),
            id: c["id"],
            residentId: c["resident_id"],
            isNew: false,
            wasModified: false,
            isMarkedForRemoval: false,
            wasSuccessfullySentToBackendOnLastSync: false));
      }

      collects.sort((Collect a, Collect b) => b.collectedOn.compareTo(a.collectedOn));

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
            isMarkedForRemoval: false,
            wasSuccessfullySentToBackendOnLastSync: false));
      }

      receipts.sort((Receipt a, Receipt b) => b.handoutDate.compareTo(a.handoutDate));

      Resident resident = Resident(
          id: residentMapObject["id"],
          address: residentMapObject["address"],
          collects: collects,
          hasPlaque: residentMapObject["has_plaque"],
          isOnWhatsappGroup: residentMapObject["is_on_whatsapp_group"],
          livesInJN: residentMapObject["lives_in_jn"],
          name: residentMapObject["name"],
          description: residentMapObject["description"] ?? "",
          observations: residentMapObject["observations"],
          phone: residentMapObject["phone"],
          profession: residentMapObject["profession"],
          referencePoint: residentMapObject["reference_point"],
          registrationDate: registrationDate,
          residentsInTheHouse: residentMapObject["residents_in_the_house"],
          rokaId: residentMapObject["roka_id"],
          situation: situation,
          birthdate: birthdate,
          needsCollectOnTheHouse: residentMapObject["needs_collect_on_the_house"],
          shiftForCollectionOnTheHouse: shiftForCollectionOnTheHouse,
          receipts: receipts,
          isNew: false,
          isMarkedForRemoval: false,
          wasModified: false,
          wasSuccessfullySentToBackendOnLastSync: false,
          lastVisited: lastVisited);

      residents.add(resident);
    }

    residents.sort((Resident a, Resident b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    await _myBox.put("RESIDENTS", residents);
  }

  Future<void> fetchAllCurrencyHandouts() async {
    String currencyHandoutsBackendRoute = "${Endpoints.baseUrl}/currency_handouts.json";
    Uri currencyHandoutsUri = Uri.parse(currencyHandoutsBackendRoute);

    final Response currencyHandoutsResponse = await http.get(currencyHandoutsUri);
    List<dynamic> currencyHandoutsResponseBody = jsonDecode(currencyHandoutsResponse.body);

    List<CurrencyHandout> currencyHandouts = [];
    for (dynamic currencyHandoutMapObject in currencyHandoutsResponseBody) {
      DateTime startDate = DateTime.now();
      try {
        startDate = DateTime.parse(currencyHandoutMapObject["start_date"]);
      } catch (e) {
        startDate = DateTime.now();
      }

      CurrencyHandout currencyHandout =
          CurrencyHandout(id: currencyHandoutMapObject["id"], title: currencyHandoutMapObject["title"], startDate: startDate, isNew: false, isMarkedForRemoval: false, wasModified: false, wasSuccessfullySentToBackendOnLastSync: false);

      currencyHandouts.add(currencyHandout);
    }

    currencyHandouts.sort((CurrencyHandout a, CurrencyHandout b) => b.startDate.compareTo(a.startDate));

    if (currencyHandouts.isNotEmpty) {
      await _myBox.put("LAST_ACTIVE_CURRENCY_HANDOUT", currencyHandouts[0]);
    }

    await _myBox.put("CURRENCY_HANDOUTS", currencyHandouts);
  }

  Future<void> fetchAllCollects() async {
    try {
      String backendRoute = "${Endpoints.baseUrl}/collects.json";
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
            wasModified: false,
            wasSuccessfullySentToBackendOnLastSync: false);

        collects.add(collect);
      }

      await _myBox.put("ALL_DATABASE_COLLECTS", collects);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> fetchAllReceipts() async {
    try {
      String backendRoute = "${Endpoints.baseUrl}/receipts.json";
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
            wasModified: false,
            wasSuccessfullySentToBackendOnLastSync: false);

        receipts.add(receipt);
      }

      await _myBox.put("ALL_DATABASE_RECEIPTS", receipts);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> sendDataToBackend() async {
    try {
      List<dynamic> residentsListDynamic = _myBox.get("RESIDENTS") ?? [];
      List<Resident> residentsList = dynamicListToTList(residentsListDynamic);
      for (Resident r in residentsList) {
        if (r.wasModified && !r.isNew && !r.isMarkedForRemoval && !r.wasSuccessfullySentToBackendOnLastSync) {
          await updateResidentOnBackend(r);

          r.wasSuccessfullySentToBackendOnLastSync = true;
          await updateResident(r);
        } else if (r.isNew && !r.isMarkedForRemoval) {
          await createNewResidentOnBackend(r);

          r.wasSuccessfullySentToBackendOnLastSync = true;
          await updateResident(r);
        } else if (r.isMarkedForRemoval && !r.isNew) {
          await deleteResidentOnBackend(r);

          r.wasSuccessfullySentToBackendOnLastSync = true;
          await updateResident(r);
        }
      }

      List<dynamic> collectsListDynamic = _myBox.get("COLLECTS") ?? [];
      List<Collect> collectsList = dynamicListToTList(collectsListDynamic);
      for (Collect c in collectsList) {
        if (!c.wasSuccessfullySentToBackendOnLastSync) {
          await createNewCollectOnBackend(c);

          c.wasSuccessfullySentToBackendOnLastSync = true;
          await updateCollect(c);
        }
      }

      List<dynamic> oldCollectsListDynamic = _myBox.get("ALL_DATABASE_COLLECTS") ?? [];
      List<Collect> oldCollectsList = dynamicListToTList(oldCollectsListDynamic);
      for (Collect c in oldCollectsList) {
        if (c.wasModified && !c.isNew && !c.isMarkedForRemoval && !c.wasSuccessfullySentToBackendOnLastSync) {
          await updateOldCollectOnBackend(c);

          c.wasSuccessfullySentToBackendOnLastSync = true;
          await updateOldCollect(c);
        } else if (c.isMarkedForRemoval && !c.wasSuccessfullySentToBackendOnLastSync) {
          await deleteOldCollectOnBackend(c);

          c.wasSuccessfullySentToBackendOnLastSync = true;
          await updateOldCollect(c);
        }
      }

      List<dynamic> currencyHandoutsListDynamic = _myBox.get("CURRENCY_HANDOUTS") ?? [];
      List<CurrencyHandout> currencyHandoutsList = dynamicListToTList(currencyHandoutsListDynamic);

      for (CurrencyHandout ch in currencyHandoutsList) {
        if (ch.wasModified && !ch.isNew && !ch.isMarkedForRemoval && !ch.wasSuccessfullySentToBackendOnLastSync) {
          await updateCurrencyHandoutOnBackend(ch);

          ch.wasSuccessfullySentToBackendOnLastSync = true;
          await updateCurrencyHandout(ch);
        } else if (ch.isNew && !ch.isMarkedForRemoval && !ch.wasSuccessfullySentToBackendOnLastSync) {
          await createNewCurrencyHandoutOnBackend(ch);

          ch.wasSuccessfullySentToBackendOnLastSync = true;
          await updateCurrencyHandout(ch);
        } else if (ch.isMarkedForRemoval && !ch.wasSuccessfullySentToBackendOnLastSync) {
          await deleteCurrencyHandoutOnBackend(ch);

          ch.wasSuccessfullySentToBackendOnLastSync = true;
          await updateCurrencyHandout(ch);
        }
      }

      List<dynamic> oldReceiptsListDynamic = _myBox.get("ALL_DATABASE_RECEIPTS") ?? [];
      List<Receipt> oldReceiptsList = dynamicListToTList(oldReceiptsListDynamic);
      for (Receipt r in oldReceiptsList) {
        if (r.wasModified && !r.isNew && !r.isMarkedForRemoval && !r.wasSuccessfullySentToBackendOnLastSync) {
          await updateOldReceiptOnBackend(r);

          r.wasSuccessfullySentToBackendOnLastSync = true;
          updateOldReceipt(r);
        } else if (r.isMarkedForRemoval && !r.wasSuccessfullySentToBackendOnLastSync) {
          await deleteOldReceiptOnBackend(r);

          r.wasSuccessfullySentToBackendOnLastSync = true;
          await updateOldReceipt(r);
        }
      }

      List<dynamic> receiptsListDynamic = _myBox.get("RECEIPTS") ?? [];
      List<Receipt> receiptsList = dynamicListToTList(receiptsListDynamic);
      for (Receipt r in receiptsList) {
        if (!r.wasSuccessfullySentToBackendOnLastSync) {
          await createNewReceiptOnBackend(r);

          r.wasSuccessfullySentToBackendOnLastSync = true;
          await updateReceipt(r);
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createNewCurrencyHandoutOnBackend(CurrencyHandout currencyHandout) async {
    String backendRoute = "${Endpoints.baseUrl}/currency_handouts";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": currencyHandout.id,
      "title": currencyHandout.title,
      "start_date": currencyHandout.startDate.toIso8601String(),
    };

    var body = json.encode(data);

    try {
      final Response response = await http.post(uri, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode != StatusCodes.create.value) {
        throw Exception("Erro ao criar nova distribuição de moeda: ${currencyHandout.title}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateCurrencyHandoutOnBackend(CurrencyHandout currencyHandout) async {
    String backendRoute = "${Endpoints.baseUrl}/currency_handouts/${currencyHandout.id}";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": currencyHandout.id,
      "title": currencyHandout.title,
      "start_date": currencyHandout.startDate.toIso8601String(),
    };

    var body = json.encode(data);

    try {
      final Response response = await http.put(uri, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode != StatusCodes.update.value) {
        throw Exception("Erro ao atualizar distribuição de moeda: ${currencyHandout.title}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteCurrencyHandoutOnBackend(CurrencyHandout currencyHandout) async {
    String backendRoute = "${Endpoints.baseUrl}/currency_handouts/${currencyHandout.id}";
    Uri uri = Uri.parse(backendRoute);

    try {
      final Response response = await http.delete(uri);

      if (response.statusCode != StatusCodes.delete.value) {
        throw Exception("Erro ao apagar distribuição de moeda: ${currencyHandout.title}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createNewReceiptOnBackend(Receipt receipt) async {
    String backendRoute = "${Endpoints.baseUrl}/receipts/";
    Uri uri = Uri.parse(backendRoute);

    Map data = {"id": receipt.id, "handout_date": receipt.handoutDate.toIso8601String(), "value": receipt.value, "resident_id": receipt.residentId, "currency_handout_id": receipt.currencyHandoutId};

    var body = json.encode(data);

    try {
      final Response response = await http.post(uri, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode != StatusCodes.create.value) {
        throw Exception("Erro ao criar nova entrega de moeda para morador ${getResidentById(receipt.residentId)?.name ?? "[Desconhecido]"} com valor de ${receipt.value.toStringAsFixed(2)}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createNewCollectOnBackend(Collect collect) async {
    String backendRoute = "${Endpoints.baseUrl}/collects";
    Uri uri = Uri.parse(backendRoute);

    Map data = {"id": collect.id, "collected_on": collect.collectedOn.toIso8601String(), "resident_id": collect.residentId, "ammount": collect.ammount};

    var body = json.encode(data);

    try {
      final Response response = await http.post(uri, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode != StatusCodes.create.value) {
        throw Exception("Erro ao criar nova coleta do morador ${getResidentById(collect.residentId)?.name ?? "[Desconhecido]"} com peso de ${collect.ammount.toStringAsFixed(2)} kg.");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createNewResidentOnBackend(Resident resident) async {
    String backendRoute = "${Endpoints.baseUrl}/residents";
    Uri uri = Uri.parse(backendRoute);

    Map data = residentToMap(resident);
    var body = json.encode(data);

    try {
      final Response response = await http.post(uri, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode != StatusCodes.create.value) {
        throw Exception("Erro ao criar novo residente: ${resident.name}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateResidentOnBackend(Resident resident) async {
    String backendRoute = "${Endpoints.baseUrl}/residents/${resident.id}";
    Uri uri = Uri.parse(backendRoute);

    Map data = residentToMap(resident);
    var body = json.encode(data);

    try {
      final Response response = await http.put(uri, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode != StatusCodes.update.value) {
        throw Exception("Erro atualizar dados do residente: ${resident.name}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteResidentOnBackend(Resident resident) async {
    String backendRoute = "${Endpoints.baseUrl}/residents/${resident.id}";
    Uri uri = Uri.parse(backendRoute);

    try {
      final Response response = await http.delete(uri);

      if (response.statusCode != StatusCodes.delete.value) {
        throw Exception("Erro ao apagar dados do residente: ${resident.name}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateOldReceiptOnBackend(Receipt receipt) async {
    String backendRoute = "${Endpoints.baseUrl}/collects/${receipt.id}";
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
      final Response response = await http.put(uri, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode != StatusCodes.update.value) {
        throw Exception("Erro ao atualizar dados da entrega de moeda para morador ${getResidentById(receipt.residentId)?.name ?? "[Desconhecido]"} com valor de ${receipt.value.toStringAsFixed(2)}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteOldReceiptOnBackend(Receipt receipt) async {
    String backendRoute = "${Endpoints.baseUrl}/receipts/${receipt.id}";
    Uri uri = Uri.parse(backendRoute);

    try {
      final Response response = await http.delete(uri);
      if (response.statusCode != StatusCodes.delete.value) {
        throw Exception("Erro ao apagar dados da entrega de moeda para morador ${getResidentById(receipt.residentId)?.name ?? "[Desconhecido]"} com valor de ${receipt.value.toStringAsFixed(2)}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateOldCollectOnBackend(Collect collect) async {
    String backendRoute = "${Endpoints.baseUrl}/collects/${collect.id}";
    Uri uri = Uri.parse(backendRoute);

    Map data = {
      "id": collect.id,
      "ammount": collect.ammount,
      "collected_on": collect.collectedOn.toIso8601String(),
      "resident_id": collect.residentId,
    };

    var body = json.encode(data);

    try {
      final Response response = await http.put(uri, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode != StatusCodes.update.value) {
        throw Exception("Erro ao atualizar dados da coleta do morador ${getResidentById(collect.residentId)?.name ?? "[Desconhecido]"} com peso de ${collect.ammount.toStringAsFixed(2)} kg.");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteOldCollectOnBackend(Collect collect) async {
    String backendRoute = "${Endpoints.baseUrl}/collects/${collect.id}";
    Uri uri = Uri.parse(backendRoute);

    try {
      final Response response = await http.delete(uri);

      if (response.statusCode != StatusCodes.delete.value) {
        throw Exception("Erro ao apagar dados da coleta do morador ${getResidentById(collect.residentId)?.name ?? "[Desconhecido]"} com peso de ${collect.ammount.toStringAsFixed(2)} kg.");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> saveNewResident(Resident resident) async {
    List<dynamic> residentsListDynamic = _myBox.get("RESIDENTS") ?? [];
    List<Resident> residentsList = dynamicListToTList(residentsListDynamic);

    residentsList.add(resident);

    residentsList.sort((Resident a, Resident b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    await _myBox.put("RESIDENTS", residentsList);
  }

  Future<void> updateResident(Resident resident) async {
    List<dynamic> residentsListDynamic = _myBox.get("RESIDENTS") ?? [];
    List<Resident> residentsList = dynamicListToTList(residentsListDynamic);

    resident.receipts.sort((Receipt a, Receipt b) => b.handoutDate.compareTo(a.handoutDate));

    resident.collects.sort((Collect a, Collect b) => b.collectedOn.compareTo(a.collectedOn));

    for (Resident r in residentsList) {
      if (r.id == resident.id) {
        r.deepCopy(resident);
        break;
      }
    }

    residentsList.sort((Resident a, Resident b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    await _myBox.put("RESIDENTS", residentsList);
  }

  Future<void> deleteResident(int id) async {
    List<dynamic> residentsListDynamic = _myBox.get("RESIDENTS") ?? [];
    List<Resident> residentsList = dynamicListToTList(residentsListDynamic);

    List<Resident> filteredList = residentsList.map((resident) {
      if (resident.id != id) {
        return resident;
      } else {
        Resident residentCopy = Resident.createCopy(resident);
        residentCopy.isMarkedForRemoval = true;
        return residentCopy;
      }
    }).toList();

    residentsList.sort((Resident a, Resident b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    await _myBox.put("RESIDENTS", filteredList);
  }

  Future<void> saveNewCurrencyHandout(CurrencyHandout currencyHandout) async {
    List<dynamic> currencyHandoutsList = _myBox.get("CURRENCY_HANDOUTS") ?? [];
    currencyHandoutsList.add(currencyHandout);

    currencyHandoutsList.sort((dynamic a, dynamic b) => b.startDate.compareTo(a.startDate));

    await _myBox.put("CURRENCY_HANDOUTS", currencyHandoutsList);

    for (dynamic c in currencyHandoutsList) {
      if (!c.isMarkedForRemoval) {
        await _myBox.put("LAST_ACTIVE_CURRENCY_HANDOUT", c);
        break;
      }
    }
  }

  Future<void> updateCurrencyHandout(CurrencyHandout currencyHandout) async {
    List<dynamic> currencyHandoutsListDynamic = _myBox.get("CURRENCY_HANDOUTS") ?? [];
    List<CurrencyHandout> currencyHandoutsList = dynamicListToTList(currencyHandoutsListDynamic);

    for (CurrencyHandout c in currencyHandoutsList) {
      if (c.id == currencyHandout.id) {
        c.deepCopy(currencyHandout);
        break;
      }
    }

    currencyHandoutsList.sort((CurrencyHandout a, CurrencyHandout b) => b.startDate.compareTo(a.startDate));

    await _myBox.put("CURRENCY_HANDOUTS", currencyHandoutsList);

    for (CurrencyHandout c in currencyHandoutsList) {
      if (!c.isMarkedForRemoval) {
        await _myBox.put("LAST_ACTIVE_CURRENCY_HANDOUT", c);
        break;
      }
    }
  }

  Future<void> deleteCurrencyHandout(int id) async {
    List<dynamic> currencyHandoutsListDynamic = _myBox.get("CURRENCY_HANDOUTS") ?? [];
    List<CurrencyHandout> currencyHandoutsList = dynamicListToTList(currencyHandoutsListDynamic);

    List<CurrencyHandout> filteredList = currencyHandoutsList.map((currencyHandout) {
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
            wasSuccessfullySentToBackendOnLastSync: currencyHandout.wasSuccessfullySentToBackendOnLastSync);
      }
    }).toList();

    filteredList.sort((CurrencyHandout a, CurrencyHandout b) => b.startDate.compareTo(a.startDate));

    await _myBox.put("CURRENCY_HANDOUTS", filteredList);

    if (filteredList.isNotEmpty) {
      for (CurrencyHandout c in filteredList) {
        if (!c.isMarkedForRemoval) {
          await _myBox.put("LAST_ACTIVE_CURRENCY_HANDOUT", c);
          break;
        }
      }
    }
  }

  Future<void> saveNewReceipt(Receipt receipt) async {
    List<dynamic> receiptsList = _myBox.get("RECEIPTS") ?? [];
    receiptsList.add(receipt);

    Resident resident = getResidentById(receipt.residentId)!;
    List<Receipt> residentReceipts = resident.receipts;
    residentReceipts.add(receipt);
    residentReceipts.sort((Receipt a, Receipt b) {
      var currencyHandoutA = getCurrencyHandoutById(a.currencyHandoutId);
      var currencyHandoutB = getCurrencyHandoutById(b.currencyHandoutId);

      if (currencyHandoutA == null) {
        return -1;
      } else if (currencyHandoutB == null) {
        return 1;
      }

      return currencyHandoutB.startDate.compareTo(currencyHandoutA.startDate);
    });
    resident.receipts = residentReceipts;
    await updateResident(resident);

    await _myBox.put("RECEIPTS", receiptsList);
  }

  Future<void> updateReceipt(Receipt receipt) async {
    List<dynamic> receiptsListDynamic = _myBox.get("RECEIPTS") ?? [];
    List<Receipt> receiptsList = dynamicListToTList(receiptsListDynamic);

    for (Receipt r in receiptsList) {
      if (r.id == receipt.id) {
        r.deepCopy(receipt);
        break;
      }
    }

    Resident resident = getResidentById(receipt.residentId)!;
    List<Receipt> residentReceipts = resident.receipts;
    for (Receipt r in residentReceipts) {
      if (r.id == receipt.id) {
        r.deepCopy(receipt);
      }
    }
    residentReceipts.sort((Receipt a, Receipt b) {
      var currencyHandoutA = getCurrencyHandoutById(a.currencyHandoutId);
      var currencyHandoutB = getCurrencyHandoutById(b.currencyHandoutId);

      if (currencyHandoutA == null) {
        return -1;
      } else if (currencyHandoutB == null) {
        return 1;
      }

      return currencyHandoutB.startDate.compareTo(currencyHandoutA.startDate);
    });
    resident.receipts = residentReceipts;
    await updateResident(resident);

    await _myBox.put("RECEIPTS", receiptsList);
  }

  Future<void> deleteReceipt(Receipt receipt) async {
    List<dynamic> receiptsListDynamic = _myBox.get("RECEIPTS") ?? [];
    List<Receipt> receiptsList = dynamicListToTList(receiptsListDynamic);

    List<Receipt> filteredList = receiptsList.where((r) => r.id != receipt.id).toList();

    Resident resident = getResidentById(receipt.residentId)!;
    List<Receipt> residentReceipts = resident.receipts;
    residentReceipts = residentReceipts.where((Receipt r) => r.id != receipt.id).toList();
    residentReceipts.sort((Receipt a, Receipt b) {
      var currencyHandoutA = getCurrencyHandoutById(a.currencyHandoutId);
      var currencyHandoutB = getCurrencyHandoutById(b.currencyHandoutId);

      if (currencyHandoutA == null) {
        return -1;
      } else if (currencyHandoutB == null) {
        return 1;
      }

      return currencyHandoutB.startDate.compareTo(currencyHandoutA.startDate);
    });
    resident.receipts = residentReceipts;
    await updateResident(resident);

    await _myBox.put("RECEIPTS", filteredList);
  }

  Future<void> updateOldReceipt(Receipt receipt) async {
    List<dynamic> receiptsListDyanmic = _myBox.get("ALL_DATABASE_RECEIPTS") ?? [];
    List<Receipt> receiptsList = dynamicListToTList(receiptsListDyanmic);

    for (Receipt r in receiptsList) {
      if (r.id == receipt.id) {
        r.deepCopy(receipt);
        break;
      }
    }

    Resident resident = getResidentById(receipt.residentId)!;
    List<Receipt> residentReceipts = resident.receipts;
    for (Receipt r in residentReceipts) {
      if (r.id == receipt.id) {
        r.deepCopy(receipt);
        break;
      }
    }
    residentReceipts.sort((Receipt a, Receipt b) {
      var currencyHandoutA = getCurrencyHandoutById(a.currencyHandoutId);
      var currencyHandoutB = getCurrencyHandoutById(b.currencyHandoutId);

      if (currencyHandoutA == null) {
        return -1;
      } else if (currencyHandoutB == null) {
        return 1;
      }

      return currencyHandoutB.startDate.compareTo(currencyHandoutA.startDate);
    });
    resident.receipts = residentReceipts;
    await updateResident(resident);

    await _myBox.put("ALL_DATABASE_RECEIPTS", receiptsList);
  }

  Future<void> deleteOldReceipt(Receipt receipt) async {
    List<dynamic> receiptsListDynamic = _myBox.get("ALL_DATABASE_RECEIPTS") ?? [];
    List<Receipt> receiptsList = dynamicListToTList(receiptsListDynamic);

    List<Receipt> filteredList = receiptsList.map((r) {
      if (r.id != receipt.id) {
        return r;
      } else {
        return Receipt(
            id: receipt.id,
            value: receipt.value,
            handoutDate: receipt.handoutDate,
            residentId: receipt.residentId,
            currencyHandoutId: receipt.currencyHandoutId,
            isMarkedForRemoval: true,
            wasModified: receipt.wasModified,
            isNew: receipt.isNew,
            wasSuccessfullySentToBackendOnLastSync: receipt.wasSuccessfullySentToBackendOnLastSync);
      }
    }).toList();

    Resident resident = getResidentById(receipt.residentId)!;
    List<Receipt> residentReceipts = resident.receipts;
    residentReceipts = residentReceipts.where((Receipt r) => r.id != receipt.id).toList();
    residentReceipts.sort((Receipt a, Receipt b) {
      var currencyHandoutA = getCurrencyHandoutById(a.currencyHandoutId);
      var currencyHandoutB = getCurrencyHandoutById(b.currencyHandoutId);

      if (currencyHandoutA == null) {
        return -1;
      } else if (currencyHandoutB == null) {
        return 1;
      }

      return currencyHandoutB.startDate.compareTo(currencyHandoutA.startDate);
    });
    await updateResident(resident);

    await _myBox.put("ALL_DATABASE_RECEIPTS", filteredList);
  }

  Future<void> saveNewCollect(Collect collect) async {
    List<dynamic> collectsListDynamic = _myBox.get("COLLECTS") ?? [];
    List<Collect> collectsList = dynamicListToTList(collectsListDynamic);

    collectsList.add(collect);

    try {
      Resident resident = getResidentById(collect.residentId)!;
      resident.collects.add(collect);
      updateResident(resident);
    } catch (e) {
      throw Exception("Resident does not exist!");
    }

    await _myBox.put("COLLECTS", collectsList);
  }

  Future<void> updateCollect(Collect collect) async {
    List<dynamic> collectsListDynamic = _myBox.get("COLLECTS") ?? [];
    List<Collect> collectsList = dynamicListToTList(collectsListDynamic);

    for (Collect c in collectsList) {
      if (c.id == collect.id) {
        c.deepCopy(collect);

        try {
          Resident resident = getResidentById(collect.residentId)!;
          resident.collects.add(collect);
          updateResident(resident);
        } catch (e) {
          throw Exception("Resident does not exist!");
        }

        break;
      }
    }

    await _myBox.put("COLLECTS", collectsList);
  }

  Future<void> deleteCollect(Collect collect) async {
    List<dynamic> collectsListDynamic = _myBox.get("COLLECTS") ?? [];
    List<Collect> collectsList = dynamicListToTList(collectsListDynamic);

    List<Collect> filteredList = collectsList.where((c) => c.id != collect.id).toList();

    try {
      Resident resident = getResidentById(collect.residentId)!;
      resident.collects.add(collect);
      updateResident(resident);
    } catch (e) {
      throw Exception("Resident does not exist!");
    }

    await _myBox.put("COLLECTS", filteredList);
  }

  Future<void> deleteOldCollect(Collect collect) async {
    List<dynamic> collectsListDynamic = _myBox.get("ALL_DATABASE_COLLECTS") ?? [];
    List<Collect> collectsList = dynamicListToTList(collectsListDynamic);

    List<Collect> filteredList = collectsList.map((c) {
      if (c.id != collect.id) {
        return c;
      } else {
        return Collect(
            id: c.id, ammount: c.ammount, collectedOn: c.collectedOn, residentId: c.residentId, isMarkedForRemoval: true, wasModified: c.wasModified, isNew: c.isNew, wasSuccessfullySentToBackendOnLastSync: c.wasSuccessfullySentToBackendOnLastSync);
      }
    }).toList();

    try {
      Resident resident = getResidentById(collect.residentId)!;
      resident.collects.add(collect);
      updateResident(resident);
    } catch (e) {
      throw Exception("Resident does not exist!");
    }

    await _myBox.put("ALL_DATABASE_COLLECTS", filteredList);
  }

  Future<void> updateOldCollect(Collect collect) async {
    List<dynamic> collectsListDynamic = _myBox.get("ALL_DATABASE_COLLECTS") ?? [];
    List<Collect> collectsList = dynamicListToTList(collectsListDynamic);

    for (Collect c in collectsList) {
      if (c.id == collect.id) {
        c.deepCopy(collect);
        break;
      }
    }

    try {
      Resident resident = getResidentById(collect.residentId)!;
      resident.collects.add(collect);
      updateResident(resident);
    } catch (e) {
      throw Exception("Resident does not exist!");
    }

    await _myBox.put("ALL_DATABASE_COLLECTS", collectsList);
  }

  Resident? getResidentById(int id) {
    List<dynamic> residentsDynamicList = _myBox.get("RESIDENTS") ?? [];
    List<Resident> residentsList = dynamicListToTList(residentsDynamicList);

    for (Resident resident in residentsList) {
      if (resident.id == id) {
        return resident;
      }
    }

    return null;
  }

  CurrencyHandout? getCurrencyHandoutById(int id) {
    List<dynamic> currencyHandoutsDynamicList = _myBox.get("CURRENCY_HANDOUTS") ?? [];
    List<CurrencyHandout> currencyHandoutsList = dynamicListToTList(currencyHandoutsDynamicList);

    for (CurrencyHandout currencyHandout in currencyHandoutsList) {
      if (currencyHandout.id == id) {
        return currencyHandout;
      }
    }

    return null;
  }

  (bool, String?) isRokaIdTakenByAnotherResident(int residentId, int rokaId) {
    List<dynamic> residentsListDynamic = _myBox.get("RESIDENTS") ?? [];
    List<Resident> residentsList = dynamicListToTList(residentsListDynamic);

    for (Resident resident in residentsList) {
      if (resident.rokaId == rokaId && resident.id != residentId) {
        return (true, resident.name);
      }
    }

    return (false, null);
  }
}
