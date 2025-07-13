import 'dart:async';
import '../models/stock_snapshot.dart';
import '../models/websocket_message.dart';
import 'websocket_service.dart';

class StockDataService {
  static final StockDataService _instance = StockDataService._internal();
  factory StockDataService() => _instance;
  StockDataService._internal();

  final _stockDataController =
      StreamController<Map<String, StockSnapshot>>.broadcast();
  final Map<String, StockSnapshot> _stockData = {};
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription? _wsSubscription;

  Stream<Map<String, StockSnapshot>> get stockDataStream =>
      _stockDataController.stream;
  Map<String, StockSnapshot> get currentStockData => Map.from(_stockData);

  Future<void> initialize(String wsUrl) async {
    await _wsService.connect(wsUrl);
    _wsSubscription = _wsService.messageStream.listen(_handleWebSocketMessage);
  }

  void _handleWebSocketMessage(dynamic message) {
    if (message is! WSMessage) return;

    if (message.isSnapshot && message.data != null) {
      for (final snapshot in message.data!) {
        _stockData[snapshot.code] = snapshot;
      }
      _stockDataController.add(Map.from(_stockData));
    }
  }

  Future<void> subscribeToTickers(List<String> tickers) async {
    await _wsService.subscribe(tickers);
  }

  Future<void> unsubscribeFromTickers(List<String> tickers) async {
    await _wsService.unsubscribe(tickers);
    for (final ticker in tickers) {
      _stockData.remove(ticker);
    }
    _stockDataController.add(Map.from(_stockData));
  }

  StockSnapshot? getStockSnapshot(String ticker) {
    return _stockData[ticker];
  }

  void dispose() {
    _wsSubscription?.cancel();
    _stockDataController.close();
    _wsService.dispose();
  }
}
