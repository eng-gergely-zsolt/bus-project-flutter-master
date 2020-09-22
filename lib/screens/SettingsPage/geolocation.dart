import 'package:bus_project/services/AppLocalizations.dart';
import 'package:bus_project/services/AppPropertiesBLoC.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:bus_project/screens/Shared/list.dart';
import 'package:bus_project/models/line.dart';
import 'buses.dart';
import 'package:background_fetch/background_fetch.dart';

class Settings {
  LocationAccuracy ac;
  String tm = '';
  String di = '';
  String sr = '';
}
//changed
class GeoListenPage extends StatefulWidget {
  @override
  _GeoListenPageState createState() => _GeoListenPageState();
}

class _GeoListenPageState extends State<GeoListenPage> {
  bool condition = false;
  Timer refresh;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Settings newSettings = new Settings();

  @override
  void initState() {
    super.initState();
    condition = false;
    Timer.periodic(Duration(seconds: 2), (Refresh) {
      if (condition) {
        Refresh.cancel();
      } else {
        setState(() {});
      }
    });
    gGeoPosition.getLocation();
  }

  void dispose() {
    condition = true;
    super.dispose();
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage(AppLocalizations.of(context).translate('settings_form_invalid_message'));//'Form is not valid!  Please review and correct.');
    } else {
      form.save(); //This invokes each onSaved event

      //print('Form save called, newSettings is now up to date...');
      //print('accuracy: ${newSettings.ac}');
      //print('distance: ${newSettings.di}');
      //print('timeInt: ${newSettings.tm}');

      setState(() {
        gGeoPosition.accuracy = newSettings.ac;
        gGeoPosition.timeInt = int.parse(newSettings.tm);
        gGeoPosition.distance = int.parse(newSettings.di);
        range = (int.parse(newSettings.sr) / 1000.toDouble());
        //state.didChange(newValue); ////////////
      });
    }
  }

  //Don't know what this is...
  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void _showDialog(String Title, String Message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(Title),
          content: new Text(Message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(AppLocalizations.of(context).translate('close')),//Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    /*
    var list = businfo_list.map((var value) {
      return new DropdownMenuItem<String>(
        value: value.BusId,
        child: new Text(value.BusId),
      );
    }).toList();
    list.add(new DropdownMenuItem<String>(
      value: 'Off',
      child: new Text(AppLocalizations.of(context).translate('off')),//Text('Off'),
    ));*/
    return /*Scaffold(
            body: Center(
                child:*/
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  gGeoPosition.userLocation == null
                      ? CircularProgressIndicator()
                      : Text(AppLocalizations.of(context).translate('settings_location')/*"Location:"*/ +
                      gGeoPosition.userLocation.latitude.toString() +
                      " " +
                      gGeoPosition.userLocation.longitude.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 20),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 38.0),
                    child: RaisedButton(
                      onPressed: () {
                        if (gArrivalTimeList != null &&
                            gArrivalTimeList.length > 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusesScreen(),
                            ),
                          );
                        } else {
                          _showDialog(
                              AppLocalizations.of(context).translate('settings_nostation')/*"No station nearby!"*/,
                              AppLocalizations.of(context).translate('settings_yesstation_1')+//"You need to be at most " +
                                  (range * 1000).toString() +
                                  AppLocalizations.of(context).translate('settings_yesstation_2'));//    " meters away from a station to check for buses.");
                        }
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.white10)),
                      color: Colors.white,
                      child: Text(
                        AppLocalizations.of(context).translate('settings_btn_showbus'),//"Show buses",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),
                      ),
                    ),
                  ),
                  new Padding(padding: EdgeInsets.only(top: 20)),
                  Text(gStationText,
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold
                    ),),
                  new Padding(padding: EdgeInsets.only(top: 15)),
                  gDrivingDetector.userActivity == null
                      ? CircularProgressIndicator()
                      : Text(
                    AppLocalizations.of(context).translate('settings_driving_score')+/*"Your phone is to*/" ${gDrivingDetector.userActivity.confidence}% ${gDrivingDetector.userActivity.type}! Driving Score= ${gDrivingDetector.DrivingScore}",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold
                    ),),
                  new Padding(padding: EdgeInsets.only(top: 15)),
                  /*new DropdownButton<String>(
                  value: MyBusId == null ? 'Off' : MyBusId,
                  items: list.reversed.toList(),
                  onChanged: (newVal) {
                    setState(() {
                      if (newVal == 'Off') {
                        MyBusId = null;
                        nextStation = null;
                        actualStation = null;
                        actualLine = null;
                        DrivingDetector.pauseDrivingDetection();
                        BackgroundFetch.stop().then((int status) {
                          print('[BackgroundFetch] stop success: $status');
                        });
                        appBloc.updateTitle();
                        appBloc.updateFab();
                      } else {
                        MyBusId = newVal;
                        BackgroundFetch.start().then((int status) {
                          print('[BackgroundFetch] start success: $status');
                        }).catchError((e) {
                          print('[BackgroundFetch] start FAILURE: $e');
                        });
                        actualLine = line_list.firstWhere((Line l) {
                          return l.LineID.toString() == newVal;
                        });
                        DrivingDetector.startDrivingDetection();
                        appBloc.updateTitle();
                        appBloc.updateFab();
                      }
                    });
                  },
                ),*/
                  Form(
                    key: _formKey,
                    autovalidate: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        DropdownButton<LocationAccuracy>(
                          value: gGeoPosition.accuracy,
                          style: new TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                              color: Colors.black
                          ),
                          items: [
                            DropdownMenuItem<LocationAccuracy>(
                                value: LocationAccuracy.bestForNavigation,
                                child: new Text(AppLocalizations.of(context).translate('settings_select_accuracy_best'))),//Text("Best accuracy")),
                            DropdownMenuItem<LocationAccuracy>(
                                value: LocationAccuracy.high,
                                child: new Text(AppLocalizations.of(context).translate('settings_select_accuracy_high'))),//Text("High accuracy")),
                            DropdownMenuItem<LocationAccuracy>(
                                value: LocationAccuracy.medium,
                                child: new Text(AppLocalizations.of(context).translate('settings_select_accuracy_med'))),//Text("Medium accuracy")),
                            DropdownMenuItem<LocationAccuracy>(
                                value: LocationAccuracy.low,
                                child: new Text(AppLocalizations.of(context).translate('settings_select_accuracy_low'))),//Text("Low accuracy")),
                            DropdownMenuItem<LocationAccuracy>(
                                value: LocationAccuracy.lowest,
                                child: new Text(AppLocalizations.of(context).translate('settings_select_accuracy_lowest'))),//Text("Lowest accuracy")),
                          ],
                          onChanged: (LocationAccuracy newValue) {
                            //print("Changed");
                            setState(() {
                              //print(newValue.toString());
                              newSettings.ac = newValue;
                              gGeoPosition.accuracy = newValue;
                            });
                          },
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20)),
                        TextFormField(
                          decoration: new InputDecoration(
                            labelText: AppLocalizations.of(context).translate('settings_tff_interval'),
                            labelStyle: TextStyle(
                                color: Colors.blue
                            ),
                            fillColor: Colors.blue,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(),
                            ),
                            enabledBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: BorderSide(color: Colors.blue, width: 0.5)
                            ),
                          ),//"Interval in seconds"),
                          //controller: IntervalController,
                          keyboardType: TextInputType.number,
                          initialValue: gGeoPosition.timeInt.toString(),
                          validator: (value) {
                            if (value.isEmpty) {
                              return AppLocalizations.of(context).translate('settings_from_empty');//'If you want to save the settings you must provide information.';
                            }
                            return null;
                          },
                          onSaved: (val) => newSettings.tm = val,
                          style: new TextStyle(
                            fontFamily: "Poppins",
                          ),
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20)),
                        TextFormField(
                          decoration: new InputDecoration(
                            labelText: AppLocalizations.of(context).translate('settings_tff_distance'),
                            labelStyle: TextStyle(
                                color: Colors.blue
                            ),
                            fillColor: Colors.blue,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(),
                            ),
                            enabledBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: BorderSide(color: Colors.blue, width: 0.5)
                            ),
                          ),//"Distance in meters"),
                          //controller: DistanceController,
                          keyboardType: TextInputType.number,
                          cursorColor: Colors.blue,
                          initialValue: gGeoPosition.distance.toString(),
                          validator: (value) {
                            if (value.isEmpty) {
                              return AppLocalizations.of(context).translate('settings_from_empty');//'If you want to save the settings you must provide information.';
                            }
                            return null;
                          },
                          onSaved: (val) => newSettings.di = val,
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20)),
                        TextFormField(
                          decoration: new InputDecoration(
                            labelText: AppLocalizations.of(context).translate('settings_tff_stationrange'),
                            labelStyle: TextStyle(
                                color: Colors.blue
                            ),
                            fillColor: Colors.blue,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(40.0),
                              borderSide: new BorderSide(),
                            ),
                            enabledBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: BorderSide(color: Colors.blue, width: 0.5)
                            ),
                          ),//"Station detection distance in meters"),
                          //controller: DistanceController,
                          keyboardType: TextInputType.number,
                          initialValue: (range * 1000).toString(),
                          validator: (value) {
                            if (value.isEmpty) {
                              return AppLocalizations.of(context).translate('settings_from_empty');//'If you want to save the settings you must provide information.';
                            }
                            return null;
                          },
                          onSaved: (val) => newSettings.sr = val,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.white)),
                            color: Colors.blue,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(8.0),
                            onPressed: _submitForm,
                            /*() {
                        // Validate returns true if the form is valid, or false
                        // otherwise.
                          if (_formKey.currentState.validate()) {
                            //distance=DistanceController.text as int;
                            //timeInt=IntervalController.text as int;
                          }
                        },*/
                            child: Text(AppLocalizations.of(context).translate('settings_from_save').toUpperCase(),
                              style: TextStyle(fontStyle: FontStyle.italic),),//Text('Save Settings'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    /*),
        );*/
  }
}
