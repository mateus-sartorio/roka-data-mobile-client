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
      address: fields[2] as String,
      collects: (fields[19] as List).cast<Collect>(),
      hasPlaque: fields[9] as bool,
      isOnWhatsappGroup: fields[8] as bool,
      livesInJN: fields[4] as bool,
      name: fields[1] as String,
      observations: fields[14] as String,
      phone: fields[7] as String,
      profession: fields[5] as String,
      referencePoint: fields[3] as String,
      registrationYear: fields[10] as int,
      residentsInTheHouse: fields[11] as int,
      rokaId: fields[12] as int,
      situation: fields[13] as Situation,
      needsCollectOnTheHouse: fields[15] as bool,
      isNew: fields[16] as bool,
      birthdate: fields[6] as DateTime,
      isMarkedForRemoval: fields[18] as bool,
      wasModified: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Resident obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.referencePoint)
      ..writeByte(4)
      ..write(obj.livesInJN)
      ..writeByte(5)
      ..write(obj.profession)
      ..writeByte(6)
      ..write(obj.birthdate)
      ..writeByte(7)
      ..write(obj.phone)
      ..writeByte(8)
      ..write(obj.isOnWhatsappGroup)
      ..writeByte(9)
      ..write(obj.hasPlaque)
      ..writeByte(10)
      ..write(obj.registrationYear)
      ..writeByte(11)
      ..write(obj.residentsInTheHouse)
      ..writeByte(12)
      ..write(obj.rokaId)
      ..writeByte(13)
      ..write(obj.situation)
      ..writeByte(14)
      ..write(obj.observations)
      ..writeByte(15)
      ..write(obj.needsCollectOnTheHouse)
      ..writeByte(16)
      ..write(obj.isNew)
      ..writeByte(17)
      ..write(obj.wasModified)
      ..writeByte(18)
      ..write(obj.isMarkedForRemoval)
      ..writeByte(19)
      ..write(obj.collects);
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
