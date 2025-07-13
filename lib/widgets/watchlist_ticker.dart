import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_data_provider.dart';
import '../models/stock_snapshot.dart';

class WatchlistTicker extends StatefulWidget {
  final List<String> tickers;

  const WatchlistTicker({
    super.key,
    required this.tickers,
  });

  @override
  State<WatchlistTicker> createState() => _WatchlistTickerState();
}

class _WatchlistTickerState extends State<WatchlistTicker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockDataProvider>().subscribeToTickers(widget.tickers);
    });
  }

  @override
  void dispose() {
    context.read<StockDataProvider>().unsubscribeFromTickers(widget.tickers);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockDataProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.tickers.length,
          itemBuilder: (context, index) {
            final ticker = widget.tickers[index];
            final snapshot = provider.getStockSnapshot(ticker);

            if (snapshot == null) {
              return _buildLoadingTicker(ticker);
            }

            return _buildStockTicker(snapshot);
          },
        );
      },
    );
  }

  Widget _buildLoadingTicker(String ticker) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticker,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildStockTicker(StockSnapshot snapshot) {
    final isPositive = snapshot.changeSign == '2';
    final color = isPositive ? Colors.red : Colors.blue;

    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                snapshot.code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                snapshot.name,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                snapshot.price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${snapshot.change} (${snapshot.changeRate}%)',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
