import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/collect.dart';

class Resident {
  int id;
  String address;
  // DateTime birthdate;
  List<Collect> collects;
  // DateTime createdAt;
  bool hasPlaque;
  bool isOnWhatsappGroup;
  bool livesInJN;
  String name;
  String observations;
  String phone;
  String profession;
  String referencePoint;
  int registrationYear;
  int residentsInTheHouse;
  int rokaId;
  Situation situation;
  // DateTime updatedAt;
  bool isNew;

  Resident(
      {required this.id,
      required this.address,
      // required this.birthdate,
      required this.collects,
      // required this.createdAt,
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
      // required this.updatedAt,
      required this.isNew});
}
