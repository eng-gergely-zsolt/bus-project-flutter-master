import 'package:bus_project/screens/Shared/list.dart';
import 'package:bus_project/services/AppLocalizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BusesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    currentContext = context;
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('buses_title'))//Text("Incoming Buses"),
      ),
      body: Center(
          child: ListView.builder(
              itemCount: gArrivalTimeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                    leading: new CircleAvatar(
                        child:
                        new Text(gArrivalTimeList.elementAt(index).busID)),
                    title: Text(gArrivalTimeList.elementAt(index).toString()));
              })),
    );
  }
}
