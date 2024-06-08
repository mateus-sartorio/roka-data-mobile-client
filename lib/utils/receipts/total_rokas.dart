import 'package:mobile_client/models/receipt.dart';

double totalRokasValue(List<Receipt> receipts) {
  double total = 0;
  for (Receipt c in receipts) {
    total += c.value;
  }

  return total;
}
