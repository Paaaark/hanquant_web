import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    // List of info fields to display (excluding Price and Change % as they're default)
    final infoFields = (widget.config['info'] as List<String>?) ?? [];
    final customFields = infoFields
        .where((field) => field != 'Price' && field != 'Change %')
        .toList();

    // If no tickers, don't show the widget
    if (_currentSymbols.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Main content: vertical list of tickers
        Consumer<StockDataProvider>(
          builder: (context, provider, child) {
            if (!provider.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information fields chips or title
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customFields.isNotEmpty
                      ? Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: customFields.map((field) {
                            return Chip(
                              label: Text(
                                field,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.blue.shade50,
                              side: BorderSide(color: Colors.blue.shade200),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        )
                      : const Text(
                          'Watchlist Ticker',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const Divider(height: 1),
                // Stock tickers
                ..._currentSymbols.map<Widget>((symbol) {
                  final snapshot = provider.getStockSnapshot(symbol);
                  if (snapshot == null) {
                    return _buildLoadingTicker(symbol, customFields);
                  }
                  return _buildStockTicker(snapshot, customFields);
                }).toList(),
              ],
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

  Widget _buildLoadingTicker(String symbol, List<String> customFields) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.trending_up),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Loading...',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              if (customFields.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildCustomFieldsRow(customFields.take(2).toList(), null),
                if (customFields.length > 2) ...[
                  const SizedBox(height: 2),
                  _buildCustomFieldsRow(
                      customFields.skip(2).take(2).toList(), null),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockTicker(StockSnapshot snapshot, List<String> customFields) {
    final isPositive = snapshot.changeSign == '2';
    final priceColor = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Logo column
          buildAvatar(snapshot.code, snapshot.name),
          const SizedBox(width: 12),

          // Name and code column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  snapshot.code,
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Price, change rate, and custom fields column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Price and Change Rate in the same row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${snapshot.changeRate}%',
                    style: Theme.of(context).textTheme.caption?.copyWith(
                          color: priceColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatKRW(snapshot.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: priceColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),

              // Custom fields in rows of 2
              if (customFields.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildCustomFieldsRow(customFields.take(2).toList(), snapshot),
                if (customFields.length > 2) ...[
                  const SizedBox(height: 2),
                  _buildCustomFieldsRow(
                      customFields.skip(2).take(2).toList(), snapshot),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomFieldsRow(List<String> fields, StockSnapshot? snapshot) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: fields.map((field) {
        final value = snapshot != null
            ? _getFormattedInfoValue(snapshot, field)
            : 'Loading...';
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            value,
            style: Theme.of(context).textTheme.caption?.copyWith(
                  color: Colors.black87,
                ),
          ),
        );
      }).toList(),
    );
  }

  String _getFormattedInfoValue(StockSnapshot snapshot, String info) {
    switch (info) {
      case 'Open':
        return _formatKRW(snapshot.open);
      case 'High':
        return _formatKRW(snapshot.high);
      case 'Low':
        return _formatKRW(snapshot.low);
      case 'Volume':
        return _formatVolume(snapshot.volume);
      case 'SecurityType':
        return snapshot.securityType;
      case 'AskPrice':
        return _formatKRW(snapshot.askPrice);
      case 'BidPrice':
        return _formatKRW(snapshot.bidPrice);
      case 'AskVolume':
        return _formatVolume(snapshot.askVolume);
      case 'BidVolume':
        return _formatVolume(snapshot.bidVolume);
      case 'TotalAskVolume':
        return _formatVolume(snapshot.totalAskVolume);
      case 'TotalBidVolume':
        return _formatVolume(snapshot.totalBidVolume);
      case 'TotalTradedValue':
        return _formatLargeNumber(snapshot.totalTradedValue);
      default:
        return '';
    }
  }

  String _formatKRW(String value) {
    try {
      final number = double.parse(value);
      return '${NumberFormat('#,###').format(number)} ₩';
    } catch (e) {
      return '$value ₩';
    }
  }

  String _formatVolume(String value) {
    try {
      final number = double.parse(value);
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      }
      return NumberFormat('#,###').format(number);
    } catch (e) {
      return value;
    }
  }

  String _formatLargeNumber(String value) {
    try {
      final number = double.parse(value);
      if (number >= 1000000000000) {
        // Trillion
        return '${(number / 1000000000000).toStringAsFixed(3)} T';
      } else if (number >= 1000000000) {
        // Billion
        return '${(number / 1000000000).toStringAsFixed(3)} B';
      } else if (number >= 1000000) {
        // Million
        return '${(number / 1000000).toStringAsFixed(3)} M';
      } else if (number >= 1000) {
        // Thousand
        return '${(number / 1000).toStringAsFixed(3)} K';
      }
      return NumberFormat('#,###').format(number);
    } catch (e) {
      return value;
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
