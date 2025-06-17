import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hanquant_frontend/models/market_widget_model.dart';
import 'package:hanquant_frontend/managers/widget_manager.dart';
import 'package:hanquant_frontend/pages/market/widgets/widget_factory.dart';

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  bool _showAddOptions = false;

  @override
  Widget build(BuildContext context) {
    final widgets = ref.watch(widgetManagerProvider);
    final manager = ref.read(widgetManagerProvider.notifier);
    final widgetTypes = WidgetType.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widgets.length + 1,
        onReorder: (oldIndex, newIndex) {
          if (!_showAddOptions) {
            final maxIndex = widgets.length;
            if (oldIndex < maxIndex && newIndex <= maxIndex) {
              manager.reorder(oldIndex, newIndex);
            }
          }
        },
        itemBuilder: (context, index) {
          // Render existing widgets
          if (index < widgets.length) {
            final widgetModel = widgets[index];
            return Card(
              key: ValueKey(widgetModel.id),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: WidgetFactory.buildPreview(widgetModel),
            );
          }

          // Add New Widget / Expanded options
          return Card(
            key: const ValueKey('add-widget-card'),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          _showAddOptions
                              ? 'Select Widget Type'
                              : 'Add New Widget',
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            _showAddOptions ? Icons.close : Icons.add,
                          ),
                          onPressed: () {
                            setState(() {
                              _showAddOptions = !_showAddOptions;
                            });
                          },
                        ),
                      ),
                      if (_showAddOptions)
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.5,
                          children: widgetTypes.map((type) {
                            return InkWell(
                              key: ValueKey('add-option-${type.name}'),
                              onTap: () {
                                manager.addWidget(type, <String, dynamic>{});
                                setState(() => _showAddOptions = false);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).cardColor,
                                ),
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _iconForType(type),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: Text(
                                        _labelForType(type),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Icon _iconForType(WidgetType type) {
    switch (type) {
      case WidgetType.watchlist:
        return const Icon(Icons.list);
      case WidgetType.miniChart:
        return const Icon(Icons.show_chart);
      case WidgetType.indicesSummary:
        return const Icon(Icons.pie_chart);
      case WidgetType.sectorPerformance:
        return const Icon(Icons.bar_chart);
      case WidgetType.economicSnapshot:
        return const Icon(Icons.account_balance);
      default:
        return const Icon(Icons.device_unknown);
    }
  }

  String _labelForType(WidgetType type) {
    switch (type) {
      case WidgetType.watchlist:
        return 'Watchlist Ticker';
      case WidgetType.miniChart:
        return 'Mini Chart';
      case WidgetType.indicesSummary:
        return 'Indices Summary';
      case WidgetType.sectorPerformance:
        return 'Sector Performance';
      case WidgetType.economicSnapshot:
        return 'Economic Snapshot';
    }
  }
}
