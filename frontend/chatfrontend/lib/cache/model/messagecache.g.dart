// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messagecache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMessageModelAdapter extends TypeAdapter<HiveMessageModel> {
  @override
  final int typeId = 2;

  @override
  HiveMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMessageModel(
      conversationId: fields[0] as String,
      messageId: fields[1] as String,
      message: fields[2] as String,
      messageType: fields[3] as String,
      createdAt: fields[4] as String,
      senderId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveMessageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.conversationId)
      ..writeByte(1)
      ..write(obj.messageId)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.messageType)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.senderId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
