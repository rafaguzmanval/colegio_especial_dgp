import 'package:firebase_database/firebase_database.dart';



class AccesoBD{
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  escribirDatos() async{
    await ref.child("usuario/0").set({
      "nombre": "Pepe Luis",
      "apellidos":"Marín López",
      "telefono" : "3424"
    });

    await ref.child("usuario/1").set({
      "nombre": "Pepe",
      "telefono" : "6666",
      "edad" : "16"
    });

  }



  Future<String> leerDatos() async{

    final valor = await ref.child("usuario/0").get();


    return valor.value.toString();
  }


}