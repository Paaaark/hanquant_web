import 'package:flutter/foundation.dart';
import '../models/stock_snapshot.dart';
import '../services/stock_data_service.dart';
import 'dart:async';

class StockDataProvider extends ChangeNotifier {
  final StockDataService _stockDataService = StockDataService();
  Map<String, StockSnapshot> _stockData = {};
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  Map<String, StockSnapshot> get stockData => _stockData;
  bool get isInitialized => _isInitialized;

  StockDataProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();
    try {
      print('Initializing StockDataProvider...');
      await _stockDataService.initialize('ws://192.168.45.178:8080/ws/stocks');
      _stockDataService.stockDataStream.listen((data) {
        print('Received stock data update: ${data.length} stocks');
        _stockData = data;
        notifyListeners();
      });
      _isInitialized = true;
      notifyListeners();
      print('StockDataProvider initialized successfully');
      _initCompleter?.complete();
    } catch (e) {
      print('Error initializing StockDataProvider: $e');
      _initCompleter?.completeError(e);
      rethrow;
    }
  }

  Future<void> subscribeToTickers(List<String> tickers) async {
    print('Attempting to subscribe to tickers: $tickers');
    if (!_isInitialized) {
      print('Provider not initialized, waiting for initialization...');
      await _initCompleter?.future;
    }

    if (tickers.isEmpty) {
      print('No tickers to subscribe to');
      return;
    }

    print('Subscribing to tickers: $tickers');
    await _stockDataService.subscribeToTickers(tickers);
    print('Subscription request sent for tickers: $tickers');
  }

  Future<void> unsubscribeFromTickers(List<String> tickers) async {
    if (!_isInitialized) return;
    print('Unsubscribing from tickers: $tickers');
    await _stockDataService.unsubscribeFromTickers(tickers);
  }

  StockSnapshot? getStockSnapshot(String ticker) {
    return _stockData[ticker];
  }

  @override
  void dispose() {
    _stockDataService.dispose();
    super.dispose();
  }
}
