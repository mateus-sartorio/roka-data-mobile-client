import 'package:mobile_client/models/collect.dart';

Map<DateTime, double> totalWeightByDate(List<Collect> collects) {
  Map<DateTime, double> totalWeightByCollectedOnDate = <DateTime, double>{};

  for (int i = 0; i < collects.length; i++) {
    if (totalWeightByCollectedOnDate.containsKey(collects[i].collectedOn)) {
      double currentSum =
          totalWeightByCollectedOnDate[collects[i].collectedOn]!;
      double newSum = collects[i].ammount + currentSum;
      totalWeightByCollectedOnDate[collects[i].collectedOn] = newSum;
    } else {
      totalWeightByCollectedOnDate[collects[i].collectedOn] =
          collects[i].ammount;
    }
  }

  return totalWeightByCollectedOnDate;
}

double totalWeight(List<Collect> collects) {
  double total = 0;
  for (Collect c in collects) {
    total += c.ammount;
  }

  return total;
}
