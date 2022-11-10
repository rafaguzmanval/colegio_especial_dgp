/*
*   Archivo: notificacion.dart
*
*   Descripción: 
*   Clase que contiene los métodos para que aparezcan notificaciones en los dispositivos. 
*   
*   Includes:
*   flutter_local_notifications.dart : Se utiliza para inicializar notificaciones.
* */

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notificacion{
  // Constructor
  static Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = new AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = new DarwinInitializationSettings();
    var initializationsSettings = new InitializationSettings(android: androidInitialize,
        iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);



  }
  // Metodo para mostrar la notificación de textp
  static Future showBigTextNotification({var id =0,required String title, required String body,
    var payload, required FlutterLocalNotificationsPlugin fln
  } ) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    new AndroidNotificationDetails(
      '1',
      'canal1',

      playSound: true,
      sound: RawResourceAndroidNotificationSound('cancion'),
      importance: Importance.max,
      priority: Priority.high,
    );

    var not= NotificationDetails(android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails()
    );
    await fln.show(0, title, body,not );
  }
}
