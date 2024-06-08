import 'package:hive/hive.dart';

part 'receipt.g.dart';

@HiveType(typeId: 4, adapterName: "ReceiptAdapter")
class Receipt extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  DateTime handoutDate;

  @HiveField(2)
  double value;

  @HiveField(3)
  int residentId;

  @HiveField(4)
  int currencyHandoutId;

  @HiveField(5)
  bool isNew;

  @HiveField(6)
  bool wasModified;

  @HiveField(7)
  bool isMarkedForRemoval;

  @HiveField(8)
  bool wasSuccessfullySentToBackendOnLastSync;

  Receipt(
      {required this.id,
      required this.value,
      required this.handoutDate,
      required this.residentId,
      required this.currencyHandoutId,
      required this.isNew,
      required this.wasModified,
      required this.isMarkedForRemoval,
      required this.wasSuccessfullySentToBackendOnLastSync});
}
