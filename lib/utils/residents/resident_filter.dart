import 'package:unorm_dart/unorm_dart.dart' as unorm;

import 'package:mobile_client/enums/shift.dart';
import 'package:mobile_client/models/resident.dart';

String normalize(String input) {
  return unorm.nfd(input).replaceAll(RegExp(r'[\u0300-\u036f]'), '');
}

List<Resident> residentFilter(List<Resident> residents, String filter) {
  filter = filter.toLowerCase();

  return residents
      .where((resident) =>
          normalize(resident.name).toLowerCase().contains(filter) ||
          normalize(resident.description).toLowerCase().contains(filter) ||
          (resident.rokaId == (int.tryParse(filter) ?? -1)) ||
          (normalize(resident.address).toLowerCase().contains(filter)) ||
          (normalize(resident.observations).toLowerCase().contains(filter)) ||
          normalize(resident.referencePoint).toLowerCase().contains(filter))
      .toList();
}

List<Resident> residentFilterForPeopleThatNeedCollectOnTheHouse(List<Resident> residents, String filter) {
  filter = filter.toLowerCase();
  return residents
      .where((resident) =>
          resident.needsCollectOnTheHouse &&
          (normalize(resident.name).toLowerCase().contains(filter) ||
              normalize(resident.description).toLowerCase().contains(filter) ||
              (resident.rokaId == (int.tryParse(filter) ?? -1)) ||
              normalize(resident.address).toLowerCase().contains(filter) ||
              normalize(resident.observations).toLowerCase().contains(filter) ||
              normalize(resident.referencePoint).toLowerCase().contains(filter)))
      .toList();
}

List<Resident> residentFilterForPeopleWithShiftForCollectOnTheHouse(List<Resident> residents, Shift? shiftForCollectOnTheHouse) {
  if (shiftForCollectOnTheHouse == null) {
    return residents;
  } else {
    return residents.where((resident) => resident.shiftForCollectionOnTheHouse == shiftForCollectOnTheHouse).toList();
  }
}
