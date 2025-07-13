import 'package:json_annotation/json_annotation.dart';
import 'stock_snapshot.dart';

part 'websocket_message.g.dart';

@JsonSerializable()
class WSMessage {
  final String type;
  final List<String>? tickers;
  final List<StockSnapshot>? data;
  final String? error;

  WSMessage({
    required this.type,
    this.tickers,
    this.data,
    this.error,
  });

  factory WSMessage.fromJson(Map<String, dynamic> json) =>
      _$WSMessageFromJson(json);

  Map<String, dynamic> toJson() => _$WSMessageToJson(this);

  bool get isSubscribe => type == 'subscribe';
  bool get isUnsubscribe => type == 'unsubscribe';
  bool get isSnapshot => type == 'snapshot';
  bool get isError => type == 'error';
}
