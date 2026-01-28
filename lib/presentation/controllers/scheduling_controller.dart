import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/notification_service.dart';

class SchedulingController extends GetxController {
  final GetStorage _storage = GetStorage();
  final RxList<Map<String, dynamic>> schedules = <Map<String, dynamic>>[].obs;
  
  static const String _keySchedules = 'prep_schedules';

  @override
  void onInit() {
    super.onInit();
    _loadSchedules();
  }

  void _loadSchedules() {
    final dynamic data = _storage.read(_keySchedules);
    if (data != null && data is List) {
      schedules.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
    }
  }

  Future<void> addSchedule(DateTime time, {String? title, String? body, String domain = "General Preparation"}) async {
    final String timestampId = DateTime.now().millisecondsSinceEpoch.toString();
    final Map<String, dynamic> newSchedule = {
      'id': timestampId,
      'time': time.toIso8601String(),
      'domain': domain,
      'title': title,
      'body': body,
      'isCompleted': false,
    };
    
    // Check for exact alarm permission (Android 12+)
    final notifService = Get.find<NotificationService>();
    final hasExactAlarmPermission = await notifService.isExactAlarmPermissionGranted();
    
    if (!hasExactAlarmPermission) {
      Get.snackbar(
        "Permission Required",
        "Please enable 'Alarms & Reminders' for HireCraft to send timely prep reminders.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        mainButton: TextButton(
          onPressed: () => notifService.requestPermissions(),
          child: const Text("SETTINGS"),
        ),
      );
      // We still save the schedule, but warn the user
    }
    
    schedules.add(newSchedule);
    await _storage.write(_keySchedules, schedules);
    
    // Schedule local notification
    final String idStr = timestampId;
    if (idStr.length >= 8) {
      final String subStr = idStr.substring(idStr.length - 8);
      final int? notifId = int.tryParse(subStr);
      
      if (notifId != null) {
        Get.find<NotificationService>().scheduleNotification(
          id: notifId,
          title: title ?? "Interview Prep Time!",
          body: body ?? "Time to practice your $domain interview questions.",
          scheduledDate: time,
        );
      }
    }
    
    Get.snackbar(
      "Schedule Set",
      "We'll remind you as requested!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
    );
  }

  Future<void> deleteSchedule(String id) async {
    schedules.removeWhere((s) => s['id'] == id);
    await _storage.write(_keySchedules, schedules);
    
    if (id.length >= 8) {
      final String subStr = id.substring(id.length - 8);
      final int? notifId = int.tryParse(subStr);
      if (notifId != null) {
        Get.find<NotificationService>().cancelNotification(notifId);
      }
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      final DateTime now = DateTime.now();
      final DateTime scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      // If time has passed today, schedule for tomorrow
      final DateTime finalTime = scheduledTime.isBefore(now) 
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime;
          
      _showCustomizationDialog(finalTime);
    }
  }

  void _showCustomizationDialog(DateTime time) {
    final titleController = TextEditingController(text: "Interview Prep Time!");
    final bodyController = TextEditingController(text: "Time to practice your interview questions.");
    final domainController = TextEditingController(text: "General Preparation");

    Get.dialog(
      AlertDialog(
        title: const Text("Customize Reminder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: domainController,
              decoration: const InputDecoration(labelText: "Domain (e.g. Flutter, Java)"),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Notification Title"),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: "Notification Message"),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              addSchedule(
                time,
                title: titleController.text,
                body: bodyController.text,
                domain: domainController.text,
              );
              Get.back();
            },
            child: const Text("Schedule"),
          ),
        ],
      ),
    );
  }
}
