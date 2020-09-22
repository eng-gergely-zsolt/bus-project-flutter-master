import 'dart:async';
import 'package:activity_recognition_alt/activity_recognition_alt.dart';
import 'package:sensors/sensors.dart';

class ActivityRecognition {
  static final ActivityRecognition _instance = ActivityRecognition._internal();

  factory ActivityRecognition() => _instance;
  Activity userActivity;
  Stream<Activity> active;
  StreamSubscription activeSubscription;
  List<double> accelerometerValues;
  List<double> gyroscopeValues;
  List<double> userAccelerometerValues;
  List<StreamSubscription> streamSubscriptions;
  int DrivingScore = 0;
  Timer DrivingCheck;
  bool isStarted = false;

  ActivityRecognition._internal() {
//    print("CREATE DRIVING DETECTION");
    if (active == null) {
      active = ActivityRecognitionAlt.activityUpdates();
    }
    if (streamSubscriptions == null) {
      streamSubscriptions = List<StreamSubscription>();
    }
  }

  void dispose() {
//    print("DESTROY DRIVING DETECTION");
    activeSubscription.cancel();
    streamSubscriptions.forEach((StreamSubscription s) {
      s.cancel();
    });
    DrivingCheck.cancel();
  }

  void startDrivingDetection() {
//    print("START DRIVING DETECTION");
    isStarted = true;
    if (active != null) {
      if (activeSubscription != null) {
        if (activeSubscription.isPaused) {
          activeSubscription.resume();
        }
      } else {
        activeSubscription = active.listen((action) {
          userActivity = action;
//          print("Your phone is to ${action.confidence}% ${action.type}!");
          /*
            "IN_VEHICLE""ON_BICYCLE""ON_FOOT""RUNNING""STILL""TILTING""UNKNOWN" "WALKING""UNDEFINED"*/
          if (action.type == "IN_VEHICLE") DrivingScore = 100;
          if (action.type == "ON_BICYCLE") DrivingScore = 0;
          if (action.type == "ON_FOOT") DrivingScore = 0;
          if (action.type == "RUNNING") DrivingScore = 0;
          if (action.type == "WALKING") DrivingScore = 0;
        });
      }
    }

    Timer.periodic(Duration(seconds: 2), (DrivingTimer) {  //Something is fishy with this
      DrivingCheck =DrivingTimer;
      if (userActivity.type == "STILL" && DrivingScore > 0) DrivingScore -= 1;
      if (userActivity.type == "TILTING" && DrivingScore > 0) DrivingScore -= 1;
      if (userActivity.type == "UNDEFINED" && DrivingScore > 0)
        DrivingScore -= 1;
    });

    if (streamSubscriptions.length < 3) {
      streamSubscriptions
          .add(accelerometerEvents.listen((AccelerometerEvent event) {
        accelerometerValues = <double>[event.x, event.y, event.z];
        //print("ACCELEROMETER: x="+event.x.toString()+" y="+event.y.toString()+" z="+event.z.toString());
      }));
      streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
        gyroscopeValues = <double>[event.x, event.y, event.z];
        //print("GYROSCOPE: x="+event.x.toString()+" y="+event.y.toString()+" z="+event.z.toString());
      }));
      streamSubscriptions
          .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
        userAccelerometerValues = <double>[event.x, event.y, event.z];
        //print("USER ACCELEROMETER: x="+event.x.toString()+" y="+event.y.toString()+" z="+event.z.toString());
      }));
    }
  }

  void pauseDrivingDetection() {
    isStarted = false;
//    print("PAUSE DRIVING DETECTION");
    DrivingCheck.cancel();
    activeSubscription.pause();
  }
}