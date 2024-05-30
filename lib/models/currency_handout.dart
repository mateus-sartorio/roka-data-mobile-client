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

  @HiveField(6)
  bool wasSuccessfullySentToBackendOnLastSync;

  CurrencyHandout(
      {required this.id,
      required this.title,
      required this.startDate,
      required this.isNew,
      required this.wasModified,
      required this.isMarkedForRemoval,
      required this.wasSuccessfullySentToBackendOnLastSync});

  String toStringFormat() {
    List<String> dayMonthYear = startDate.toString().split(" ")[0].split("-");
    "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

    String displayTitle = title.length >= 15 ? title.substring(0, 15) : title;

    return "$displayTitle - ${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";
  }
}
