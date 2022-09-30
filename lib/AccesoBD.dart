import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
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
      "apellidos" : usuario.DNI,
      "DNI": usuario.DNI,
      "password" : hashvalue.toString(),
      "fechanacimiento" : usuario.fechanacimiento
    };

    db.collection("usuarios").add(user).then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));


  }


  leerDatos(path) async{
    String valores = "";
    await db.collection("usuarios").get().then((event) => {
      for(var doc in event.docs){
        valores += "${doc.id} => ${doc.data()}"
        }
      }
    );

    return valores;

  }

  consultarDNI(dni) async{

    var valores = "";
    final ref = db.collection("usuarios");

    final consulta = ref.where("DNI", isEqualTo: dni);

    await consulta.get().then((event) => {

      if(event.docs.isNotEmpty)
      valores = event.docs.first.data().toString()
      else{
        print("NO SE HA ENCONTRADO EL USUARIO CON DNI: ${dni} EN LA BASE DE DATOS")
      }
    });

    print(valores);

    return valores;

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