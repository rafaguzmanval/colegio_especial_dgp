import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/tarea.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';

import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


String encriptacionSha256(String password)
{
  var data = utf8.encode(password);
  var hashvalue = sha256.convert(data);

  return hashvalue.toString();
}


class AccesoBD{

  var db = FirebaseFirestore.instance;
  var storageRef = FirebaseStorage.instance.ref();

  var fotoDesconocido = "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fperfiles%2Fdesconocido.png?alt=media&token=98ba72ac-776e-4f83-9aaa-57761589c974";


  registrarUsuario(usuario,foto) async{

    try {
      //Se encripta la contaseña
      var nuevaPassword = encriptacionSha256(usuario.password);
      var nombrehaseao = encriptacionSha256(usuario.apellidos + usuario.fechanacimiento);

      var fotoPath = null;
      if(foto != null)
        {
          fotoPath = "Imágenes/perfiles/${usuario.nombre+usuario.apellidos+nombrehaseao}";


          return await storageRef.child(fotoPath).putFile(foto).then((p0) async {
            var fotoURL = await leerImagen(fotoPath);

            var user = <String, dynamic>{
              "nombre": usuario.nombre,
              "apellidos": usuario.apellidos,
              "password": nuevaPassword,
              "fechanacimiento": usuario.fechanacimiento,
              "rol": usuario.rol,
              "foto": fotoURL,
              "metodoLogeo" : usuario.metodoLogeo
            };
            db.collection("usuarios").add(user);

            return true;
            });
          }else{

              var user = <String, dynamic>{
                "nombre": usuario.nombre,
                "apellidos": usuario.apellidos,
                "password": nuevaPassword,
                "fechanacimiento": usuario.fechanacimiento,
                "rol": usuario.rol,
                "foto": fotoDesconocido,
                "metodoLogeo" : usuario.metodoLogeo
              };
              db.collection("usuarios").add(user);

              return true;

          }

    }
    catch(e){
      print(e);
      return false;
    }

  }


  crearTarea(tarea) async{

    try {
      //Se encripta la contaseña

      var imagenes = [];
      var videos = [];

      var futuros = <Future>[];

      int i = 0;

      log("Se meten imagenes");
      if(tarea.imagenes.length > 0)
        {

          var fotoPath = "Imágenes/pictogramas/"+encriptacionSha256(tarea.imagenes[0].path);
          await storageRef.child(fotoPath).putFile(tarea.imagenes[0]).then( (d0) async {
            log("Se está comprobando que la imagen se ha subido correctamente");
            await leerImagen(fotoPath).then((value){
              log(value);
              imagenes.add(value);
              log("Se añadio la imagen al array");
              i++;
            });
            log("Se leido lo de await leerImagen");
          }
          );
        }

      log("Se meten videos");
      if(tarea.videos.length > 0)
        {
          var videoPath = "Vídeos/"+encriptacionSha256(tarea.videos[0].path);

          await storageRef.child(videoPath).putFile(tarea.videos[0]).then((p0) async {
            await leerVideo(videoPath).then((value) {
              videos.add(value);
              i++;

            });


          });
        }

      while( i != tarea.imagenes.length + tarea.videos.length){};

        log("Todos los futures se han completado");
        var nuevaTarea = <String, dynamic>{
          "nombre": tarea.nombre,
          "textos": tarea.textos,
          "imagenes": imagenes,
          "videos": videos,
          "orden": tarea.orden
        };

        db.collection("Tareas").add(nuevaTarea);

        return true;

    }
    catch(e){

      log(e.toString());
      return false;
    }

  }


  consultarIDusuario(id) async{

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
    }
    catch(e){
      print(e);
    }
  }

  consultarTareasAsignadasAlumno(id,cargarVideos) async
  {

    try {
      final ref = db.collection("usuarioTieneTareas");

      await ref.where("idUsuario",isEqualTo: id).orderBy("fechainicio")..snapshots().listen((e) async{

        var nuevasTareas = [];
        for(int i = 0; i < e.docs.length; i++)
          {
            var idTarea = e.docs[i].get("idTarea");

            await consultarIDTarea(idTarea).then( (nuevaTarea) {

              nuevaTarea.idRelacion = e.docs[i].id;
              nuevasTareas.add(nuevaTarea);

              if(nuevasTareas.length == e.docs.length)
                {
                  Sesion.tareas = nuevasTareas;
                  if(cargarVideos)
                  {
                    try {
                      for (int i = 0; i < Sesion.tareas.length; i++) {
                        for (int j = 0; j < Sesion.tareas[i].videos.length; j++) {
                          var nuevoControlador = VideoPlayerController.network(
                              Sesion.tareas[i].videos[j]);
                          Sesion.tareas[i].controladoresVideo.add(nuevoControlador);
                          Sesion.tareas[i].controladoresVideo.last.initialize();
                        }
                      }
                      Sesion.paginaActual.actualizar();

                    }
                    catch(e){print(e);};
                }
                  Sesion.paginaActual.actualizar();
                  return;

            }});

        }

        if(e.docs.length == 0)
          Sesion.tareas = [];


      });



    }
    catch(e){
      print(e);
      return false;
    }

  }


  addTareaAlumno(idUsuario,idTarea) async{
    try {

      var tar = <String, dynamic>{
        "idUsuario": idUsuario,
        "idTarea": idTarea,
        "fechainicio" : DateTime.now().millisecondsSinceEpoch
      };

      await db.collection("usuarioTieneTareas").add(tar).then((value) {
        Sesion.paginaActual.esNuevaTareaCargando = false;
        Sesion.paginaActual.actualizar();
      });

    }
    catch(e){
      print(e);
    }

  }

  eliminarTareaAlumno(id) async{

    try{
      if(Sesion.tareas != null && Sesion.tareas != [])
      {
        await db.collection("usuarioTieneTareas").doc(id).delete().then((value) {
          Sesion.paginaActual.esTareaEliminandose = false;
          Sesion.paginaActual.actualizar();
        });
      }
    }catch(e){
      print(e);
    }

  }
  consultarTodosUsuarios() async
  {
    try{
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
    }catch(e){
      print(e);
    }

  }


  consultarTodosAlumnos() async
  {
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
    }catch(e){
      print(e);
    }
  }

  consultarTodosProfesores() async
  {
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
    }catch(e){
      print(e);
    }
  }


  consultarTodasLasTareas() async{
    try {
      final ref = db.collection("Tareas").withConverter(
          fromFirestore: Tarea.fromFirestore,
          toFirestore: (Tarea tarea,_) => tarea.toFirestore());

      final consulta = await ref.get();

      var lista = [];

      consulta.docs.forEach((element) {
        var nuevaTarea = element.data();
        nuevaTarea.id = element.id;
        lista.add(nuevaTarea);
      });

      return lista;
    }
    catch (e) {
    print(e);
    }
  }

  consultarIDTarea(id) async{

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
    }
    catch(e){
      print(e);
    }
  }

  checkearPassword(id,password) async
  {
    try {
      var resultado = await consultarIDusuario(id);

      var PassEncriptada = encriptacionSha256(password);

      if (PassEncriptada == resultado.password) {

        return true;
      }
      else
        return false;
    }catch(e){
      print(e);
    }
  }

  leerImagen(path) async{

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

  leerVideo(path) async{

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


}