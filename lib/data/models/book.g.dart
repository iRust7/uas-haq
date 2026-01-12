// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 1;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      tags: (fields[3] as List).cast<String>(),
      filePathOrUri: fields[4] as String,
      addedAt: fields[5] as DateTime,
      lastPage: fields[6] as int,
      totalPages: fields[7] as int,
      bookmarks: (fields[8] as List).cast<int>(),
      lastReadAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.filePathOrUri)
      ..writeByte(5)
      ..write(obj.addedAt)
      ..writeByte(6)
      ..write(obj.lastPage)
      ..writeByte(7)
      ..write(obj.totalPages)
      ..writeByte(8)
      ..write(obj.bookmarks)
      ..writeByte(9)
      ..write(obj.lastReadAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
