import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../managers/widget_manager.dart';
import '../../../models/stock_listing.dart';
import '../../../widgets/stock_search_field.dart';
import "package:hanquant_frontend/widgets/watchlist_ticker.dart";

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

  // Track if changes have been made
  bool _hasChanges = false;
  List<String> _originalInfoFields = [];
  List<String> _originalSymbols = [];

  // Available information fields that can be displayed
  // Note: Price and Change % are now default and not selectable
  static const List<String> availableInfoFields = [
    'Open',
    'High',
    'Low',
    'Volume',
    'SecurityType',
    'AskPrice',
    'BidPrice',
    'AskVolume',
    'BidVolume',
    'TotalAskVolume',
    'TotalBidVolume',
    'TotalTradedValue',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if any
    final widgets = ref.read(widgetManagerProvider);
    final widgetModel = widgets.firstWhere((w) => w.id == widget.widgetId);
    final symbols = (widgetModel.config['symbols'] as List<String>?) ?? [];
    final info = (widgetModel.config['info'] as List<String>?) ?? [];

    // Store original values for change detection
    _originalSymbols = List.from(symbols);
    _originalInfoFields = List.from(
        info.where((field) => field != 'Price' && field != 'Change %'));

    // Initialize ticker controllers
    for (final symbol in symbols) {
      _tickerControllers.add(TextEditingController(text: symbol));
    }
    // Add one empty controller if no tickers exist
    if (_tickerControllers.isEmpty) {
      _tickerControllers.add(TextEditingController());
    }

    // Initialize selected info fields (filter out Price and Change % as they're now default)
    _selectedInfoFields.addAll(_originalInfoFields);
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
        _hasChanges = true;
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
      _hasChanges = true;
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
      _hasChanges = true;
    });
  }

  void _onFieldSelectionChanged(String field, bool selected) {
    setState(() {
      if (selected) {
        if (_selectedInfoFields.length >= 4) {
          _showMaxFieldsWarning();
          return;
        }
        _selectedInfoFields.add(field);
      } else {
        _selectedInfoFields.remove(field);
      }
      _hasChanges = true;
    });
  }

  void _showMaxFieldsWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maximum Fields Reached'),
        content: const Text(
            'You can select at most 4 additional information fields.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Would you like to apply the changes you made?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (result == true) {
      _saveChanges();
    }
    return true;
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final symbols = _tickerControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    // Add Price and Change % as default fields
    final allInfoFields = ['Price', 'Change %', ..._selectedInfoFields];

    final manager = ref.read(widgetManagerProvider.notifier);
    manager.editWidget(widget.widgetId, {
      'symbols': symbols,
      'info': allInfoFields,
    });

    setState(() {
      _hasChanges = false;
    });

    Navigator.pop(context);
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Watchlist'),
        content: const Text(
            'Are you sure you want to delete this watchlist? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteWidget();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteWidget() {
    final manager = ref.read(widgetManagerProvider.notifier);
    manager.deleteWidget(widget.widgetId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Watchlist'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
              color: Colors.red,
            ),
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
                        'Additional Information Fields',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Note: Price and Change % are always displayed by default',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selected: ${_selectedInfoFields.length}/4',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: availableInfoFields.map((field) {
                          final isSelected =
                              _selectedInfoFields.contains(field);
                          return FilterChip(
                            label: Text(field),
                            selected: isSelected,
                            onSelected: (selected) =>
                                _onFieldSelectionChanged(field, selected),
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
      ),
    );
  }
}
