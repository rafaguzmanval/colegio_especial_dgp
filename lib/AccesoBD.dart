import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Sesion.dart';

import 'package:colegio_especial_dgp/rol.dart';
import 'package:colegio_especial_dgp/usuario.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';



class AccesoBD{

  var db = FirebaseFirestore.instance;
  var storageRef = FirebaseStorage.instance.ref();

  registrarUsuario(usuario) async{

    var data = utf8.encode(usuario.password);
    var hashvalue = sha256.convert(data);

    final user = <String, dynamic>{
      "nombre" : usuario.nombre,
      "apellidos" : usuario.apellidos,
      "password" : hashvalue.toString(),
      "fechanacimiento" : usuario.fechanacimiento,
      "rol" : usuario.rol
    };

    db.collection("usuarios").add(user).then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));

  }


  leerDatos(path) async{
    String valores = "";
    await db.collection(path).get().then((event) => {
      for(var doc in event.docs){
        valores += "${doc.id} => ${doc.data()}"
        }
      }
    );

    return valores;

  }

  consultarIDusuario(id) async{

    final ref = db.collection("usuarios");

    final consulta = ref.doc(id).withConverter(
        fromFirestore: Usuario.fromFirestore,
        toFirestore: (Usuario user, _) => user.toFirestore());

    final docSnap = await consulta.get();
    final usuario = docSnap.data();

    return usuario;
  }

  checkearPassword(id,password) async
  {
    var resultado = await consultarIDusuario(id);

    var data = utf8.encode(password);
    var hashvalue = sha256.convert(data);

    if(hashvalue.toString() == resultado.password)
      {
        Sesion.nombre = resultado.nombre;
        Sesion.rol = resultado.rol;
        return true;
      }
    else
        return false;
  }

  leerImagen(path) async{

    final imagen = storageRef.child(path);

    print("intentando cargar imagen");
    try {
      const oneMegabyte = 1024 * 1024;
      final Uint8List? data = await imagen.getData(oneMegabyte);
      print("imagen cargada");
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