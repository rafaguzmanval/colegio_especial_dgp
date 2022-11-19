
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';

import 'notificacion.dart';
import 'main.dart';
import 'package:flutter_background/flutter_background.dart';
import 'acceso_bd.dart';

class Background
{
  static var _ultimaTarea = "";
  static var _lengthTareas = 0;
  static var _subscripcion ;

static inicializarBackground() async
  {
  print("intentando hacer background");
    final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "flutter_background example app",
    notificationText: "Background notification for keeping the example app running in the background",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'),
    enableWifiLock: true,// Default is ic_launcher from folder mipmap
  );
  bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
    if(success)
    {
      print("Servicio de background activado");
      final backgroundExecution =
      await FlutterBackground.enableBackgroundExecution();
      if(backgroundExecution)
      {
          print("diselo");
      };

    }
  }

  static activarNotificacionesNuevasTareas() async
  {
    if(Sesion.id != "")
      {

        var ref = Sesion.db.db.collection("usuarioTieneTareas");

        _subscripcion = await ref.where("idUsuario", isEqualTo: Sesion.id).orderBy("fechainicio") // consulta todas las tareas de un usuario ordenadas por fecha de asignación
          .snapshots().listen((e) async {
              var idTarea = e.docs.last.get("idTarea"); // cada tarea tiene una id

              if(_lengthTareas < e.docs.length && _lengthTareas != 0)
                {
                  await Sesion.db.consultarIDTarea(idTarea).then((nuevaTarea) {

                      Sesion.argumentos.add(e.docs.length-1);
                      Notificacion.showBigTextNotification(title: "Nueva tarea", body: nuevaTarea.nombre, fln: notificaciones );

                    _ultimaTarea = nuevaTarea.nombre;

                  });
                }
              _lengthTareas = e.docs.length;

          });
      }
  }

  static desactivarNotificaciones()
  {
    if(_subscripcion != null)
    _subscripcion.cancel();
  }

}
