import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi plugin
  Future<void> initialize() async {
    // Pengaturan untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Gunakan ikon default app

    // Pengaturan untuk iOS (meminta izin)
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification: (id, title, body, payload) async {
            // Handle notifikasi saat app terbuka di iOS versi lama
          },
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle saat notifikasi di-tap
        // (Contoh: Buka aplikasi)
      },
    );

    // Minta izin notifikasi di Android 13+
    // await _flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //       AndroidFlutterLocalNotificationsPlugin
    //     >()
    //     ?.requestNotificationsPermission();
  }

  // Menampilkan notifikasi
  Future<void> showNotification(int id, String title, String body) async {
    // Detail channel notifikasi Android
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'titik_kondisi_channel', // ID Channel
          'Notifikasi Cuaca', // Nama Channel
          channelDescription: 'Channel untuk notifikasi cuaca dan astronomi',
          importance:
              Importance.defaultImportance, // Ubah ke high jika ingin heads-up
          priority: Priority.defaultPriority,
          ticker: 'ticker',
        );

    // Detail notifikasi iOS
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    // Tampilkan notifikasi
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: 'item x', // Opsional: data yang dikirim saat di-tap
    );
  }
}
