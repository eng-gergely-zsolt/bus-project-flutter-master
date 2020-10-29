import 'package:background_fetch/background_fetch.dart';
import 'package:bus_project/screens/SettingsPage/geolocation.dart';
import 'package:bus_project/services/AppLocalizations.dart';
import 'package:bus_project/services/AppPropertiesBLoC.dart';
import 'package:flutter/material.dart';
import 'package:bus_project/screens/MapPage/map.dart';
import 'package:bus_project/screens/BusListPage/bus_list.dart';

import 'list.dart';

TabController tabController;
class Start extends StatefulWidget {
  @override
  NewBar createState() => new NewBar();
}

class NewBar extends State<Start> with SingleTickerProviderStateMixin {

  bool pEnabled = true;
  List<DateTime> _events = [];
  int pStatus = 0;

  //Future<Post> post;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    //DrivingDetector = ActivityRecognition();
    //GeoPosition = GPS();
    tabController = TabController(length: 3, vsync: this);
    //post = fetchPost('https://putsreq.com/Ys5rRZMUkZbBlazbTtLF');
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: false
    ), () async {
      // This is the fetch-event callback.
//      print('[BackgroundFetch] Event received');
      setState(() {
        _events.insert(0, new DateTime.now());
        gGeoPosition.sendPositionOnce();
      });
      // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish();
    }).then((int status) {
//      print('[BackgroundFetch] configure success: $status');
      setState(() {
        pStatus = status;
      });
    }).catchError((e) {
//      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        pStatus = e;
      });
    });
    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      pStatus = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: SafeArea(
          child: getTabBar(),
        ),
      ),
      body: getTabBarPages(),
      floatingActionButton: StreamBuilder<Object>(
          stream: appBloc.fabStream,
          initialData: "Main Dart",
          builder: (context, snapshot) {
            return Visibility(
              visible: gMyBusId == null ? false : true,
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    gMyBusId = null;
                    nextStation = null;
                    actualStation = null;
                    actualLine = null;
                    gDrivingDetector.pauseDrivingDetection();
                    BackgroundFetch.stop().then((int status) {
//                        print('[BackgroundFetch] stop success: $status');
                    });
                  });
                },
                label: Text(AppLocalizations.of(context).translate('fab_stop_journey')),//'End Journey'),
                icon: Icon(Icons.stop),
                backgroundColor: Colors.red,
              ),
            );
          }),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<Object>(
                stream: appBloc.titleStream,
                initialData: "Main Dart",
                builder: (context, snapshot) {
                  return gMyBusId == null
                      ? Text(AppLocalizations.of(context).translate('settings_select_bus'),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold
                    ),)//Text("Please select the bus you are traveling with:")
                      : Text(AppLocalizations.of(context).translate('settings_selected_bus')/*"Your bus is:"*/ + gMyBusId,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold
                    ),);
                }
            ),

          ],
        ),
      ),
    );
  }

  Widget getTabBar() {
    return TabBar(controller: tabController, tabs: [
      Tab(text: AppLocalizations.of(context).translate('menu_buses')),//Text('Station'),
      Tab(text: AppLocalizations.of(context).translate('menu_maps')),//Text('Maps'),
      Tab(text: AppLocalizations.of(context).translate('menu_settings')),//Text('Settings'),
    ]);
  }

  Widget getTabBarPages() {
    return TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          BusList1(),
          Map(),
          GeoListenPage(),
        ]);
  }
}
