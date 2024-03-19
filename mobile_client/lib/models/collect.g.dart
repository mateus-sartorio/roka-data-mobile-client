// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collect.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectAdapter extends TypeAdapter<Collect> {
  @override
  final int typeId = 2;

  @override
  Collect read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Collect(
      ammount: fields[1] as double,
      collectedOn: fields[2] as DateTime,
      id: fields[0] as int,
      residentId: fields[3] as int,
      isNew: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Collect obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ammount)
      ..writeByte(2)
      ..write(obj.collectedOn)
      ..writeByte(3)
      ..write(obj.residentId)
      ..writeByte(4)
      ..write(obj.isNew);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
