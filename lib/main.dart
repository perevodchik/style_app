import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:provider/provider.dart';
import 'package:style_app/providers/CitiesProvider.dart';
import 'package:style_app/providers/ConversionProvider.dart';
import 'package:style_app/providers/MessagesProvider.dart';
import 'package:style_app/providers/NewRecordProvider.dart';
import 'package:style_app/providers/OrderProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/RecordProvider.dart';
import 'package:style_app/providers/SearchFilterProvider.dart';
import 'package:style_app/providers/ServicesProvider.dart';
import 'package:style_app/providers/SettingProvider.dart';
import 'package:style_app/providers/SketchesFilterProvider.dart';
import 'package:style_app/providers/SketchesProvider.dart';
import 'package:style_app/ui/PreloaderScreen.dart';

void main() {
  runApp(MyApp());}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
  // FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  // FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingProvider>.value(value: SettingProvider()),
        ChangeNotifierProvider<ProfileProvider>.value(value: ProfileProvider()),
        ChangeNotifierProvider<ServicesProvider>.value(value: ServicesProvider()),
        ChangeNotifierProvider<NewRecordProvider>.value(value: NewRecordProvider()),
        ChangeNotifierProvider<ConversionProvider>.value(value: ConversionProvider()),
        ChangeNotifierProvider<SettingProvider>.value(value: SettingProvider()),
        ChangeNotifierProvider<OrdersProvider>.value(value: OrdersProvider()),
        ChangeNotifierProvider<SketchesProvider>.value(value: SketchesProvider()),
        ChangeNotifierProvider<CitiesProvider>.value(value: CitiesProvider()),
        ChangeNotifierProvider<SearchFilterProvider>.value(value: SearchFilterProvider()),
        ChangeNotifierProvider<MessagesProvider>.value(value: MessagesProvider()),
        ChangeNotifierProvider<SketchesFilterProvider>.value(value: SketchesFilterProvider()),
        ChangeNotifierProvider<OrderProvider>.value(value: OrderProvider())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: PreloaderScreen()
        // home: const AuthScreen()
//        const Main(),
      ),
    );
  }
}