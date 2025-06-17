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
        // Parse market cap with fallback to 0.0
        double parseMarketCap(dynamic value) {
          if (value == null) return 0.0;
          return double.tryParse(value.toString()) ?? 0.0;
        }

        final stock = StockListing(
          code: row[0].toString(), // Keep as string to preserve leading zeros
          isin: row[1].toString(),
          name: row[2].toString(),
          securityType: row[3].toString(),
          capSize: row[4].toString(),
          indLarge: row[5].toString(),
          indMedium: row[6].toString(),
          indSmall: row[7].toString(),
          marketCap: parseMarketCap(row[8]),
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
          final groupCodeScore = _getGroupCodeScore(stock.securityType);

          return _SearchResult(
            stock: stock,
            stringScore: stringScore,
            groupCodeScore: groupCodeScore,
            marketCap: stock.marketCap,
          );
        })
        .where((result) => result.stringScore > 0.3)
        .toList()
      ..sort((a, b) {
        final similarityCompare = b.stringScore.compareTo(a.stringScore);
        if (similarityCompare != 0) return similarityCompare;

        final groupCodeCompare = b.groupCodeScore.compareTo(a.groupCodeScore);
        if (groupCodeCompare != 0) return groupCodeCompare;

        return b.marketCap.compareTo(a.marketCap);
      });

    results.forEach((r) {
      print('${r.stock.code} (${r.stock.name}): marketCap=${r.marketCap}');
    });

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

  double _getGroupCodeScore(String securityType) {
    switch (securityType) {
      case 'ST': // 주권
      case 'EF': // ETF
      case 'EW': // ELW
        return 3.0; // Highest priority
      default:
        return 1.0; // Lower priority
    }
  }
}

class _SearchResult {
  final StockListing stock;
  final double stringScore;
  final double groupCodeScore;
  final double marketCap;

  _SearchResult({
    required this.stock,
    required this.stringScore,
    required this.groupCodeScore,
    required this.marketCap,
  });
}
