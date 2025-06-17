import 'package:flutter/material.dart';
import 'package:hanquant_frontend/models/market_widget_model.dart';
import 'watchlist_widget.dart'; // Assume we'll create this

class WidgetFactory {
  static Widget buildPreview(MarketWidgetModel model) {
    switch (model.type) {
      case WidgetType.watchlist:
        return WatchlistWidget(config: model.config);
      // Add more widget types as needed
      default:
        return const Text('Unknown widget type');
    }
  }
}
