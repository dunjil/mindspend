import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:mindspend/core/services/notification_service.dart';
import 'package:mindspend/core/navigation/main_navigation.dart';

class ProfileController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  final RxBool morningReminderEnabled = false.obs;
  final RxInt morningHour = 9.obs;
  final RxInt morningMinute = 0.obs;

  final RxBool eveningReminderEnabled = false.obs;
  final RxInt eveningHour = 20.obs;
  final RxInt eveningMinute = 0.obs;

  final RxBool remindersConfigured = false.obs;

  // Getters for UI compatibility
  TimeOfDay get morningTime =>
      TimeOfDay(hour: morningHour.value, minute: morningMinute.value);
  TimeOfDay get eveningTime =>
      TimeOfDay(hour: eveningHour.value, minute: eveningMinute.value);

  // Currency
  final RxString selectedCurrency = 'USD'.obs;
  final Map<String, String> currencies = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'NGN': '₦',
    'JPY': '¥',
    'INR': '₹',
  };

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  String get currencySymbol => currencies[selectedCurrency.value] ?? '\$';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Reminders
    morningReminderEnabled.value =
        prefs.getBool('morning_reminder_enabled') ?? false;
    morningHour.value = prefs.getInt('morning_hour') ?? 9;
    morningMinute.value = prefs.getInt('morning_minute') ?? 0;

    eveningReminderEnabled.value =
        prefs.getBool('evening_reminder_enabled') ?? false;
    eveningHour.value = prefs.getInt('evening_hour') ?? 20;
    eveningMinute.value = prefs.getInt('evening_minute') ?? 0;

    // Currency
    selectedCurrency.value = prefs.getString('selected_currency') ?? 'USD';

    remindersConfigured.value = prefs.getBool('reminders_configured') ?? false;

    // Update notification scheduling if enabled
    if (morningReminderEnabled.value) _scheduleMorning();
    if (eveningReminderEnabled.value) _scheduleEvening();
  }

  Future<void> updateCurrency(String currencyCode) async {
    selectedCurrency.value = currencyCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', currencyCode);
  }

  Future<void> toggleMorningReminder(bool value) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        Get.snackbar(
          'Notifications Required',
          'Please enable notification permissions to set daily reminders.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
        return;
      }
    }

    morningReminderEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morning_reminder_enabled', value);

    if (value) {
      await _scheduleMorning();
    } else {
      await _notificationService.cancelNotification(100);
    }
  }

  Future<void> updateMorningTime(TimeOfDay time) async {
    morningHour.value = time.hour;
    morningMinute.value = time.minute;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('morning_hour', time.hour);
    await prefs.setInt('morning_minute', time.minute);

    if (morningReminderEnabled.value) {
      await _scheduleMorning();
    }
  }

  Future<void> toggleEveningReminder(bool value) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        Get.snackbar(
          'Notifications Required',
          'Please enable notification permissions to set daily reminders.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
        return;
      }
    }

    eveningReminderEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('evening_reminder_enabled', value);

    if (value) {
      await _scheduleEvening();
    } else {
      await _notificationService.cancelNotification(101);
    }
  }

  Future<void> updateEveningTime(TimeOfDay time) async {
    eveningHour.value = time.hour;
    eveningMinute.value = time.minute;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('evening_hour', time.hour);
    await prefs.setInt('evening_minute', time.minute);

    if (eveningReminderEnabled.value) {
      await _scheduleEvening();
    }
  }

  Future<void> _scheduleMorning() async {
    await _notificationService.scheduleReminder(
      id: 100,
      title: 'Good Morning!',
      body: 'Time to log your morning mood and any expenses.',
      hour: morningHour.value,
      minute: morningMinute.value,
    );
  }

  Future<void> _scheduleEvening() async {
    await _notificationService.scheduleReminder(
      id: 101,
      title: 'Daily Wrap-up',
      body: 'Don\'t forget to log your expenses for today!',
      hour: eveningHour.value,
      minute: eveningMinute.value,
    );
  }

  Future<void> completeReminderSetup() async {
    remindersConfigured.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_configured', true);
    Get.offAll(() => const MainNavigation());
  }
}
