import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/voice_search/controller.dart';

class VoiceSearchPopup extends StatelessWidget {
  const VoiceSearchPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VoiceSearchController>(
      init: VoiceSearchController(),
      
      builder: (controller) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Center(child: Text("Voice Search")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mic,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                "Listening...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Obx(
                () => Text(
                  controller.searchText.value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
