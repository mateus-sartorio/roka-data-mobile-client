// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resident.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResidentAdapter extends TypeAdapter<Resident> {
  @override
  final int typeId = 1;

  @override
  Resident read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Resident(
      id: fields[0] as int,
      address: fields[1] as String,
      collects: (fields[2] as List).cast<Collect>(),
      hasPlaque: fields[3] as bool,
      isOnWhatsappGroup: fields[4] as bool,
      livesInJN: fields[5] as bool,
      name: fields[6] as String,
      observations: fields[7] as String,
      phone: fields[8] as String,
      profession: fields[9] as String,
      referencePoint: fields[10] as String,
      registrationYear: fields[11] as int,
      residentsInTheHouse: fields[12] as int,
      rokaId: fields[13] as int,
      situation: fields[14] as Situation,
      isNew: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Resident obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.collects)
      ..writeByte(3)
      ..write(obj.hasPlaque)
      ..writeByte(4)
      ..write(obj.isOnWhatsappGroup)
      ..writeByte(5)
      ..write(obj.livesInJN)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.observations)
      ..writeByte(8)
      ..write(obj.phone)
      ..writeByte(9)
      ..write(obj.profession)
      ..writeByte(10)
      ..write(obj.referencePoint)
      ..writeByte(11)
      ..write(obj.registrationYear)
      ..writeByte(12)
      ..write(obj.residentsInTheHouse)
      ..writeByte(13)
      ..write(obj.rokaId)
      ..writeByte(14)
      ..write(obj.situation)
      ..writeByte(15)
      ..write(obj.isNew);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResidentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
