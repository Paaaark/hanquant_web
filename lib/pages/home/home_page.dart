import 'package:flutter/material.dart';
import 'package:hanquant_frontend/models/index_summary.dart';
import 'package:hanquant_frontend/models/stock_summary.dart';
import 'package:hanquant_frontend/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<IndexSummary>> _indicesFuture;
  late Future<List<StockSummary>> _trendingStocksFuture;

  final List<String> _indexCodes = ['0001', '1001', '4001'];

  @override
  void initState() {
    super.initState();
    _indicesFuture = _fetchIndices();
    _trendingStocksFuture = ApiService.fetchTrendingStocks();
  }

  Future<List<IndexSummary>> _fetchIndices() async {
    final results = <IndexSummary>[];
    for (final code in _indexCodes) {
      try {
        final index = await ApiService.fetchIndexSummary(code);
        results.add(index);
      } catch (_) {}
    }
    return results;
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
            const Text("Market Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildMarketSummary(),
            const SizedBox(height: 24),
            const Text("Trending Stocks",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTrendingStocks(),
          ],
        ),
      ),
    );
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
    return FutureBuilder<List<StockSummary>>(
        future: _trendingStocksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error loading trending stocks: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final stocks = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stocks.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (cotext, index) {
                final stock = stocks[index];
                return _StockListItem(stock: stock);
              },
            );
          } else {
            return const Text('No trending stocks data available');
          }
        });
  }
}

class _IndexCard extends StatelessWidget {
  final IndexSummary index;
  const _IndexCard({required this.index});

  @override
  Widget build(BuildContext context) {
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
          Text('${index.currentPrice}₩', style: const TextStyle(fontSize: 14)),
          Text('High: ${index.high}₩',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('Low: ${index.low}₩',
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
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
            'https://logo.synthfinance.com/ticker/${stock.stockCode}'),
        child: null,
      ),
      title: Text(stock.stockName),
      subtitle: Text(stock.stockCode),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${stock.currentPrice}₩',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '${stock.changePercentage}%',
            style: TextStyle(color: isPositive ? Colors.green : Colors.red),
          ),
        ],
      ),
    );
  }
}
