import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Sesion.dart';
import 'package:colegio_especial_dgp/perfilalumno.dart';

import 'package:colegio_especial_dgp/rol.dart';
import 'package:colegio_especial_dgp/usuario.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

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

      await storageRef.child(fotoPath).putFile(foto).then((p0) async {
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

    });





    }
    catch(e){
      print(e);
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

  consultarTareas(id)
  {

    try {
      final ref = db.collection("usuarios");

      ref.doc(id).withConverter(
          fromFirestore: Usuario.fromFirestore,
          toFirestore: (Usuario user, _) => user.toFirestore())
          .snapshots()
          .listen((event) {
        var usuario = event.data();
        Sesion.misTareas = usuario?.tareas;
        Sesion.paginaActual.actualizar();
      });
    }
    catch(e){
      print(e);
    }

  }

  addTareaAlumno(id,tarea) async{
    try {
      final ref = db.collection("usuarios");
      if (Sesion.misTareas == null)
        Sesion.misTareas = [];
      Sesion.misTareas.add(tarea);
      ref.doc(id).update({
        "tareas": Sesion.misTareas,
      });
    }
    catch(e){
      print(e);
    }

  }

  eliminarTareaAlumno(id,tarea) async{

    try{
      if(Sesion.misTareas != null && Sesion.misTareas != [])
      {
        final ref = db.collection("usuarios");
        Sesion.misTareas.remove(tarea);
        ref.doc(id).update({
          "tareas" : Sesion.misTareas,
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