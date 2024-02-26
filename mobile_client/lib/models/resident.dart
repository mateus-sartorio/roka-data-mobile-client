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

  // DateTime birthdate;

  @HiveField(6)
  String phone;

  @HiveField(7)
  bool isOnWhatsappGroup;

  @HiveField(8)
  bool hasPlaque;

  @HiveField(9)
  int registrationYear;

  @HiveField(10)
  int residentsInTheHouse;

  @HiveField(11)
  int rokaId;

  @HiveField(12)
  Situation situation;

  @HiveField(13)
  String observations;

  @HiveField(14)
  bool isNew;

  @HiveField(15)
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
