import 'package:hive/hive.dart';

part 'currency_handout.g.dart';

@HiveType(typeId: 4, adapterName: "CurrencyHandoutAdapter")
class CurrencyHandout extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime startDate;

  @HiveField(3)
  bool isNew;

  @HiveField(4)
  bool wasModified;

  @HiveField(5)
  bool isMarkedForRemoval;

  CurrencyHandout(
      {required this.id,
      required this.title,
      required this.startDate,
      required this.isNew,
      required this.wasModified,
      required this.isMarkedForRemoval});
}
