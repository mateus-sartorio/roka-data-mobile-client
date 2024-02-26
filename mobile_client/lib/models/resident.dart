import 'package:hive/hive.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/collect.dart';

part 'resident.g.dart';

@HiveType(typeId: 1, adapterName: "ResidentAdapter")
class Resident extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(6)
  String name;

  @HiveField(1)
  String address;

  // DateTime birthdate;

  @HiveField(3)
  bool hasPlaque;

  @HiveField(4)
  bool isOnWhatsappGroup;

  @HiveField(5)
  bool livesInJN;

  @HiveField(8)
  String phone;

  @HiveField(9)
  String profession;

  @HiveField(10)
  String referencePoint;

  @HiveField(11)
  int registrationYear;

  @HiveField(12)
  int residentsInTheHouse;

  @HiveField(13)
  int rokaId;

  @HiveField(14)
  Situation situation;

  @HiveField(7)
  String observations;

  @HiveField(15)
  bool isNew;

  @HiveField(2)
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
      required this.isNew});
}
