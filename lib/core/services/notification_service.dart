import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
 
    const settings = InitializationSettings(android: android, iOS: ios);
 
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          print("Notification Payload: ${response.payload}");
        }
      },
    );
 
    // --- Request permissions explicitly ---
 
    // iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
 
    // Android 13+
    // Make sure you have permission_handler package added
 
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
 

  /// Generic notification
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();

    const details = NotificationDetails(android: android, iOS: ios);

    await _notifications.show(0, title, body, details);
  }

  /// Order success notification
  static Future<void> showOrderSuccessNotification(String orderId) async {
    const android = AndroidNotificationDetails(
      'order_channel', // id
      'Order Notifications', // title
      channelDescription: 'Notifications for order status',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const ios = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: android,
      iOS: ios,
    );

    await _notifications.show(
      1,
      'Order Successful!',
      'Your order has been placed successfully.',
      details,
      payload: orderId,
    );
  }
}
