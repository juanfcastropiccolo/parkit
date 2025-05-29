import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'parkit_channel';
  static const String _channelName = 'Parkit Notifications';
  static const String _channelDescription = 'Notificaciones de la app Parkit';

  Future<void> initialize() async {
    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificaciones para Android
    if (!kIsWeb) {
      await _createNotificationChannel();
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
      // Aquí puedes manejar la navegación o acciones específicas
      _handleNotificationAction(payload);
    }
  }

  void _handleNotificationAction(String payload) {
    // Analizar el payload y realizar acciones
    switch (payload) {
      case 'confirmar_lugar_libre':
        // Navegar a la pantalla de confirmación o ejecutar lógica
        break;
      case 'ver_lugares_cercanos':
        // Navegar al mapa con lugares cercanos
        break;
      default:
        break;
    }
  }

  // Solicitar permisos de notificación
  Future<bool> requestPermissions() async {
    bool? result = true;
    
    if (!kIsWeb) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      
      result = grantedNotificationPermission ?? true;
    }

    return result;
  }

  // Mostrar notificación básica
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Parkit',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Notificación específica para preguntar si dejó el lugar
  Future<void> showMovementDetectedNotification() async {
    await showNotification(
      id: 1,
      title: '¿Dejaste el estacionamiento?',
      body: 'Detectamos movimiento. Pulsa para confirmar si liberaste el lugar.',
      payload: 'confirmar_lugar_libre',
    );
  }

  // Notificación de lugar compartido exitosamente
  Future<void> showLugarCompartidoNotification() async {
    await showNotification(
      id: 2,
      title: 'Lugar compartido',
      body: 'Tu lugar de estacionamiento fue registrado exitosamente.',
    );
  }

  // Notificación de lugar libre confirmado
  Future<void> showLugarLiberadoNotification() async {
    await showNotification(
      id: 3,
      title: 'Lugar liberado',
      body: 'Tu lugar está ahora disponible para otros conductores.',
    );
  }

  // Notificación de lugares cercanos disponibles
  Future<void> showLugaresCercanosNotification(int cantidad) async {
    await showNotification(
      id: 4,
      title: 'Lugares disponibles cerca',
      body: 'Hay $cantidad lugares de estacionamiento disponibles cerca de ti.',
      payload: 'ver_lugares_cercanos',
    );
  }

  // Cancelar notificación específica
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Programar notificación para más tarde
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.schedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      payload: payload,
    );
  }
} 