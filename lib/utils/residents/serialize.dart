import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/utils/enum_conversion/situation.dart';

Map residentToMap(Resident resident) {
  int situation = situationToInteger(resident.situation);

  return {"id": resident.id, "name": resident.name, "roka_id": resident.rokaId, "situation": situation, "has_plaque": resident.hasPlaque, "registration_year": resident.registrationYear, "registration_date": resident.registrationDate.toString(), "address": resident.address, "reference_point": resident.referencePoint, "lives_in_jn": resident.livesInJN, "phone": resident.phone, "is_on_whatsapp_group": resident.isOnWhatsappGroup, "birthdate": resident.birthdate.toString(), "profession": resident.profession, "residents_in_the_house": resident.residentsInTheHouse, "observations": resident.observations, "needs_collect_on_the_house": resident.needsCollectOnTheHouse, "shift_for_collection_on_the_house": resident.shiftForCollectionOnTheHouse?.value};
}
