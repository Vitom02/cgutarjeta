// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarjeta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TarjetaAdapter extends TypeAdapter<Tarjeta> {
  @override
  final int typeId = 6;

  @override
  Tarjeta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tarjeta(
      id: fields[0] as String?,
      nombreTorneo: fields[1] as String,
      matricula: fields[2] as String,
      matriculaCompanion: fields[3] as String,
      nombreJugador: fields[4] as String,
      bochaSeleccionada1: fields[5] as Bocha?,
      bochaSeleccionada2: fields[6] as Bocha?,
      tarjetaScores: fields[7] as TarjetaScores?,
    );
  }

  @override
  void write(BinaryWriter writer, Tarjeta obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombreTorneo)
      ..writeByte(2)
      ..write(obj.matricula)
      ..writeByte(3)
      ..write(obj.matriculaCompanion)
      ..writeByte(4)
      ..write(obj.nombreJugador)
      ..writeByte(5)
      ..write(obj.bochaSeleccionada1)
      ..writeByte(6)
      ..write(obj.bochaSeleccionada2)
      ..writeByte(7)
      ..write(obj.tarjetaScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TarjetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
