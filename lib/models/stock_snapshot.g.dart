// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockSnapshot _$StockSnapshotFromJson(Map<String, dynamic> json) =>
    StockSnapshot(
      code: json['Code'] as String,
      name: json['Name'] as String,
      price: json['Price'] as String,
      change: json['Change'] as String,
      changeSign: json['ChangeSign'] as String,
      changeRate: json['ChangeRate'] as String,
      open: json['Open'] as String,
      high: json['High'] as String,
      low: json['Low'] as String,
      volume: json['Volume'] as String,
      securityType: json['SecurityType'] as String,
      askPrice: json['AskPrice'] as String,
      bidPrice: json['BidPrice'] as String,
      askVolume: json['AskVolume'] as String,
      bidVolume: json['BidVolume'] as String,
      totalAskVolume: json['TotalAskVolume'] as String,
      totalBidVolume: json['TotalBidVolume'] as String,
      totalTradedValue: json['TotalTradedValue'] as String,
    );

Map<String, dynamic> _$StockSnapshotToJson(StockSnapshot instance) =>
    <String, dynamic>{
      'Code': instance.code,
      'Name': instance.name,
      'Price': instance.price,
      'Change': instance.change,
      'ChangeSign': instance.changeSign,
      'ChangeRate': instance.changeRate,
      'Open': instance.open,
      'High': instance.high,
      'Low': instance.low,
      'Volume': instance.volume,
      'SecurityType': instance.securityType,
      'AskPrice': instance.askPrice,
      'BidPrice': instance.bidPrice,
      'AskVolume': instance.askVolume,
      'BidVolume': instance.bidVolume,
      'TotalAskVolume': instance.totalAskVolume,
      'TotalBidVolume': instance.totalBidVolume,
      'TotalTradedValue': instance.totalTradedValue,
    };
