// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_set.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeamSetAdapter extends TypeAdapter<TeamSet> {
  @override
  final int typeId = 0;

  @override
  TeamSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TeamSet(
      name: fields[0] as String,
      names: (fields[1] as List).cast<String>(),
      teams: (fields[2] as List)
          .map((dynamic e) => (e as List).cast<String>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, TeamSet obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.names)
      ..writeByte(2)
      ..write(obj.teams);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
