import 'package:get/route_manager.dart';
import 'package:location/location.dart';
import 'package:luvpark/location_controller/controller/location_controller.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

class LocationService {
  LocationService.init();
  static LocationService instance = LocationService.init();

  final Location _location = Location();
  Future<bool> checkForServiceAvailability() async {
    bool isEnabled = await _location.serviceEnabled();
    if (isEnabled) {
      return Future.value(true);
    }

    isEnabled = await _location.requestService();

    if (isEnabled) {
      return Future.value(true);
    }

    return Future.value(false);
  }

  Future<bool> checkForPermission() async {
    PermissionStatus status = await _location.hasPermission();

    if (status == PermissionStatus.denied) {
      status = await _location.requestPermission();
      if (status == PermissionStatus.granted) {
        return true;
      }
      return false;
    }
    if (status == PermissionStatus.deniedForever) {
      Get.snackbar("Permission Needed",
          "We use permission to get your location in order to give your service",
          onTap: (snack) async {
        await handler.openAppSettings();
      }).show();
      return false;
    }

    return Future.value(true);
  }

  Future<void> getUserLocation({required LocationController controller}) async {
    controller.updateIsAccessingLocation(true);
    if (!(await checkForServiceAvailability())) {
      controller.errorDescription.value = "Service not enabled";
      controller.updateIsAccessingLocation(false);

      return;
    }
    if (!(await checkForPermission())) {
      controller.errorDescription.value = "Permission not given";
      controller.updateIsAccessingLocation(false);
      return;
    }

    final LocationData data = await _location.getLocation();
    controller.updateUserLocation(data);
    controller.updateIsAccessingLocation(false);
  }
}




// class _MyHomePageState extends State<MyHomePage> {
//   final LocationController locationController =
//       Get.put<LocationController>(LocationController());

//   @override
//   void initState() {
//     LocationService.instance.getUserLocation(controller: locationController);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Obx(() {
//           return locationController.isAccessingLocation.value
//               ? const Column(
//                   children: [
//                     CircularProgressIndicator(),
//                     Text("Accessing Location")
//                   ],
//                 )
//               : locationController.errorDescription.value.isNotEmpty ||
//                       locationController.userLocation.value == null
//                   ? Column(
//                       children: [
//                         Text(locationController.errorDescription.value),
//                       ],
//                     )
//                   : Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           "Latitude: ${locationController.userLocation.value?.latitude} ",
//                           style: Theme.of(context).textTheme.headlineSmall,
//                         ),
//                         Text(
//                           "Longitude :  ${locationController.userLocation.value?.longitude} ",
//                           style: Theme.of(context).textTheme.headlineSmall,
//                         )
//                       ],
//                     );
//         }),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           LocationService.instance
//               .getUserLocation(controller: locationController);
//         },
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
