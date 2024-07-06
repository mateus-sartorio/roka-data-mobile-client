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
  String description;

  @HiveField(3)
  String address;

  @HiveField(4)
  String referencePoint;

  @HiveField(5)
  bool livesInJN;

  @HiveField(6)
  String profession;

  @HiveField(7)
  DateTime birthdate;

  @HiveField(8)
  String phone;

  @HiveField(9)
  bool isOnWhatsappGroup;

  @HiveField(10)
  bool hasPlaque;

  @HiveField(11)
  int registrationYear;

  @HiveField(12)
  DateTime registrationDate;

  @HiveField(13)
  int residentsInTheHouse;

  @HiveField(14)
  int rokaId;

  @HiveField(15)
  Situation situation;

  @HiveField(16)
  String observations;

  @HiveField(17)
  bool needsCollectOnTheHouse;

  @HiveField(18)
  Shift? shiftForCollectionOnTheHouse;

  @HiveField(19)
  bool isNew;

  @HiveField(20)
  bool wasModified;

  @HiveField(21)
  bool isMarkedForRemoval;

  @HiveField(22)
  List<Collect> collects;

  @HiveField(23)
  List<Receipt> receipts;

  @HiveField(24)
  bool wasSuccessfullySentToBackendOnLastSync;

  Resident(
      {required this.id,
      required this.address,
      required this.collects,
      required this.hasPlaque,
      required this.isOnWhatsappGroup,
      required this.livesInJN,
      required this.name,
      required this.description,
      required this.observations,
      required this.phone,
      required this.profession,
      required this.referencePoint,
      required this.registrationYear,
      required this.registrationDate,
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
    description = resident.description;
    observations = resident.observations;
    phone = resident.phone;
    profession = resident.profession;
    referencePoint = resident.referencePoint;
    registrationYear = resident.registrationYear;
    registrationDate = resident.registrationDate;
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
    wasSuccessfullySentToBackendOnLastSync = resident.wasSuccessfullySentToBackendOnLastSync;
  }

  static Resident createCopy(Resident resident) {
    return Resident(
        id: resident.id,
        address: resident.address,
        collects: resident.collects,
        hasPlaque: resident.hasPlaque,
        isOnWhatsappGroup: resident.isOnWhatsappGroup,
        livesInJN: resident.livesInJN,
        name: resident.name,
        description: resident.description,
        observations: resident.observations,
        phone: resident.phone,
        profession: resident.profession,
        referencePoint: resident.referencePoint,
        registrationYear: resident.registrationYear,
        registrationDate: resident.registrationDate,
        residentsInTheHouse: resident.residentsInTheHouse,
        rokaId: resident.rokaId,
        situation: resident.situation,
        birthdate: resident.birthdate,
        isMarkedForRemoval: resident.isMarkedForRemoval,
        wasModified: resident.wasModified,
        isNew: resident.isNew,
        needsCollectOnTheHouse: resident.needsCollectOnTheHouse,
        shiftForCollectionOnTheHouse: resident.shiftForCollectionOnTheHouse,
        receipts: resident.receipts,
        wasSuccessfullySentToBackendOnLastSync: resident.wasSuccessfullySentToBackendOnLastSync);
  }
}
