import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:hanquant_frontend/models/index_summary.dart';
import 'package:hanquant_frontend/models/stock_summary.dart';
import 'package:hanquant_frontend/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Cache for data to prevent refetching
  static List<IndexSummary>? _cachedIndices;
  static List<StockSummary>? _cachedVolumeStocks;
  static List<StockSummary>? _cachedFluctuationStocks;
  static List<StockSummary>? _cachedMarketCapStocks;
  static DateTime? _lastFetchTime;

  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  late Future<List<IndexSummary>> _indicesFuture;
  late Future<void> _allTrendingStocksFuture;

  final List<String> _indexCodes = ['0001', '1001', '4001'];

  // Trening stock filter options
  final List<String> _filterOptions = ['Volume', 'Fluctuation', 'Market Cap'];
  String _selectedFilter = 'Volume';

  List<StockSummary> _volumeStocks = [];
  List<StockSummary> _fluctuationStocks = [];
  List<StockSummary> _marketCapStocks = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Check if we have valid cached data
    final now = DateTime.now();
    final hasValidCache = _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < _cacheDuration &&
        _cachedIndices != null &&
        _cachedVolumeStocks != null &&
        _cachedFluctuationStocks != null &&
        _cachedMarketCapStocks != null;

    if (hasValidCache) {
      // Use cached data
      setState(() {
        _volumeStocks = _cachedVolumeStocks!;
        _fluctuationStocks = _cachedFluctuationStocks!;
        _marketCapStocks = _cachedMarketCapStocks!;
      });
      _indicesFuture = Future.value(_cachedIndices!);
      _allTrendingStocksFuture = Future.value();
    } else {
      // Fetch fresh data
      _indicesFuture = _fetchIndices();
      _allTrendingStocksFuture = _fetchAllTrendingStocks();
    }
  }

  Future<List<IndexSummary>> _fetchIndices() async {
    final results = <IndexSummary>[];
    for (final code in _indexCodes) {
      try {
        final index = await ApiService.fetchIndexSummary(code);
        results.add(index);
      } catch (_) {}
    }

    // Cache the results
    _cachedIndices = results;
    _lastFetchTime = DateTime.now();

    return results;
  }

  Future<void> _fetchAllTrendingStocks() async {
    final volume = await ApiService.fetchTopTrendingStocks("volume");
    final fluctuation = await ApiService.fetchTopTrendingStocks("fluctuation");
    final marketCap = await ApiService.fetchTopTrendingStocks("market-cap");

    // Cache the results
    _cachedVolumeStocks = volume;
    _cachedFluctuationStocks = fluctuation;
    _cachedMarketCapStocks = marketCap;
    _lastFetchTime = DateTime.now();

    setState(() {
      _volumeStocks = volume;
      _fluctuationStocks = fluctuation;
      _marketCapStocks = marketCap;
    });
  }

  List<StockSummary> get _currentStocks {
    switch (_selectedFilter) {
      case 'Fluctuation':
        return _fluctuationStocks;
      case 'Market Cap':
        return _marketCapStocks;
      case 'Volume':
      default:
        return _volumeStocks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Market Overview")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildMarketSummary(),
            const SizedBox(height: 24),
            _trendingStocks(),
          ],
        ),
      ),
    );
  }

  Widget _trendingStocks() {
    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(3.0, 5.0, 3.0, 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                "Trending Stocks",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedFilter,
                items: _filterOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null && value != _selectedFilter) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  }
                },
              )
            ]),
            const SizedBox(height: 12),
            _buildTrendingStocks()
          ],
        ));
  }

  Widget _buildMarketSummary() {
    return FutureBuilder<List<IndexSummary>>(
        future: _indicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                height: 125, child: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Text('Error loading indices: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final indices = snapshot.data!;
            return SizedBox(
                height: 125,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: indices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = indices[index];
                    return _IndexCard(index: item);
                  },
                ));
          } else {
            return const Text('No index data available');
          }
        });
  }

  Widget _buildTrendingStocks() {
    // If we have cached data, show it immediately
    if (_volumeStocks.isNotEmpty ||
        _fluctuationStocks.isNotEmpty ||
        _marketCapStocks.isNotEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _currentStocks.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, index) {
          return _StockListItem(stock: _currentStocks[index]);
        },
      );
    }

    // Otherwise, show loading state
    return FutureBuilder<void>(
        future: _allTrendingStocksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error loading trending stocks: ${snapshot.error}');
          } else {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentStocks.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                return _StockListItem(stock: _currentStocks[index]);
              },
            );
          }
        });
  }
}

class _IndexCard extends StatelessWidget {
  final IndexSummary index;
  const _IndexCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final formattedPrice =
        NumberFormat('#,###.##').format(double.parse(index.currentPrice));
    final formattedHigh =
        NumberFormat('#,###.##').format(double.parse(index.high));
    final formattedLow =
        NumberFormat('#,###.##').format(double.parse(index.low));

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            index.isChangePositive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: index.isChangePositive ? Colors.green : Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                index.indexName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${index.changeRate}%',
                style: TextStyle(
                  color: index.isChangePositive ? Colors.green : Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$formattedPrice ₩', style: const TextStyle(fontSize: 15)),
          Text('High: $formattedHigh ₩',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('Low: $formattedLow ₩',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StockListItem extends StatelessWidget {
  final StockSummary stock;
  const _StockListItem({required this.stock});

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.changePercentage.startsWith('+');
    final formattedPrice =
        NumberFormat('#,###').format(double.parse(stock.currentPrice));

    return ListTile(
      leading: buildAvatar(stock.stockCode, stock.stockName),
      title:
          Text(stock.stockName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(stock.stockCode),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('$formattedPrice ₩', style: const TextStyle(fontSize: 16)),
          Text(
            '${stock.changePercentage}%',
            style: TextStyle(
                color: isPositive ? Colors.green : Colors.red, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

Widget buildAvatar(String stockCode, String stockName) {
  final url = 'https://logo.synthfinance.com/ticker/$stockCode';

  return FutureBuilder<http.Response>(
    future: http.get(Uri.parse(url)),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData &&
          snapshot.data!.statusCode == 200) {
        final contentType = snapshot.data!.headers['content-type'] ?? '';

        if (contentType.contains('image/svg')) {
          return CircleAvatar(
            backgroundColor: Colors.transparent,
            child:
                SizedBox(width: 32, height: 32, child: SvgPicture.network(url)),
          );
        } else {
          return CircleAvatar(
            child: Text(stockName[0]),
          );
        }
      } else {
        return CircleAvatar(
          child: Text(stockName[0]),
        );
      }
    },
  );
}
