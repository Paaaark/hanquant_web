import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/websocket_message.dart';
import '../models/stock_snapshot.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final Set<String> _subscribedTickers = {};
  final _messageController = StreamController<WSMessage>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  bool _isConnected = false;

  Stream<WSMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;
  Set<String> get subscribedTickers => Set.from(_subscribedTickers);

  Future<void> connect(String url) async {
    if (_channel != null) {
      print('WebSocket already connected, disconnecting first...');
      await disconnect();
    }

    try {
      print('Connecting to WebSocket at $url...');
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      _connectionController.add(true);
      print('WebSocket connected successfully');

      _channel!.stream.listen(
        (message) {
          try {
            print('Received WebSocket message: $message');
            String decodedMessage;

            if (message is List<int>) {
              // Handle binary message
              decodedMessage = utf8.decode(message);
              print('Decoded binary message: $decodedMessage');
            } else {
              // Handle string message
              decodedMessage = message.toString();
            }

            final wsMessage = WSMessage.fromJson(jsonDecode(decodedMessage));
            _messageController.add(wsMessage);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
            print('Raw message: $message');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          _connectionController.add(false);
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          _connectionController.add(false);
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _isConnected = false;
      _connectionController.add(false);
      rethrow;
    }
  }

  Future<void> disconnect() async {
    print('Disconnecting WebSocket...');
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _connectionController.add(false);
    print('WebSocket disconnected');
  }

  Future<void> subscribe(List<String> tickers) async {
    if (!_isConnected) {
      print('Cannot subscribe: WebSocket is not connected');
      throw Exception('WebSocket is not connected');
    }

    final newTickers =
        tickers.where((t) => !_subscribedTickers.contains(t)).toList();
    if (newTickers.isEmpty) {
      print('No new tickers to subscribe to');
      return;
    }

    print('Subscribing to new tickers: $newTickers');
    print('Ticker format check:');
    for (final ticker in newTickers) {
      print(
          '  Ticker: "$ticker" (length: ${ticker.length}, type: ${ticker.runtimeType})');
    }

    final message = WSMessage(
      type: 'subscribe',
      tickers: newTickers,
    );

    final jsonMessage = jsonEncode(message.toJson());
    print('Sending subscription message: $jsonMessage');
    _channel?.sink.add(jsonMessage);
    _subscribedTickers.addAll(newTickers);
    print('Subscription request sent for tickers: $newTickers');
  }

  Future<void> unsubscribe(List<String> tickers) async {
    if (!_isConnected) {
      print('Cannot unsubscribe: WebSocket is not connected');
      throw Exception('WebSocket is not connected');
    }

    print('Unsubscribing from tickers: $tickers');
    final message = WSMessage(
      type: 'unsubscribe',
      tickers: tickers,
    );

    final jsonMessage = jsonEncode(message.toJson());
    print('Sending unsubscription message: $jsonMessage');
    _channel?.sink.add(jsonMessage);
    _subscribedTickers.removeAll(tickers);
    print('Unsubscription request sent for tickers: $tickers');
  }

  void dispose() {
    print('Disposing WebSocket service...');
    disconnect();
    _messageController.close();
    _connectionController.close();
    print('WebSocket service disposed');
  }
}
