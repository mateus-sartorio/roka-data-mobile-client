// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptAdapter extends TypeAdapter<Receipt> {
  @override
  final int typeId = 5;

  @override
  Receipt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Receipt(
      id: fields[0] as int,
      value: fields[2] as double,
      handoutDate: fields[1] as DateTime,
      residentId: fields[3] as int,
      currencyHandoutId: fields[4] as int,
      isNew: fields[5] as bool,
      wasModified: fields[6] as bool,
      isMarkedForRemoval: fields[7] as bool,
      wasSuccessfullySentToBackendOnLastSync: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Receipt obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.handoutDate)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.residentId)
      ..writeByte(4)
      ..write(obj.currencyHandoutId)
      ..writeByte(5)
      ..write(obj.isNew)
      ..writeByte(6)
      ..write(obj.wasModified)
      ..writeByte(7)
      ..write(obj.isMarkedForRemoval)
      ..writeByte(8)
      ..write(obj.wasSuccessfullySentToBackendOnLastSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
