import 'package:hive/hive.dart';
import 'package:mobile_client/enums/shift.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/receipt.dart';

part 'resident.g.dart';

@HiveType(typeId: 1, adapterName: "ResidentAdapter")
class Resident extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String address;

  @HiveField(3)
  String referencePoint;

  @HiveField(4)
  bool livesInJN;

  @HiveField(5)
  String profession;

  @HiveField(6)
  DateTime birthdate;

  @HiveField(7)
  String phone;

  @HiveField(8)
  bool isOnWhatsappGroup;

  @HiveField(9)
  bool hasPlaque;

  @HiveField(10)
  int registrationYear;

  @HiveField(11)
  int residentsInTheHouse;

  @HiveField(12)
  int rokaId;

  @HiveField(13)
  Situation situation;

  @HiveField(14)
  String observations;

  @HiveField(15)
  bool needsCollectOnTheHouse;

  @HiveField(16)
  Shift? shiftForCollectionOnTheHouse;

  @HiveField(17)
  bool isNew;

  @HiveField(18)
  bool wasModified;

  @HiveField(19)
  bool isMarkedForRemoval;

  @HiveField(20)
  List<Collect> collects;

  @HiveField(21)
  List<Receipt> receipts;

  @HiveField(22)
  bool wasSuccessfullySentToBackendOnLastSync;

  Resident(
      {required this.id,
      required this.address,
      required this.collects,
      required this.hasPlaque,
      required this.isOnWhatsappGroup,
      required this.livesInJN,
      required this.name,
      required this.observations,
      required this.phone,
      required this.profession,
      required this.referencePoint,
      required this.registrationYear,
      required this.residentsInTheHouse,
      required this.rokaId,
      required this.situation,
      required this.needsCollectOnTheHouse,
      required this.shiftForCollectionOnTheHouse,
      required this.isNew,
      required this.birthdate,
      required this.isMarkedForRemoval,
      required this.wasModified,
      required this.receipts,
      required this.wasSuccessfullySentToBackendOnLastSync});

  // Copies resident to this resident instance
  void deepCopy(Resident resident) {
    address = resident.address;
    collects = resident.collects;
    hasPlaque = resident.hasPlaque;
    isOnWhatsappGroup = resident.isOnWhatsappGroup;
    livesInJN = resident.livesInJN;
    name = resident.name;
    observations = resident.observations;
    phone = resident.phone;
    profession = resident.profession;
    referencePoint = resident.referencePoint;
    registrationYear = resident.registrationYear;
    residentsInTheHouse = resident.residentsInTheHouse;
    rokaId = resident.rokaId;
    situation = resident.situation;
    birthdate = resident.birthdate;
    isMarkedForRemoval = resident.isMarkedForRemoval;
    wasModified = resident.wasModified;
    isNew = resident.isNew;
    needsCollectOnTheHouse = resident.needsCollectOnTheHouse;
    shiftForCollectionOnTheHouse = resident.shiftForCollectionOnTheHouse;
    receipts = resident.receipts;
    collects = resident.collects;
    wasSuccessfullySentToBackendOnLastSync =
        resident.wasSuccessfullySentToBackendOnLastSync;
  }
}
