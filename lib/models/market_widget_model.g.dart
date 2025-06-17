// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_widget_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarketWidgetModelAdapter extends TypeAdapter<MarketWidgetModel> {
  @override
  final int typeId = 1;

  @override
  MarketWidgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarketWidgetModel(
      id: fields[0] as String,
      type: fields[1] as WidgetType,
      config: (fields[2] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, MarketWidgetModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.config);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketWidgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WidgetTypeAdapter extends TypeAdapter<WidgetType> {
  @override
  final int typeId = 0;

  @override
  WidgetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WidgetType.watchlist;
      case 1:
        return WidgetType.miniChart;
      case 2:
        return WidgetType.indicesSummary;
      case 3:
        return WidgetType.sectorPerformance;
      case 4:
        return WidgetType.economicSnapshot;
      default:
        return WidgetType.watchlist;
    }
  }

  @override
  void write(BinaryWriter writer, WidgetType obj) {
    switch (obj) {
      case WidgetType.watchlist:
        writer.writeByte(0);
        break;
      case WidgetType.miniChart:
        writer.writeByte(1);
        break;
      case WidgetType.indicesSummary:
        writer.writeByte(2);
        break;
      case WidgetType.sectorPerformance:
        writer.writeByte(3);
        break;
      case WidgetType.economicSnapshot:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
