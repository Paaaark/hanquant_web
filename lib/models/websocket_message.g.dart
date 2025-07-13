// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WSMessage _$WSMessageFromJson(Map<String, dynamic> json) => WSMessage(
      type: json['type'] as String,
      tickers:
          (json['tickers'] as List<dynamic>?)?.map((e) => e as String).toList(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StockSnapshot.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$WSMessageToJson(WSMessage instance) => <String, dynamic>{
      'type': instance.type,
      'tickers': instance.tickers,
      'data': instance.data,
      'error': instance.error,
    };
