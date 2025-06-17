import 'package:hive/hive.dart';

part 'market_widget_model.g.dart'; // Run build_runner for this

@HiveType(typeId: 0)
enum WidgetType {
  @HiveField(0)
  watchlist,

  @HiveField(1)
  miniChart,

  @HiveField(2)
  indicesSummary,

  @HiveField(3)
  sectorPerformance,

  @HiveField(4)
  economicSnapshot,
}

@HiveType(typeId: 1)
class MarketWidgetModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final WidgetType type;

  @HiveField(2)
  final Map<String, dynamic> config;

  MarketWidgetModel({
    required this.id,
    required this.type,
    required this.config,
  });
}
