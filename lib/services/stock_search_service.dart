import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'dart:math';
import '../models/stock_listing.dart';

class StockSearchService {
  static final StockSearchService _instance = StockSearchService._internal();
  factory StockSearchService() => _instance;
  StockSearchService._internal();

  List<StockListing> _stockListings = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String csvData =
          await rootBundle.loadString('assets/stock_listings_complete.csv');
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(csvData);

      _stockListings = rows.skip(1).map((row) {
        final stock = StockListing(
          code: row[0].toString(),
          isin: row[1].toString(),
          name: row[2].toString(),
          securityType: row[3].toString(),
          capSize: row[4].toString(),
          indLarge: row[5].toString(),
          indMedium: row[6].toString(),
          indSmall: row[7].toString(),
          market: row.length > 8 ? row[8].toString() : '1',
        );
        return stock;
      }).toList();

      _isInitialized = true;
      print(
          'StockSearchService initialized with ${_stockListings.length} stocks');
    } catch (e) {
      print('Error initializing StockSearchService: $e');
      rethrow;
    }
  }

  List<StockListing> search(String query) {
    if (!_isInitialized) {
      print('StockSearchService not initialized');
      return [];
    }

    if (query.isEmpty) return [];

    final normalizedQuery = query.toLowerCase();

    final results = _stockListings
        .map((stock) {
          final nameScore = _calculateStringSimilarity(
              stock.name.toLowerCase(), normalizedQuery);
          final codeScore = _calculateStringSimilarity(
              stock.code.toLowerCase(), normalizedQuery);
          final isinScore = _calculateStringSimilarity(
              stock.isin.toLowerCase(), normalizedQuery);

          final stringScore = max(max(nameScore, codeScore), isinScore);
          final capSizeScore = _getCapSizeScore(stock.capSize);
          final securityTypeScore = _getSecurityTypeScore(stock.securityType);

          final totalScore = (stringScore * 0.6) +
              (capSizeScore * 0.25) +
              (securityTypeScore * 0.15);

          return _SearchResult(stock: stock, score: totalScore);
        })
        .where((result) => result.score > 0.3)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return results.map((r) => r.stock).toList();
  }

  double _calculateStringSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Exact match
    if (s1 == s2) return 1.0;

    // Contains match
    if (s1.contains(s2) || s2.contains(s1)) return 0.8;

    // Character overlap
    final chars1 = s1.split('');
    final chars2 = s2.split('');
    final commonChars = chars1.where((c) => chars2.contains(c)).length;

    return commonChars / max(chars1.length, chars2.length);
  }

  double _getCapSizeScore(String capSize) {
    switch (capSize) {
      case '1':
        return 3.0; // Large cap
      case '2':
        return 2.0; // Mid cap
      case '3':
      default:
        return 1.0; // Small cap or invalid
    }
  }

  double _getSecurityTypeScore(String securityType) {
    switch (securityType) {
      case 'ST': // 주권
      case 'EF': // ETF
      case 'EW': // ELW
        return 3.0; // Most common/preferred types
      case 'DR': // 주식예탁증서
        return 2.0;
      default:
        return 1.0; // Less common types
    }
  }
}

class _SearchResult {
  final StockListing stock;
  final double score;

  _SearchResult({required this.stock, required this.score});
}
