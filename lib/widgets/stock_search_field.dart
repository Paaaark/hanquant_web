import 'package:flutter/material.dart';
import 'dart:async';
import '../models/stock_listing.dart';
import '../services/stock_search_service.dart';

class StockSearchField extends StatefulWidget {
  final Function(StockListing) onStockSelected;
  final String? initialValue;

  const StockSearchField({
    super.key,
    required this.onStockSelected,
    this.initialValue,
  });

  @override
  State<StockSearchField> createState() => _StockSearchFieldState();
}

class _StockSearchFieldState extends State<StockSearchField> {
  final _searchService = StockSearchService();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<StockListing> _searchResults = [];
  bool _showResults = false;
  Timer? _debounceTimer;
  bool _isInitialized = false;
  bool _showAllResults = false;

  @override
  void initState() {
    super.initState();
    print('StockSearchField: Initializing...'); // Debug log
    _initializeSearch();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  Future<void> _initializeSearch() async {
    try {
      await _searchService.initialize();
      _isInitialized = true;
      print('StockSearchField: Initialization complete'); // Debug log
    } catch (e) {
      print('StockSearchField: Error initializing - $e'); // Debug log
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (!_isInitialized) {
      print(
          'StockSearchField: Search service not initialized yet'); // Debug log
      return;
    }

    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Set a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        print('StockSearchField: Searching for "$query"'); // Debug log
        setState(() {
          _searchResults = _searchService.search(query);
          _showResults = query.isNotEmpty;
          _showAllResults = false; // Reset show all when search changes
          print(
              'StockSearchField: Found ${_searchResults.length} results'); // Debug log
        });
      }
    });
  }

  void _onStockSelected(StockListing stock) {
    print(
        'StockSearchField: Selected stock ${stock.code} - ${stock.name}'); // Debug log
    _controller.text = stock.name;
    _focusNode.unfocus();
    setState(() => _showResults = false);
    widget.onStockSelected(stock);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            labelText: 'Search Stocks',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _onSearchChanged,
          onTap: () {
            if (_controller.text.isNotEmpty) {
              setState(() => _showResults = true);
            }
          },
        ),
        if (_showResults && _searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _showAllResults
                    ? _searchResults.length
                    : (_searchResults.length > 10 ? 11 : _searchResults.length),
                itemBuilder: (context, index) {
                  if (!_showAllResults && index == 10) {
                    return ListTile(
                      title: const Text('See more results...'),
                      onTap: () {
                        setState(() => _showAllResults = true);
                      },
                    );
                  }

                  final stock = _searchResults[index];
                  return ListTile(
                    title: Text(stock.name),
                    subtitle: Text(stock.code),
                    onTap: () => _onStockSelected(stock),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
