import 'package:hive/hive.dart';

part 'situation.g.dart';

@HiveType(typeId: 5)
enum Situation {
  @HiveField(0)
  active,

  @HiveField(1)
  inactive,

  @HiveField(2)
  noContact,
}
