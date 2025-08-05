import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/index_summary.dart';
import '../models/stock_summary.dart';

class ApiService {
  static const _baseUrl = 'http://43.203.29.9:8080';

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

  // Login method
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  // Register method
  static Future<void> register(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 201) {
      return;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Registration failed');
    }
  }

  // List linked accounts
  static Future<List<Map<String, dynamic>>> getLinkedAccounts(
      String token) async {
    final url = Uri.parse('$_baseUrl/accounts');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error']?['message'] ?? 'Failed to fetch accounts');
    }
  }

  // Link a new bank account
  static Future<Map<String, dynamic>> linkBankAccount({
    required String token,
    required String accountId,
    required String appKey,
    required String appSecret,
    required String cano,
    bool? isMock,
  }) async {
    final url = Uri.parse('$_baseUrl/accounts');
    final body = <String, dynamic>{
      'account_id': accountId,
      'app_key': appKey,
      'app_secret': appSecret,
      'cano': cano,
    };
    if (isMock != null) body['is_mock'] = isMock;
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['error']?['message'] ?? 'Failed to link account');
    }
  }

  // Delete a linked bank account
  static Future<void> deleteBankAccount({
    required String token,
    required int id,
  }) async {
    final url = Uri.parse('$_baseUrl/accounts/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      final data = jsonDecode(response.body);
      throw Exception(data['error']?['message'] ?? 'Failed to delete account');
    }
  }

  // Fetch portfolio for a linked account
  static Future<Map<String, dynamic>> getPortfolio({
    required String token,
    required String accountId,
  }) async {
    final url = Uri.parse('$_baseUrl/portfolio?account_id=$accountId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error']?['message'] ?? 'Failed to fetch portfolio');
    }
  }

  // Server management methods
  static const String _lambdaUrl =
      'https://lmd3dvmg5pehw7xrynnqdrbmga0rlmjj.lambda-url.ap-northeast-2.on.aws/';

  static Future<String> getServerStatus() async {
    final url = Uri.parse('$_lambdaUrl?action=status');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['state'] ?? 'unknown';
    } else {
      throw Exception('Failed to get server status');
    }
  }

  static Future<void> startServer() async {
    final url = Uri.parse('$_lambdaUrl?action=wake');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to start server');
    }
  }

  static Future<void> stopServer() async {
    final url = Uri.parse('$_lambdaUrl?action=stop');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to stop server');
    }
  }
}
