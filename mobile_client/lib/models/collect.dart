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

  Collect(
      {required this.ammount,
      required this.collectedOn,
      required this.id,
      required this.residentId,
      required this.isNew});
}
