import 'package:bus_project/services/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:bus_project/screens/Shared/start.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tutorials',
      supportedLocales: [
        Locale('en', 'US'),
        Locale('hu', 'HU'),
        Locale('ro', 'RO'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales){
        for(var supportedLocale in supportedLocales){
          if(supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode){
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: start(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text('BusApp'),
        centerTitle: true,
      ),
      body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: null),
    );
  }
}
