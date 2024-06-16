import 'package:mobile_client/enums/shift.dart';

Shift getShiftFromInt(int n) {
  switch (n) {
    case 0:
      return Shift.morning;
    case 1:
      return Shift.afternoon;
    default:
      throw Exception("No Shift value corresponds to the numeric value $n");
  }
}
