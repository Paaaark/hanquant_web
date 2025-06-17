import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/market_widget_model.dart';

class WidgetManager extends StateNotifier<List<MarketWidgetModel>> {
  static const _boxName = 'market_widgets';
  final Box box;

  WidgetManager(this.box) : super([]) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final List<dynamic>? saved = box.get('widgets');
    if (saved != null) {
      state = saved.cast<MarketWidgetModel>();
    }
  }

  void _saveToStorage() {
    box.put('widgets', state);
  }

  void addWidget(WidgetType type, Map<String, dynamic> config) {
    final newWidget = MarketWidgetModel(
      id: const Uuid().v4(),
      type: type,
      config: config,
    );
    state = [...state, newWidget];
    _saveToStorage();
  }

  void editWidget(String id, Map<String, dynamic> newConfig) {
    state = [
      for (final widget in state)
        if (widget.id == id)
          MarketWidgetModel(id: id, type: widget.type, config: newConfig)
        else
          widget
    ];
    _saveToStorage();
  }

  void deleteWidget(String id) {
    state = state.where((w) => w.id != id).toList();
    _saveToStorage();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final items = [...state];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = items;
    _saveToStorage();
  }
}

final widgetManagerProvider =
    StateNotifierProvider<WidgetManager, List<MarketWidgetModel>>((ref) {
  final box = Hive.box('market_widgets');
  return WidgetManager(box);
});
