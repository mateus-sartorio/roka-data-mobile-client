import 'package:mobile_client/models/receipt.dart';
import 'package:mobile_client/utils/dates/to_date_string.dart';

double totalRokasValue(List<Receipt> receipts) {
  double total = 0;
  for (Receipt c in receipts) {
    total += c.value;
  }

  return total;
}

Map<String, double> totalRokasValueByDate(List<Receipt> receipts) {
  Map<String, double> totalWeightByHandoutDate = <String, double>{};

  for (int i = 0; i < receipts.length; i++) {
    if (totalWeightByHandoutDate.containsKey(toDateString(receipts[i].handoutDate))) {
      double currentSum = totalWeightByHandoutDate[toDateString(receipts[i].handoutDate)]!;
      double newSum = receipts[i].value + currentSum;
      totalWeightByHandoutDate[toDateString(receipts[i].handoutDate)] = newSum;
    } else {
      totalWeightByHandoutDate[toDateString(receipts[i].handoutDate)] = receipts[i].value;
    }
  }

  return totalWeightByHandoutDate;
}
