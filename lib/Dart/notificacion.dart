/*
*   Archivo: notificacion.dart
*
*   Descripción: 
*   Clase que contiene los métodos para que aparezcan notificaciones en los dispositivos. 
*   
*   Includes:
*   flutter_local_notifications.dart : Se utiliza para inicializar notificaciones.
* */

import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/ver_tareas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notificacion {
  // Constructor
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String rol) async {
    var androidInitialize =
        new AndroidInitializationSettings('app_icon');
    var iOSInitialize = new DarwinInitializationSettings();
    var initializationsSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onDidReceiveNotificationResponse: (notificationResponse) async{

      if(rol == Rol.alumno.toString())
        {
          redireccionAlumno();
        }
      else
        {
          redireccionProfesor();
        }

      }
    );
  }

  //Se va a quedar sin implementar
  static redireccionProfesor() async
  {
    if(Sesion.paginaActual.toString().startsWith("MyHomePageState"))
    {
    }
    else if(Sesion.paginaActual.toString().startsWith("VerTareasState"))
    {
    }
    else
    {
    }
  }

  //Redirige la aplicación cuando tiene el perfil de un alumno hacia la última tarea añadida
  static redireccionAlumno() async
  {
    if(Sesion.paginaActual.toString().startsWith("MyHomePageState"))
    {
      var paginaAnterior = Sesion.paginaActual;
      await Navigator.push(Sesion.paginaActual.context, MaterialPageRoute(
          builder: (context) => VerTareas()));
      Sesion.paginaActual = paginaAnterior;
    }
    else if(Sesion.paginaActual.toString().startsWith("VerTareasState"))
    {
      Sesion.paginaActual.enfocarTarea();
      Sesion.paginaActual.actualizar();
    }
    else
    {
      //Navigator.popUntil(Sesion.paginaActual.context, ModalRoute.withName("/home"));
      Navigator.pop(Sesion.paginaActual.context);
    }
  }

  // Metodo para mostrar la notificación de textp
  static Future showBigTextNotification(
      {var id = 0,
      required String title,
      required String body,
      var payload,
      required FlutterLocalNotificationsPlugin fln}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        new AndroidNotificationDetails(
      '1',
      'canal1',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('cancion'),
      importance: Importance.max,
      priority: Priority.high,

    );


    var not = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());
    await fln.show(0, title, body, not);



  }
}
