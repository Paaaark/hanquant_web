import 'package:flutter/material.dart';
import 'package:hanquant_frontend/models/index_summary.dart';
import 'package:hanquant_frontend/models/stock_summary.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Sample dummy data for indices and stocks
  final List<IndexSummary> indices = [
    IndexSummary(
      indexName: "KOSPI",
      changeRate: "+1.25%",
      currentPrice: "3,200",
      high: "3,220",
      low: "3,180",
    ),
    IndexSummary(
      indexName: "KOSDAQ",
      changeRate: "-0.45%",
      currentPrice: "950",
      high: "960",
      low: "945",
    ),
    IndexSummary(
      indexName: "Dow Jones",
      changeRate: "+0.75%",
      currentPrice: "34,000",
      high: "34,200",
      low: "33,800",
    ),
  ];

  final List<StockSummary> trendingStocks = List.generate(
    10,
    (index) => StockSummary(
      logoUrl: '', // TODO: add logo URLs or placeholder
      stockName: "Stock $index",
      stockCode: "CODE$index",
      changePercentage: (index % 2 == 0 ? "+0.${index}%" : "-0.${index}%"),
      currentPrice: "${100 + index * 5}",
    ),
  );

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
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: indices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = indices[index];
          return _IndexCard(index: item);
        },
      ),
    );
  }

  Widget _buildTrendingStocks() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trendingStocks.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final stock = trendingStocks[index];
        return _StockListItem(stock: stock);
      },
    );
  }
}

class _IndexCard extends StatelessWidget {
  final IndexSummary index;
  const _IndexCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final isPositive = index.changeRate.startsWith('+');
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPositive ? Colors.green : Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(index.indexName,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(index.changeRate,
              style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red, fontSize: 14)),
          const SizedBox(height: 8),
          Text('Price: ${index.currentPrice}',
              style: const TextStyle(fontSize: 14)),
          Text('High: ${index.high}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('Low: ${index.low}',
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
        child: Text(stock.stockCode.substring(0, 1)), // Placeholder for logo
      ),
      title: Text(stock.stockName),
      subtitle: Text(stock.stockCode),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(stock.currentPrice,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            stock.changePercentage,
            style: TextStyle(color: isPositive ? Colors.green : Colors.red),
          ),
        ],
      ),
    );
  }
}
