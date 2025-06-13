import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/index_summary.dart';
import '../models/stock_summary.dart';

class ApiService {
  static const _baseUrl = 'http://192.168.45.8:8081';

  // Fetch index summary by index code
  static Future<IndexSummary> fetchIndexSummary(String indexCode) async {
    final url = Uri.parse('$_baseUrl/index/$indexCode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return IndexSummary(
        indexName: data['IndexName'] ?? '',
        changeRate: data['bstp_nmix_prdy_ctrt'] ?? '',
        isChangePositive: data["prdy_vrss_sign"] == "1" ? true : false,
        currentPrice: data['bstp_nmix_prpr'] ?? '',
        high: data['bstp_nmix_hgpr'] ?? '',
        low: data['bstp_nmix_lwpr'] ?? '',
      );
    } else {
      throw Exception('Failed to load index data');
    }
  }

  // Fetch trending stocks (limit 10)
  static Future<List<StockSummary>> fetchTrendingStocks() async {
    final url =
        Uri.parse('$_baseUrl/ranking/fluctuation'); // Adjust endpoint as needed
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.take(10).map((jsonStock) {
        return StockSummary(
          logoUrl: '', // Add if available
          stockName: jsonStock['hts_kor_isnm'] ?? '',
          stockCode: jsonStock['stck_shrn_iscd'] ?? '',
          changePercentage: jsonStock['prdy_ctrt'] ?? '',
          currentPrice: jsonStock['stck_prpr'] ?? '',
        );
      }).toList();
    } else {
      throw Exception('Failed to load trending stocks');
    }
  }
}
