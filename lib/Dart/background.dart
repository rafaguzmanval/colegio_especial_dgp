
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notificacion.dart';
import 'main.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Background
{
  static var _subscripcion ;
  static  bool primera= false;

static inicializarBackground() async
  {
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
      await FlutterBackground.enableBackgroundExecution().then((value) {
        if(Sesion.rol == Rol.alumno.toString())
          Background.activarNotificacionesNuevasTareas();
        else
          Background.activarNotificacionesTareasTerminadas();
      });



    }
  }

  static activarNotificacionesNuevasTareas() async
  {
    if(Sesion.id != "")
      {

        var ref = Sesion.db.db.collection("usuarioTieneTareas");

        _subscripcion = await ref.where("idUsuario", isEqualTo: Sesion.id).orderBy("fechainicio") // consulta todas las tareas de un usuario ordenadas por fecha de asignación
          .snapshots().listen((e) {

            if(e.docs.length > 0)
              {
                var idTarea = e.docs.last.get("idTarea"); // cada tarea tiene una id

                if(primera)
                {
                  e.docChanges.forEach((element) async {
                    if(element.type == DocumentChangeType.added)
                    {
                      await Sesion.db.consultarIDTarea(idTarea).then((nuevaTarea) {

                        Sesion.argumentos.add(e.docs.length-1);
                        Notificacion.showBigTextNotification(title: "Nueva tarea", body: nuevaTarea.nombre, fln: notificaciones );
                      });
                    }
                  });
                }

                primera = true;
              }

          });
      }
  }

  static activarNotificacionesTareasTerminadas() async
  {
    if(Sesion.id != "")
    {

      var ref = Sesion.db.db.collection("usuarioTieneTareas");

      _subscripcion = await ref.orderBy("fechaentrega") // consulta todas las tareas de un usuario ordenadas por fecha de asignación
          .snapshots().listen((e) async{


        var entrega = e.docs.last.get("fechaentrega");
        var diferencia = DateTime.fromMillisecondsSinceEpoch(
            entrega)
            .difference(DateTime.now());

        print(e.docChanges.last.type.toString());

        if(e.docs.length > 0 && e.docs.last.get("estado") == "completada" &&  e.docChanges.last.type == DocumentChangeType.modified)
        {

          var idUsuario = e.docs.last.get("idUsuario"); // cada tarea tiene una id
          var idTarea = e.docs.last.get("idTarea");

          try{
            await Sesion.db.consultarIDusuario(idUsuario).then((usuario) async{

              //Sesion.argumentos.add(e.docs.length-1);

              await Sesion.db.consultarIDTarea(idTarea).then((tarea) {

                print(usuario.nombre + " ha completado una tarea " + tarea.nombre);
                Notificacion.showBigTextNotification(title: "Tarea completada", body: usuario.nombre + " ha completado una tarea " + tarea.nombre, fln: notificaciones );

              });

              //if(!kIsWeb)

            });
          }
          catch(e){
            print(e);
          }


          //print(idUsuario.toString());

            /*e.docChanges.forEach((element) async {
              if(element.type == DocumentChangeType.added)
              {
                print(element.get("idUsuario").toString());
                /*
                await Sesion.db.consultarIDusuario(idUsuario).then((usuario) {

                  Sesion.argumentos.add(e.docs.length-1);
                  Notificacion.showBigTextNotification(title: "Tarea completada", body: usuario.nombre + " ha completado una tarea", fln: notificaciones );
                });*/
              }
            });*/

        }

      });
    }
  }

  static desactivarNotificaciones()
  {
    if(_subscripcion != null)
    _subscripcion.cancel();
  }

}
