import 'package:mobile_client/models/resident.dart';

List<Resident> residentFilter(List<Resident> residents, String filter) {
  filter = filter.toLowerCase();
  return residents
      .where((resident) =>
          resident.name.toLowerCase().contains(filter) ||
          (resident.rokaId == (int.tryParse(filter) ?? -1)) ||
          (resident.address.toLowerCase().contains(filter)) ||
          (resident.observations.toLowerCase().contains(filter)) ||
          resident.referencePoint.toLowerCase().contains(filter))
      .toList();
}

List<Resident> residentFilterForPeopleThatNeedCollectOnTheHouse(
    List<Resident> residents, String filter) {
  filter = filter.toLowerCase();
  return residents
      .where((resident) =>
          resident.needsCollectOnTheHouse &&
          (resident.name.toLowerCase().contains(filter) ||
              (resident.rokaId == (int.tryParse(filter) ?? -1)) ||
              (resident.address.toLowerCase().contains(filter)) ||
              (resident.observations.toLowerCase().contains(filter)) ||
              resident.referencePoint.toLowerCase().contains(filter)))
      .toList();
}
