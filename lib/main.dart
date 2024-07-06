import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/enums/shift.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/currency_handout.dart';
import 'package:mobile_client/models/receipt.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/pages/home_page.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(SituationAdapter());
  Hive.registerAdapter(ShiftAdapter());
  Hive.registerAdapter(CollectAdapter());
  Hive.registerAdapter(ResidentAdapter());
  Hive.registerAdapter(CurrencyHandoutAdapter());
  Hive.registerAdapter(ReceiptAdapter());
  await Hive.openBox("globalDatabase");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MainState();
}

class _MainState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('pt', 'BR'), // Portuguese (Brazil)
        // Add more locales as needed
      ],
      locale: Locale('pt', 'BR'), // Set default locale
      // other MaterialApp configurations
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData.light(),
    );
  }
}
