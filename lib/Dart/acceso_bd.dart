/*
*   Archivo: acceso_bd.dart
*
*   Descripción:
*   Realiza la comunicación con la base de datos del firebase y de storage de firebase. Fundamentalmente se accede a la información de los usuarios
*   y de las tareas. 
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   passport_method.dart : Contiene el enum que indica el tipo de contraseña que va a usarse (clave, pin,...)
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   tarea.dart : Contiene los métodos para convertir la información de la base de datos al objeto del modelo. 
*   usuario.dart : Contiene los métodos para convertir la información de la base de datos al objeto del modelo. 
*   firebase_storage.dart : Contiene los métodos para acceder al almacenamiento de archivos del servidor. 
*   crypto.dart : Contiene los métodos para realizar encriptación en Sha256 de los datos.
*   video_player.dart : Necesario para cargar los videos del storage y cargarlos en el controlador de los reproductores de video. 
* */

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/tablon.dart';
import 'package:colegio_especial_dgp/Dart/tarea.dart';

import 'package:colegio_especial_dgp/Dart/usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';
import 'notificacion.dart';

String encriptacionSha256(String password) {
  var data = utf8.encode(password);
  var hashvalue = sha256.convert(data);

  return hashvalue.toString();
}



class AccesoBD {
  var db = FirebaseFirestore.instance;
  var storageRef = FirebaseStorage.instance.ref();

  var fotoDesconocido =
      "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fperfiles%2Fdesconocido.png?alt=media&token=98ba72ac-776e-4f83-9aaa-57761589c974";

  // Metodo para registrar usuario
  registrarUsuario(usuario, foto) async {
    try {

      //Se encripta la contaseña
      var nuevaPassword = encriptacionSha256(usuario.password);
      var nombrehaseao =
          encriptacionSha256(usuario.apellidos + usuario.fechanacimiento);

      var fotoPath = null;
      if (foto != null) {
        fotoPath =
            "Imágenes/perfiles/${usuario.nombre + usuario.apellidos + nombrehaseao}";

        return await storageRef.child(fotoPath).putFile(foto).then((p0) async {
          var fotoURL = await leerImagen(fotoPath);

          var user = <String, dynamic>{
            "nombre": usuario.nombre,
            "apellidos": usuario.apellidos,
            "password": nuevaPassword,
            "fechanacimiento": usuario.fechanacimiento,
            "rol": usuario.rol,
            "foto": fotoURL,
            "metodoLogeo": usuario.metodoLogeo
          };
          db.collection("usuarios").add(user);

          return true;
        });
      } else {
        var user = <String, dynamic>{
          "nombre": usuario.nombre,
          "apellidos": usuario.apellidos,
          "password": nuevaPassword,
          "fechanacimiento": usuario.fechanacimiento,
          "rol": usuario.rol,
          "foto": fotoDesconocido,
          "metodoLogeo": usuario.metodoLogeo
        };
        db.collection("usuarios").add(user);

        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Metodo para crear una tarea
  crearTarea(tarea) async {
    try {
      //Se encripta la contaseña

      var imagenes = [];
      var videos = [];

      var futuros = <Future>[];

      int i = 0;

      if (tarea.imagenes.length > 0) {


        if(tarea.imagenes[0] is String)
          {
            if(tarea.imagenes[0].startsWith("http"))
              {
                imagenes.add(tarea.imagenes[0]);
                i++;
              }
          }
        else
          {
            var fotoPath = "Imágenes/pictogramas/" +
                encriptacionSha256(tarea.imagenes[0].path);

            //se introduce la imágen dentro del storage y cuando se comrpueba que se ha cargado entronces se incrementa 'i' para que se pueda salir del bucle de espera
            await storageRef
                .child(fotoPath)
                .putFile(tarea.imagenes[0])
                .then((d0) async {
                      await leerImagen(fotoPath).then((value) {
                        log(value);
                        imagenes.add(value);
                        log("Se añadio la imagen al array");
                        i++;
                      });
                      log("Se leido lo de await leerImagen");
                    });
          }

      }

      if (tarea.videos.length > 0) {
        var videoPath = "Vídeos/" + encriptacionSha256(tarea.videos[0].path);

        // se espera a que se introduzca el video correctamente en el storage para después salir del bucle de espera
        await storageRef
            .child(videoPath)
            .putFile(tarea.videos[0])
            .then((p0) async {
          await leerVideo(videoPath).then((value) {
            videos.add(value);
            i++;
          });
        });
      }

      //bucle de espera  para que las imágenes y los vídeos estén cargados
      while (i != tarea.imagenes.length + tarea.videos.length) {}
      ;

      //Cuando se han cargado todas las imágenes y vídeos entonces se sube a la base de datos
      //la nueva tarea con todas las urls de las imágenes y vídeos

      log("Todos los futures se han completado");

      var nuevaTarea = <String, dynamic>{
        "nombre": tarea.nombre,
        "textos": tarea.textos,
        "imagenes": imagenes,
        "videos": videos,
        "formularios":tarea.formularios,
        "orden": tarea.orden
      };

      db.collection("Tareas").add(nuevaTarea);

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Metodo al que le pasas por parametro la id del usuario, comprueba si existe y te devuelve el objeto usuario
  consultarIDusuario(id) async {
    try {
      final ref = db.collection("usuarios");

      final consulta = ref.doc(id).withConverter(
          fromFirestore: Usuario.fromFirestore,
          toFirestore: (Usuario user, _) => user.toFirestore());

      final docSnap = await consulta.get();

      var usuario = null;
      if (docSnap != null) {
        usuario = docSnap.data();
        usuario?.id = docSnap.id;
      }

      return usuario;
    } catch (e) {
      print(e);
    }
  }

  // Metodo para consultar las tareas asignadas a un usuario según el id pasado por parametro y te devuelve las tareas que tiene insertandolas en la
  // sesion
  @deprecated
  consultarTareasAsignadasAlumno(id, cargarVideos) async {
    try {

      //Se accede a la relación de las tareas de un usuario
      final ref = db.collection("usuarioTieneTareas");


      await ref.where("idUsuario", isEqualTo: id).orderBy("fechainicio") // consulta todas las tareas de un usuario ordenadas por fecha de asignación
        ..snapshots().listen((e) async {      //Escucha los cambios en el servidor
          var nuevasTareas = [];
          for (int i = 0; i < e.docs.length; i++) { // itera sobre los elementos de la colección
            var idTarea = e.docs[i].get("idTarea"); // cada tarea tiene una id

            await consultarIDTarea(idTarea).then((nuevaTarea) {  // sobre esa id accedemos a la colección tarea donde se encuentra la información de la tarea
              nuevaTarea.idRelacion = e.docs[i].id;
              nuevaTarea.estado = e.docs[i].get("estado");
              nuevaTarea.fechafinal = e.docs[i].get("fechafinal");
              nuevaTarea.respuesta = e.docs[i].get("respuesta");
              nuevaTarea.retroalimentacion = e.docs[i].get("retroalimentacion");

              if(nuevaTarea.estado != "sinFinalizar")
                {
                  nuevaTarea.fechaentrega =  (DateTime.now().millisecondsSinceEpoch - e.docs[i].get("fechaentrega"))/(1000*60);

                  if(nuevaTarea.formularios != []) // si en la tarea no se han actualizado los datos del formulario entonces debemos sobreescribir
                    //el que viene por defecto
                  nuevaTarea.formularios = e.docs[i].get("formularios");

                }
              nuevasTareas.add(nuevaTarea);

              if (nuevasTareas.length == e.docs.length) {
                Sesion.tareas = nuevasTareas;
                if (cargarVideos) {
                  try {
                    for (int k = 0; k < Sesion.tareas.length; k++) {
                      for (int j = 0; j < Sesion.tareas[k].videos.length; j++) {
                            var nuevoControlador = VideoPlayerController.network(
                                Sesion.tareas[k].videos[j]);
                            Sesion.tareas[k].controladoresVideo
                                .add(nuevoControlador);
                            Sesion.tareas[k].controladoresVideo.last.initialize();
                      }

                      //Se cargan los formularios (Mas feo esto que pegarle a un pae la verdad)
                      if(Sesion.tareas[k].formularios != [])
                      {
                        for (int l = 0; l < Sesion.tareas[k].formularios.length;
                        l = l + 2 + (Sesion.tareas[k].formularios[l + 1] as int) * 3) {

                          for(int j = 0 ; j < (Sesion.tareas[k].formularios[l + 1] as int)  ; j++)
                          {
                            Sesion.tareas[k].controladoresComandas.add(TextEditingController());
                          }

                        }
                      }

                    }

                    Sesion.paginaActual.actualizar();

                  } catch (e) {
                    print(e);
                  }
                  ;
                }
                Sesion.paginaActual.actualizar();
                return;
              }
            });
          }

          if (e.docs.length == 0) Sesion.tareas = [];

        });
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Metodo para añadir una tarea con el id de tarea a un usuario en especifico con id de usuario
  addTareaAlumno(idUsuario, idTarea,fechafinal) async {
    try {

      var tar = <String, dynamic>{
        "idUsuario": idUsuario,
        "idTarea": idTarea,
        "fechainicio": DateTime.now().millisecondsSinceEpoch,
        "fechafinal" : fechafinal,
        "estado" : "sinFinalizar",
        "fechaentrega" : 0,
        "respuesta":"",
        "retroalimentacion":"",
        "formularios":[]

      };

      await db.collection("usuarioTieneTareas").add(tar).then((value) { return true;});

    } catch (e) {
      print(e);
      return false;
    }
  }

  completarTarea(idTareaAsignada) async
  {
    try
    {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({"estado" : "completada", "fechaentrega" : DateTime.now().millisecondsSinceEpoch});

    }catch(e){
      log(e.toString());
      return false;
    }

  }


  fallarTarea(idTareaAsignada) async
  {
    try
    {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({"estado" : "cancelada", "fechaentrega" : DateTime.now().millisecondsSinceEpoch});

    }catch(e){
      log(e.toString());
      return false;
    }

  }

  addRespuestaTarea(idTareaAsignada,comentario) async
  {
    try
    {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({"respuesta" : comentario});

    }catch(e){
      log(e.toString());
      return false;
    }

  }

  addFeedbackTarea(idTareaAsignada,retroalimentacion) async
  {
    try
    {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({"retroalimentacion" : retroalimentacion});

    }catch(e){
      log(e.toString());
      return false;
    }

  }

  // Metodo para eliminar una tarea de un usuario pasandole el id de la relacion entre el usuario y la tarea
  Future eliminarTareaAlumno(id) async {
    try {
      if (Sesion.tareas != null && Sesion.tareas != []) {
        await db
            .collection("usuarioTieneTareas")
            .doc(id)
            .delete();
        return true;
      }
    } catch (e) {
      return false;
      print(e);
    }
  }

  // Metodo que te devuelve todos los usuarios de la base de datos
  consultarTodosUsuarios() async {
    try {
      var usuarios = [];

      final ref = db.collection("usuarios").withConverter(
          fromFirestore: Usuario.fromFirestore,
          toFirestore: (Usuario user, _) => user.toFirestore());

      final consulta = await ref.get();

      consulta.docs.forEach((element) {
        final usuarioNuevo = element.data();
        usuarioNuevo.id = element.id;
        usuarios.add(usuarioNuevo);
      });

      return usuarios;
    } catch (e) {
      print(e);
    }
  }

  // Metodos que te devuelve todos los alumnos de la base de datos
  consultarTodosAlumnos() async {
    try {
      var usuarios = [];

      final ref = db.collection("usuarios").withConverter(
          fromFirestore: Usuario.fromFirestore,
          toFirestore: (Usuario user, _) => user.toFirestore());

      final consulta = await ref.where("rol", isEqualTo: "Rol.alumno").get();

      consulta.docs.forEach((element) {
        final usuarioNuevo = element.data();
        usuarioNuevo.id = element.id;
        usuarios.add(usuarioNuevo);
      });

      return usuarios;
    } catch (e) {
      print(e);
    }
  }

  // Metodo que te devuelve todos los profesores de la base de datos
  consultarTodosProfesores() async {
    try {
      var usuarios = [];

      final ref = db.collection("usuarios").withConverter(
          fromFirestore: Usuario.fromFirestore,
          toFirestore: (Usuario user, _) => user.toFirestore());

      final consulta = await ref.where("rol", isNotEqualTo: "Rol.alumno").get();

      consulta.docs.forEach((element) {
        final usuarioNuevo = element.data();
        usuarioNuevo.id = element.id;
        usuarios.add(usuarioNuevo);
      });

      return usuarios;
    } catch (e) {
      print(e);
    }
  }

  // Metodo que te devuelve todas las tareas del usuario
  consultarTodasLasTareas() async {
    try {
      final ref = db.collection("Tareas").withConverter(
          fromFirestore: Tarea.fromFirestore,
          toFirestore: (Tarea tarea, _) => tarea.toFirestore());

      final consulta = await ref.get();

      var lista = [];

      consulta.docs.forEach((element) {
        var nuevaTarea = element.data();
        nuevaTarea.id = element.id;
        lista.add(nuevaTarea);
      });

      return lista;
    } catch (e) {
      print(e);
    }
  }

  updateComanda(idTareaAsignada,formulario) async
  {
    try
    {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({"formularios" : formulario});

    }catch(e){
      log(e.toString());
      return false;
    }
  }

  // Metodo que te devuelve la tarea segun el id de esta
  consultarIDTarea(id) async {
    try {
      final ref = db.collection("Tareas");

      final consulta = ref.doc(id).withConverter(
          fromFirestore: Tarea.fromFirestore,
          toFirestore: (Tarea tarea, _) => tarea.toFirestore());

      final docSnap = await consulta.get();


      var tarea = null;
      if (docSnap != null) {
        tarea = docSnap.data();
        tarea?.id = docSnap.id;

      }

      return tarea;
    } catch (e) {
      print(e);
    }
  }

  // Metodo que comprueba la contraseña introducida con la guardada en la base de datos
  checkearPassword(id, password) async {
    try {
      var resultado = await consultarIDusuario(id);

      var PassEncriptada = encriptacionSha256(password);

      if (PassEncriptada == resultado.password) {
        return true;
      } else
        return false;
    } catch (e) {
      print(e);
    }
  }

  // Metodo que te devuelve la URL según el PATH que tenga la imagen en el servidor
  leerImagen(path) async {
    final imagen = storageRef.child(path);

    print("intentando cargar imagen");
    try {
      const oneMegabyte = 1024 * 1024;
      final String? data = await imagen.getDownloadURL();
      print("imagen cargada ${data}");
      return data;
      // Data for "images/island.jpg" is returned, use this as needed.
    } on FirebaseException catch (e) {
      print("ERROR:" + e.toString());
      // Handle any errors.
    }
  }

  // Metodo que te devuelve la URL según el PATH que tenga el video en el servidor
  leerVideo(path) async {
    final video = storageRef.child(path);

    print("intentando cargar video");
    try {
      const oneMegabyte = 1024 * 1024;
      final String? data = await video.getDownloadURL();
      print("video cargado");
      return data;
      // Data for "images/island.jpg" is returned, use this as needed.
    } on FirebaseException catch (e) {
      print("ERROR:" + e.toString());
      // Handle any errors.
    }
  }

  crearTablon(tablon) async
  {
    try {
      final ref = db.collection("tablero");
      var nuevoTablero = <String, dynamic>{
          "nombre" : tablon.nombres,
          "imagene" : tablon.imagenes,
          "tipo" : tablon.tipos,
      };
      ref.add(nuevoTablero);
      return true;
    }
    catch(e){
      print(e);
      return false;
    }
  }

  // Metodo que te devuelve todos los usuarios de la base de datos
  consultarTodosTablon() async {
    try {
      var tablon = [];

      final ref = db.collection("tablero").withConverter(
          fromFirestore: Tablon.fromFirestore,
          toFirestore: (Tablon tab, _) => tab.toFirestore());

      final consulta = await ref.get();

      consulta.docs.forEach((element) {
        final tableroNuevo = element.data();
        tableroNuevo.id = element.id;
        tablon.add(tableroNuevo);
      });
      return tablon;

    } catch (e) {
      print(e);
    }
  }

}
