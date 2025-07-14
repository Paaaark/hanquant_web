import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    final priceColor = isPositive ? Colors.green : Colors.red;
    final formattedPrice = _formatKRW(snapshot.price);

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
      child: Row(
        children: [
          // Logo column
          buildAvatar(snapshot.code, snapshot.name),
          const SizedBox(width: 8),

          // Name and code column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  snapshot.code,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Price and change rate column (in same row)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${snapshot.changeRate}%',
                style: TextStyle(
                  color: priceColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formattedPrice,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: priceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatKRW(String value) {
    try {
      final number = double.parse(value);
      return '${NumberFormat('#,###').format(number)} ₩';
    } catch (e) {
      return '$value ₩';
    }
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
