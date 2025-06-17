import 'package:flutter/material.dart';
import '../pages/market/widgets/watchlist_edit_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String watchlistEdit = '/watchlist-edit';

  static Map<String, WidgetBuilder> get routes => {
        watchlistEdit: (context) {
          final widgetId = ModalRoute.of(context)!.settings.arguments as String;
          return WatchlistEditPage(widgetId: widgetId);
        },
      };
}
