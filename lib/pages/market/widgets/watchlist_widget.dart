import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/stock_data_provider.dart';
import '../../../models/stock_snapshot.dart';

class WatchlistWidget extends StatefulWidget {
  final String id;
  final Map<String, dynamic> config;
  final VoidCallback? onSettingsPressed;

  const WatchlistWidget({
    Key? key,
    required this.id,
    required this.config,
    this.onSettingsPressed,
  }) : super(key: key);

  @override
  State<WatchlistWidget> createState() => _WatchlistWidgetState();
}

class _WatchlistWidgetState extends State<WatchlistWidget> {
  List<String> _currentSymbols = [];

  @override
  void initState() {
    super.initState();
    _currentSymbols = (widget.config['symbols'] as List<String>?) ?? [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockDataProvider>().subscribeToTickers(_currentSymbols);
    });
  }

  @override
  void didUpdateWidget(WatchlistWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newSymbols = (widget.config['symbols'] as List<String>?) ?? [];

    // Find symbols to unsubscribe (removed from config)
    final symbolsToUnsubscribe = _currentSymbols
        .where((symbol) => !newSymbols.contains(symbol))
        .toList();

    // Find symbols to subscribe (newly added to config)
    final symbolsToSubscribe = newSymbols
        .where((symbol) => !_currentSymbols.contains(symbol))
        .toList();

    if (symbolsToUnsubscribe.isNotEmpty) {
      context
          .read<StockDataProvider>()
          .unsubscribeFromTickers(symbolsToUnsubscribe);
    }
    if (symbolsToSubscribe.isNotEmpty) {
      context.read<StockDataProvider>().subscribeToTickers(symbolsToSubscribe);
    }

    _currentSymbols = newSymbols;
  }

  @override
  void dispose() {
    context.read<StockDataProvider>().unsubscribeFromTickers(_currentSymbols);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List of info fields to display
    final infoFields = (widget.config['info'] as List<String>?) ?? [];

    return Stack(
      children: [
        // Main content: vertical list of tickers
        Consumer<StockDataProvider>(
          builder: (context, provider, child) {
            if (!provider.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: _currentSymbols.map<Widget>((symbol) {
                final snapshot = provider.getStockSnapshot(symbol);
                if (snapshot == null) {
                  return _buildLoadingTicker(symbol, infoFields);
                }
                return _buildStockTicker(snapshot, infoFields);
              }).toList(),
            );
          },
        ),

        // Floating settings button at top-right
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.settings, size: 20),
            splashRadius: 20,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/watchlist-edit',
                arguments: widget.id,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingTicker(String symbol, List<String> infoFields) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: const Icon(Icons.trending_up),
        title: Row(
          children: [
            Text(
              symbol,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(width: 8),
            for (final info in infoFields.take(2)) ...[
              Flexible(
                child: Text(
                  'Loading...',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockTicker(StockSnapshot snapshot, List<String> infoFields) {
    final isPositive = snapshot.changeSign == '2';
    final color = isPositive ? Colors.red : Colors.blue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: const Icon(Icons.trending_up),
        title: Row(
          children: [
            Text(
              snapshot.code,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(width: 8),
            for (final info in infoFields.take(2)) ...[
              Flexible(
                child: Text(
                  _getInfoValue(snapshot, info),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        subtitle: infoFields.length > 2
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    for (final info in infoFields.skip(2).take(3)) ...[
                      Flexible(
                        child: Text(
                          _getInfoValue(snapshot, info),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ],
                ),
              )
            : null,
      ),
    );
  }

  String _getInfoValue(StockSnapshot snapshot, String info) {
    switch (info) {
      case 'Price':
        return snapshot.price;
      case 'Open':
        return snapshot.open;
      case 'High':
        return snapshot.high;
      case 'Low':
        return snapshot.low;
      case 'Volume':
        return snapshot.volume;
      case 'Change %':
        return '${snapshot.changeRate}%';
      default:
        return '';
    }
  }
}
