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


  registrarUsuario(usuario,foto) async{

    try {
      //Se encripta la contaseña
      var nuevaPassword = encriptacionSha256(usuario.password);
      var nombrehaseao = encriptacionSha256(usuario.apellidos + usuario.fechanacimiento);

      var fotoPath = "Imágenes/perfiles/${usuario.nombre+usuario.apellidos+nombrehaseao}";


      print("Se envia la imagen");

      return await storageRef.child(fotoPath).putFile(foto).then((p0) async {
          var fotoURL = await leerImagen(fotoPath);

            var user = <String, dynamic>{
              "nombre": usuario.nombre,
              "apellidos": usuario.apellidos,
              "password": nuevaPassword,
              "fechanacimiento": usuario.fechanacimiento,
              "rol": usuario.rol,
              "foto": fotoURL,
              "tareas": []
            };

          db.collection("usuarios").add(user);

          return true;

      });
    }
    catch(e){
      print(e);
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

      await ref.where("idUsuario",isEqualTo: id).get().then((e) async{

        var nuevasTareas = [];
        for(int i = 0; i < e.docs.length; i++)
          {
            var idTarea = e.docs[i].get("idTarea");

            await consultarIDTarea(idTarea).then( (nuevaTarea) {

              nuevaTarea.idRelacion = e.docs.first.id;
              nuevasTareas.add(nuevaTarea);

              if(i == e.docs.length - 1)
                {
                  Sesion.tareas = nuevasTareas;
                  if(cargarVideos)
                  {
                    try {
                      for (int i = 0; i < Sesion.tareas.length; i++) {
                        for (int j = 0; j < Sesion.tareas[i].videos.length; j++) {
                          print("nuevo video " + Sesion.tareas[i].videos[j]);
                          var nuevoControlador = VideoPlayerController.network(
                              Sesion.tareas[i].videos[j]);
                          Sesion.controladoresVideo.add(nuevoControlador);
                          Sesion.controladoresVideo.last.initialize()
                              .then((value) {

                          });
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
      };

      db.collection("usuarioTieneTareas").add(tar);

    }
    catch(e){
      print(e);
    }

  }

  eliminarTareaAlumno(id) async{

    try{
      if(Sesion.tareas != null && Sesion.tareas != [])
      {
        final ref = db.collection("usuarioTieneTareas").doc(id).delete();
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