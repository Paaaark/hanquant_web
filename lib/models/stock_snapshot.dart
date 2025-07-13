import 'package:json_annotation/json_annotation.dart';

part 'stock_snapshot.g.dart';

@JsonSerializable()
class StockSnapshot {
  @JsonKey(name: 'Code')
  final String code;
  @JsonKey(name: 'Name')
  final String name;
  @JsonKey(name: 'Price')
  final String price;
  @JsonKey(name: 'Change')
  final String change;
  @JsonKey(name: 'ChangeSign')
  final String changeSign;
  @JsonKey(name: 'ChangeRate')
  final String changeRate;
  @JsonKey(name: 'Open')
  final String open;
  @JsonKey(name: 'High')
  final String high;
  @JsonKey(name: 'Low')
  final String low;
  @JsonKey(name: 'Volume')
  final String volume;
  @JsonKey(name: 'SecurityType')
  final String securityType;
  @JsonKey(name: 'AskPrice')
  final String askPrice;
  @JsonKey(name: 'BidPrice')
  final String bidPrice;
  @JsonKey(name: 'AskVolume')
  final String askVolume;
  @JsonKey(name: 'BidVolume')
  final String bidVolume;
  @JsonKey(name: 'TotalAskVolume')
  final String totalAskVolume;
  @JsonKey(name: 'TotalBidVolume')
  final String totalBidVolume;
  @JsonKey(name: 'TotalTradedValue')
  final String totalTradedValue;

  StockSnapshot({
    required this.code,
    required this.name,
    required this.price,
    required this.change,
    required this.changeSign,
    required this.changeRate,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.securityType,
    required this.askPrice,
    required this.bidPrice,
    required this.askVolume,
    required this.bidVolume,
    required this.totalAskVolume,
    required this.totalBidVolume,
    required this.totalTradedValue,
  });

  factory StockSnapshot.fromJson(Map<String, dynamic> json) =>
      _$StockSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$StockSnapshotToJson(this);

  StockSnapshot copyWith({
    String? code,
    String? name,
    String? price,
    String? change,
    String? changeSign,
    String? changeRate,
    String? open,
    String? high,
    String? low,
    String? volume,
    String? securityType,
    String? askPrice,
    String? bidPrice,
    String? askVolume,
    String? bidVolume,
    String? totalAskVolume,
    String? totalBidVolume,
    String? totalTradedValue,
  }) {
    return StockSnapshot(
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      change: change ?? this.change,
      changeSign: changeSign ?? this.changeSign,
      changeRate: changeRate ?? this.changeRate,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      volume: volume ?? this.volume,
      securityType: securityType ?? this.securityType,
      askPrice: askPrice ?? this.askPrice,
      bidPrice: bidPrice ?? this.bidPrice,
      askVolume: askVolume ?? this.askVolume,
      bidVolume: bidVolume ?? this.bidVolume,
      totalAskVolume: totalAskVolume ?? this.totalAskVolume,
      totalBidVolume: totalBidVolume ?? this.totalBidVolume,
      totalTradedValue: totalTradedValue ?? this.totalTradedValue,
    );
  }
}
