import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/location_controller/controller/location_controller.dart';
import 'package:luvpark/location_controller/controller/services/location_service.dart';

class LocationGetting extends StatefulWidget {
  const LocationGetting({super.key});

  @override
  State<LocationGetting> createState() => _LocationGettingState();
}

class _LocationGettingState extends State<LocationGetting> {
  final LocationController locationController =
      Get.put<LocationController>(LocationController());

  @override
  void initState() {
    LocationService.instance.getUserLocation(controller: locationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
      ),
      body: Center(
        child: Obx(() {
          return locationController.isAccessingLocation.value
              ? const Column(
                  children: [
                    CircularProgressIndicator(),
                    Text("Accessing Location")
                  ],
                )
              : locationController.errorDescription.value.isNotEmpty ||
                      locationController.userLocation.value == null
                  ? Column(
                      children: [
                        Text(locationController.errorDescription.value),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Latitude: ${locationController.userLocation.value?.latitude} ",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          "Longitude :  ${locationController.userLocation.value?.longitude} ",
                          style: Theme.of(context).textTheme.headlineSmall,
                        )
                      ],
                    );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          LocationService.instance
              .getUserLocation(controller: locationController);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
