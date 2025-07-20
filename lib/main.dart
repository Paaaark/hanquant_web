import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'app/app.dart';
import 'package:hanquant_frontend/models/market_widget_model.dart';
import 'providers/stock_data_provider.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(WidgetTypeAdapter());
  Hive.registerAdapter(MarketWidgetModelAdapter());
  await Hive.openBox('market_widgets');

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => StockDataProvider()),
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}
