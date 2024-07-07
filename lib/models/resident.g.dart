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
      address: fields[3] as String,
      collects: (fields[21] as List).cast<Collect>(),
      hasPlaque: fields[10] as bool,
      isOnWhatsappGroup: fields[9] as bool,
      livesInJN: fields[5] as bool,
      name: fields[1] as String,
      description: fields[2] as String,
      observations: fields[15] as String,
      phone: fields[8] as String,
      profession: fields[6] as String,
      referencePoint: fields[4] as String,
      registrationDate: fields[11] as DateTime?,
      residentsInTheHouse: fields[12] as int,
      rokaId: fields[13] as int,
      situation: fields[14] as Situation,
      needsCollectOnTheHouse: fields[16] as bool,
      shiftForCollectionOnTheHouse: fields[17] as Shift?,
      isNew: fields[18] as bool,
      birthdate: fields[7] as DateTime?,
      isMarkedForRemoval: fields[20] as bool,
      wasModified: fields[19] as bool,
      receipts: (fields[22] as List).cast<Receipt>(),
      wasSuccessfullySentToBackendOnLastSync: fields[23] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Resident obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.referencePoint)
      ..writeByte(5)
      ..write(obj.livesInJN)
      ..writeByte(6)
      ..write(obj.profession)
      ..writeByte(7)
      ..write(obj.birthdate)
      ..writeByte(8)
      ..write(obj.phone)
      ..writeByte(9)
      ..write(obj.isOnWhatsappGroup)
      ..writeByte(10)
      ..write(obj.hasPlaque)
      ..writeByte(11)
      ..write(obj.registrationDate)
      ..writeByte(12)
      ..write(obj.residentsInTheHouse)
      ..writeByte(13)
      ..write(obj.rokaId)
      ..writeByte(14)
      ..write(obj.situation)
      ..writeByte(15)
      ..write(obj.observations)
      ..writeByte(16)
      ..write(obj.needsCollectOnTheHouse)
      ..writeByte(17)
      ..write(obj.shiftForCollectionOnTheHouse)
      ..writeByte(18)
      ..write(obj.isNew)
      ..writeByte(19)
      ..write(obj.wasModified)
      ..writeByte(20)
      ..write(obj.isMarkedForRemoval)
      ..writeByte(21)
      ..write(obj.collects)
      ..writeByte(22)
      ..write(obj.receipts)
      ..writeByte(23)
      ..write(obj.wasSuccessfullySentToBackendOnLastSync);
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
