import 'package:hive/hive.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/collect.dart';

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
  bool isNew;

  @HiveField(16)
  bool wasModified;

  @HiveField(17)
  bool isMarkedForRemoval;

  @HiveField(18)
  List<Collect> collects;

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
      required this.isNew,
      required this.birthdate,
      required this.isMarkedForRemoval,
      required this.wasModified});
}
