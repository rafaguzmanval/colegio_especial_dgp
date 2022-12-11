
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:geolocator/geolocator.dart';
import 'notificacion.dart';
import 'main.dart';
import 'package:flutter_background/flutter_background.dart';

class Background
{
  static var _subscripcion ;
  static  bool primera= false;
  static var _positionStream;
  static var _subscripcionChat;

static inicializarBackground() async
  {
    final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "TuCole",
    notificationText: "La aplicación se está ejecutando en segundo plano",
    notificationImportance: AndroidNotificationImportance.Default,
    enableWifiLock: true,// Default is ic_launcher from folder mipmap
  );
  bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
    if(success)
    {
      print("Servicio de background activado");
      await FlutterBackground.enableBackgroundExecution().then((value) {
        if(Sesion.rol == Rol.alumno.toString())
          {
            obtenerPosicion();
            Background.activarNotificacionesNuevasTareas();
          }

        else
          {
            Background.activarNotificacionesTareasTerminadas();
          }

        _activarNotificacionesChat();
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

  static _activarNotificacionesChat () async
  {
    _subscripcionChat = await Sesion.db.db
        .collection('mensajes')
        .where('idUsuarioReceptor',  isEqualTo: Sesion.id).orderBy("fechaEnvio")
        .snapshots().listen((event) async{
          

            var usuario = await Sesion.db.consultarIDusuario(event.docs.last.get("idUsuarioEmisor"));
            var contenido = "te ha enviado un mensaje";
            if(event.docs.last.get("tipo") == "texto")
             contenido = event.docs.last.get("contenido");
              else if(event.docs.last.get("tipo") == "imagen")
                {contenido = "te ha enviado una imagen";}
                else
                  {contenido = "te ha enviado un video";}
            
            Notificacion.showBigTextNotification(title: "${usuario.nombre}", body: "${contenido}", fln: notificaciones );
          

    });
  }


  static obtenerPosicion() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,

    );

    _positionStream = Geolocator.getPositionStream( locationSettings: locationSettings).listen(
            (Position? position) {
          if(position != null)
          {
            print("nueva pos");
            Sesion.db.cambiarPosicion(Sesion.id,position.latitude,position.longitude);
          }
        });

  }

  static desactivarNotificaciones()
  {
    if(_subscripcion != null)
    _subscripcion.cancel();

    if(_positionStream != null)
      _positionStream.cancel();

    if(_subscripcionChat != null)
      _subscripcionChat.cancel();


  }

}
