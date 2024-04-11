import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AndroidBackgroundProcess {
  // ignore: avoid_init_to_null
  static StreamSubscription<int>? timerSubscription;
  static int counter = 0;
  static Future<void> isRunBackground(bool isRunBP) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_running", isRunBP);
  }

  // @pragma('vm:entry-point')
  // static initilizeBackgroundService() async {
  //   int counter = 0;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var akongId = prefs.getString('myId');
  //   bool? isRunBP = prefs.getBool("is_running");

  //   timerBp = Timer.periodic(Duration(seconds: 5), (timer) async {
  //     counter++;

  //     print("sulod sa ti ");
  //     // if (akongId != null) {
  //     //   await getParkingTrans(counter);
  //     //   await getSharingData(akongId, counter);
  //     //   await updateShareLocation(akongId);
  //     //   await getMessNotif();
  //     // }
  //   });
  //   if (isRunBP!) {
  //     print("timerBp active ${timerBp!.isActive}");
  //   } else {
  //     timerBp!.cancel();
  //     print("else isRunBP ${timerBp!}");
  //     return;
  //   }
  // }

  static backgroundExecution() {
    const int helloAlarmID = 0;
    print("sulod sa take me to background");
    AndroidAlarmManager.cancel(0);
    AndroidAlarmManager.periodic(
      const Duration(seconds: 1),
      helloAlarmID,
      initilizeBackgroundService,
      startAt: DateTime.now(),
      exact: true,
      wakeup: true,
    );
  }

  @pragma('vm:entry-point')
  static void initilizeBackgroundService() async {
    Stream<int> timerStream = Stream.periodic(Duration(seconds: 3), (x) => x);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongId = prefs.getString('myId');

    if (timerSubscription != null) {
      timerSubscription!.cancel();
      timerSubscription = null;
      AndroidAlarmManager.cancel(0);

      backgroundExecution();
      print("is active Stopped");
      return;
    }
    if (akongId != null) {
      timerSubscription = timerStream.listen((event) async {
        await getParkingTrans(counter);
        await getSharingData(akongId, counter);
        await updateLocation();
        //   await getParkingQueue();
        await getMessNotif();
      });
    }
  }
}

// class AndroidBackgroundProcess {
//   static late Timer? timerBp; // Declare timerBp as a static variable
//   static Future<void> isRunBackground(isRunBP) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool("is_running", isRunBP);
//   }

//   // @pragma('vm:entry-point')
//   static void initilizeBackgroundService() async {
//     int counter = 0;

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var akongId = prefs.getString('myId');
//     bool? isRunBP = prefs.getBool("is_running");

//     if (isRunBP!) {
//       timerBp = Timer.periodic(Duration(seconds: 5), (timer) async {
//         counter++;

//         print("if timerBp $timerBp");
//         if (akongId != null) {
//           await getParkingTrans(counter);
//           await getSharingData(akongId, counter);
//           await updateShareLocation(akongId);
//           //   await getParkingQueue();
//           await getMessNotif();
//         }
//       });
//       timerBp!.tick;
//     } else {
//       print("else timerBp $timerBp");
//       //   print("is active timer ${timerBp!.isActive}");
//       print("else isRunBP $isRunBP");
//     }
//   }

//   static Future<void> backgroundExecution() async {
//     await AndroidAlarmManager.initialize();
//     const int helloAlarmID = 0;
//     print("sulod sa take me to background");
//     await AndroidAlarmManager.periodic(
//       const Duration(seconds: 5),
//       helloAlarmID,
//       initilizeBackgroundService,
//       startAt: DateTime.now(),
//     );
//   }

//   static Future<void> cancelBackgroundExec() async {
//     AndroidAlarmManager.cancel(0);
//   }
// }
