import 'package:hive_flutter/adapters.dart';

part 'shift.g.dart';

@HiveType(typeId: 6)
enum Shift {
  @HiveField(0)
  morning(0),

  @HiveField(1)
  afternoon(1);

  final int value;

  const Shift(this.value);
}
