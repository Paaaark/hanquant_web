import 'package:flutter/material.dart';

class WatchlistWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // List of ticker symbols to show
    final symbols = (config['symbols'] as List<String>?) ?? ['AAPL', 'GOOG'];

    // List of info fields to display
    final infoFields = (config['info'] as List<String>?) ?? [];

    return Stack(
      children: [
        // Main content: vertical list of tickers
        Column(
          children: symbols.map<Widget>((symbol) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                leading: const Icon(Icons.trending_up),
                // Title row: ticker + up to 2 info items
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
                          info,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                // Subtitle row: up to 3 info items
                subtitle: infoFields.length > 2
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            for (final info in infoFields.skip(2).take(3)) ...[
                              Flexible(
                                child: Text(
                                  info,
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
          }).toList(),
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
                arguments: id,
              );
            },
          ),
        ),
      ],
    );
  }
}
