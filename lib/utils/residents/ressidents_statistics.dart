import 'package:mobile_client/models/resident.dart';

int totalLivesImpacted(List<Resident> residents) {
  int total = 0;

  for (Resident r in residents) {
    if (r.residentsInTheHouse == 0) {
      total++;
    } else {
      total += r.residentsInTheHouse;
    }
  }

  return total;
}
