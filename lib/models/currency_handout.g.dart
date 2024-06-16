// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_handout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyHandoutAdapter extends TypeAdapter<CurrencyHandout> {
  @override
  final int typeId = 3;

  @override
  CurrencyHandout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyHandout(
      id: fields[0] as int,
      title: fields[1] as String,
      startDate: fields[2] as DateTime,
      isNew: fields[3] as bool,
      wasModified: fields[4] as bool,
      isMarkedForRemoval: fields[5] as bool,
      wasSuccessfullySentToBackendOnLastSync: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyHandout obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.isNew)
      ..writeByte(4)
      ..write(obj.wasModified)
      ..writeByte(5)
      ..write(obj.isMarkedForRemoval)
      ..writeByte(6)
      ..write(obj.wasSuccessfullySentToBackendOnLastSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyHandoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
