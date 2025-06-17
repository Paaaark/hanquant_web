import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../managers/widget_manager.dart';
import '../../../models/stock_listing.dart';
import '../../../widgets/stock_search_field.dart';

// TODO: In the future, we can expand this to support searching/autocomplete for tickers
class WatchlistEditPage extends ConsumerStatefulWidget {
  final String widgetId;

  const WatchlistEditPage({
    super.key,
    required this.widgetId,
  });

  @override
  ConsumerState<WatchlistEditPage> createState() => _WatchlistEditPageState();
}

class _WatchlistEditPageState extends ConsumerState<WatchlistEditPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _tickerControllers = [];
  final List<String> _selectedInfoFields = [];
  final List<StockListing> _selectedStocks = [];

  // Available information fields that can be displayed
  // TODO: Expand this list as more features are added
  static const List<String> availableInfoFields = [
    'Price',
    'Open',
    'High',
    'Low',
    'Close',
    'Volume',
    'Change %',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if any
    final widgets = ref.read(widgetManagerProvider);
    final widgetModel = widgets.firstWhere((w) => w.id == widget.widgetId);
    final symbols = (widgetModel.config['symbols'] as List<String>?) ?? [];
    final info = (widgetModel.config['info'] as List<String>?) ?? [];

    // Initialize ticker controllers
    for (final symbol in symbols) {
      _tickerControllers.add(TextEditingController(text: symbol));
    }
    // Add one empty controller if no tickers exist
    if (_tickerControllers.isEmpty) {
      _tickerControllers.add(TextEditingController());
    }

    // Initialize selected info fields
    _selectedInfoFields.addAll(info);
  }

  @override
  void dispose() {
    for (final controller in _tickerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTicker() {
    if (_tickerControllers.length < 5) {
      setState(() {
        _tickerControllers.add(TextEditingController());
      });
    }
  }

  void _removeTicker(int index) {
    setState(() {
      _tickerControllers[index].dispose();
      _tickerControllers.removeAt(index);
      if (index < _selectedStocks.length) {
        _selectedStocks.removeAt(index);
      }
    });
  }

  void _onStockSelected(int index, StockListing stock) {
    setState(() {
      _tickerControllers[index].text = stock.code;
      if (index < _selectedStocks.length) {
        _selectedStocks[index] = stock;
      } else {
        _selectedStocks.add(stock);
      }
    });
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final symbols = _tickerControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final manager = ref.read(widgetManagerProvider.notifier);
    manager.editWidget(widget.widgetId, {
      'symbols': symbols,
      'info': _selectedInfoFields,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Information Fields Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Information Fields',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: availableInfoFields.map((field) {
                        final isSelected = _selectedInfoFields.contains(field);
                        return FilterChip(
                          label: Text(field),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (_selectedInfoFields.length < 5) {
                                  _selectedInfoFields.add(field);
                                }
                              } else {
                                _selectedInfoFields.remove(field);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Ticker List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tickers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_tickerControllers.length < 5)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addTicker,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_tickerControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: StockSearchField(
                                initialValue: _tickerControllers[index].text,
                                onStockSelected: (stock) =>
                                    _onStockSelected(index, stock),
                              ),
                            ),
                            if (_tickerControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeTicker(index),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
