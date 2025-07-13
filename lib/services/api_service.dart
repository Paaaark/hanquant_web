import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/index_summary.dart';
import '../models/stock_summary.dart';

class ApiService {
  static const _baseUrl = 'http://192.168.45.186:8080';

  // Fetch index summary by index code
  static Future<IndexSummary> fetchIndexSummary(String indexCode) async {
    final url = Uri.parse('$_baseUrl/index/$indexCode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return IndexSummary(
        indexName: data['IndexName'] ?? '',
        changeRate: data['ChangeRate'] ?? '',
        isChangePositive: data["ChangeFromPrev"][0] != '-' ? true : false,
        currentPrice: data['CurrentPrice'] ?? '',
        high: data['High'] ?? '',
        low: data['Low'] ?? '',
      );
    } else {
      throw Exception('Failed to load index data');
    }
  }

  // Fetch trending stocks (limit 10)
  // metric: fluctuation, volume, market-cap
  static Future<List<StockSummary>> fetchTopTrendingStocks(
      String metric) async {
    final url =
        Uri.parse('$_baseUrl/ranking/$metric'); // Adjust endpoint as needed
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.take(10).map((jsonStock) {
        return StockSummary(
          logoUrl: '', // Add if available
          stockName: jsonStock['Name'] ?? '',
          stockCode: jsonStock['Code'] ?? '',
          changePercentage: jsonStock['ChangeRate'] ?? '',
          currentPrice: jsonStock['Price'] ?? '',
          volume: jsonStock['Volume'] ?? '',
          marketCap: jsonStock['MarketCap'] ?? '',
        );
      }).toList();
    } else {
      throw Exception('Failed to load trending stocks');
    }
  }
}
