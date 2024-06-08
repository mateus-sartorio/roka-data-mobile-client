// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftAdapter extends TypeAdapter<Shift> {
  @override
  final int typeId = 6;

  @override
  Shift read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Shift.morning;
      case 1:
        return Shift.afternoon;
      default:
        return Shift.morning;
    }
  }

  @override
  void write(BinaryWriter writer, Shift obj) {
    switch (obj) {
      case Shift.morning:
        writer.writeByte(0);
        break;
      case Shift.afternoon:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
