import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'package:hanquant_frontend/models/market_widget_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(WidgetTypeAdapter());
  Hive.registerAdapter(MarketWidgetModelAdapter());
  await Hive.openBox('market_widgets');

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}
