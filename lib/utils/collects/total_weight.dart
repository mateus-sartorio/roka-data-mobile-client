import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/utils/dates/to_date_string.dart';

Map<String, double> totalWeightByDate(List<Collect> collects) {
  Map<String, double> totalWeightByCollectedOnDate = <String, double>{};

  for (int i = 0; i < collects.length; i++) {
    if (totalWeightByCollectedOnDate
        .containsKey(toDateString(collects[i].collectedOn))) {
      double currentSum =
          totalWeightByCollectedOnDate[toDateString(collects[i].collectedOn)]!;
      double newSum = collects[i].ammount + currentSum;
      totalWeightByCollectedOnDate[toDateString(collects[i].collectedOn)] =
          newSum;
    } else {
      totalWeightByCollectedOnDate[toDateString(collects[i].collectedOn)] =
          collects[i].ammount;
    }
  }

  return totalWeightByCollectedOnDate;
}

Map<String, double> totalWeightByMonth(List<Collect> collects) {
  Map<String, double> totalWeightByMonth = <String, double>{};

  for (int i = 0; i < collects.length; i++) {
    if (totalWeightByMonth
        .containsKey(toMonthString(collects[i].collectedOn))) {
      double currentSum =
          totalWeightByMonth[toMonthString(collects[i].collectedOn)]!;
      double newSum = collects[i].ammount + currentSum;
      totalWeightByMonth[toMonthString(collects[i].collectedOn)] = newSum;
    } else {
      totalWeightByMonth[toMonthString(collects[i].collectedOn)] =
          collects[i].ammount;
    }
  }

  return totalWeightByMonth;
}

double totalWeight(List<Collect> collects) {
  double total = 0;
  for (Collect c in collects) {
    total += c.ammount;
  }

  return total;
}
