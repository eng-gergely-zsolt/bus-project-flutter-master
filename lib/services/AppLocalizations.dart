import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations{
  final Locale locale;
  Map<String,String> _LocalizedStrings;
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context){
    return Localizations.of<AppLocalizations>(context,AppLocalizations);
  }

  Future<bool> load() async{
    String jsonString = await rootBundle.loadString('lang/${locale.languageCode}.json');

    Map<String,dynamic> jsonMap = json.decode(jsonString);
    _LocalizedStrings = jsonMap.map((key,value){
      return MapEntry(key,value.toString());
    });
    return true;
  }

  String translate(String key){
    return _LocalizedStrings[key];
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations>{

  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // TODO: implement isSupported
    return ['en','hu','ro'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // TODO: implement load
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    // TODO: implement shouldReload
    return false;
  }

}