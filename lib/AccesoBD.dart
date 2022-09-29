import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';



class AccesoBD{
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  var storageRef = FirebaseStorage.instance.ref();

  escribirDatos() async{
    await ref.child("usuario/1").set({
      "nombre": "Pepe Luis",
      "apellidos":"Marín López",
      "telefono" : "3424"
    });

    await ref.child("usuario/2").set({
      "nombre": "MAnolin",
      "telefono" : "45656",
      "edad" : "21"
    });

  }


  Future<String> leerDatos() async{

    final valor = await ref.child("usuario").get();

    return valor.value.toString();

  }

  leerImagen() async{

    final imagen = storageRef.child("ugr.png");

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


}