import 'package:hive/hive.dart';

part 'collect.g.dart';

@HiveType(typeId: 2, adapterName: "CollectAdapter")
class Collect extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  double ammount;

  @HiveField(2)
  DateTime collectedOn;

  @HiveField(3)
  int residentId;

  @HiveField(4)
  bool isNew;

  @HiveField(5)
  bool wasModified;

  @HiveField(6)
  bool isMarkedForRemoval;

  @HiveField(7)
  bool wasSuccessfullySentToBackendOnLastSync;

  Collect(
      {required this.ammount,
      required this.collectedOn,
      required this.id,
      required this.residentId,
      required this.isNew,
      required this.wasModified,
      required this.isMarkedForRemoval,
      required this.wasSuccessfullySentToBackendOnLastSync});
}
