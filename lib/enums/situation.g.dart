// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'situation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SituationAdapter extends TypeAdapter<Situation> {
  @override
  final int typeId = 3;

  @override
  Situation read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Situation.active;
      case 1:
        return Situation.inactive;
      case 2:
        return Situation.noContact;
      default:
        return Situation.active;
    }
  }

  @override
  void write(BinaryWriter writer, Situation obj) {
    switch (obj) {
      case Situation.active:
        writer.writeByte(0);
        break;
      case Situation.inactive:
        writer.writeByte(1);
        break;
      case Situation.noContact:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SituationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
