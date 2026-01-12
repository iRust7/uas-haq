// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      username: fields[0] as String,
      lastLoginAt: fields[1] as DateTime,
      isLoggedIn: fields[2] as bool,
      password: fields[3] as String?,
      isGuest: fields[4] as bool,
      email: fields[5] as String?,
      displayName: fields[6] as String?,
      photoURL: fields[7] as String?,
      authProvider: fields[8] as String?,
      uid: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.lastLoginAt)
      ..writeByte(2)
      ..write(obj.isLoggedIn)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.isGuest)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.displayName)
      ..writeByte(7)
      ..write(obj.photoURL)
      ..writeByte(8)
      ..write(obj.authProvider)
      ..writeByte(9)
      ..write(obj.uid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
