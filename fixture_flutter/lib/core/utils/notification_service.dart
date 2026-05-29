import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../../domain/entities/fixture_entities.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize timezones
    tz.initializeTimeZones();

    // 2. Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS settings
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false, // Requested dynamically in UI
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 4. Combine settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // 5. Initialize plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
    );
  }

  Future<void> requestPermissions() async {
    // Request for Android 13+
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // Request for iOS
    final iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> scheduleMatchNotification(Match match) async {
    try {
      // Parse match date and time (format: YYYY-MM-DD and HH:mm)
      final matchDateTimeString = '${match.date} ${match.localTime}';
      final DateFormat format = DateFormat('yyyy-MM-dd HH:mm');
      final DateTime matchDateTime = format.parse(matchDateTimeString);

      // Schedule for 15 minutes before the match
      final scheduledDateTime = matchDateTime.subtract(const Duration(minutes: 15));
      final now = DateTime.now();

      // Only schedule if the match is in the future
      if (scheduledDateTime.isAfter(now)) {
        final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'match_reminders_channel',
          'Recordatorios de Partidos',
          channelDescription: 'Canal para las alertas de inicio de los partidos del Mundial 2026',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

        const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        // Parse matchNumber to unique ID
        final notificationId = match.matchNumber;

        await _notificationsPlugin.zonedSchedule(
          notificationId,
          '⚽ ¡Partido por comenzar!',
          'El encuentro entre ${match.homeFlag} ${match.homeTeam} y ${match.awayFlag} ${match.awayTeam} inicia en 15 minutos en el ${match.stadium}.',
          tzScheduledTime,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );

        print('Notification scheduled for Match #${match.matchNumber} at $tzScheduledTime');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelMatchNotification(Match match) async {
    final notificationId = match.matchNumber;
    await _notificationsPlugin.cancel(notificationId);
    print('Notification cancelled for Match #${match.matchNumber}');
  }
}
