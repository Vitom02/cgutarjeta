// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TarjetaScoresAdapter extends TypeAdapter<TarjetaScores> {
  @override
  final int typeId = 7;

  @override
  TarjetaScores read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TarjetaScores(
      id: fields[0] as String?,
      scores1: (fields[1] as List?)?.cast<int>(),
      scores2: (fields[2] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, TarjetaScores obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scores1)
      ..writeByte(2)
      ..write(obj.scores2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TarjetaScoresAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
