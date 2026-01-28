// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversationcache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveConversationModelAdapter extends TypeAdapter<HiveConversationModel> {
  @override
  final int typeId = 1;

  @override
  HiveConversationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveConversationModel(
      conversationId: fields[0] as String,
      conversationName: fields[1] as String,
      lastMessage: fields[2] as String,
      participantId: (fields[3] as List).cast<String>(),
      updatedAt: fields[4] as String,
      type: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveConversationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.conversationId)
      ..writeByte(1)
      ..write(obj.conversationName)
      ..writeByte(2)
      ..write(obj.lastMessage)
      ..writeByte(3)
      ..write(obj.participantId)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveConversationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
