import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/passportmethod.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';

class Tarea{
  var id;
  var nombre;

  Tarea({
          this.id,
          this.nombre,
  });


  factory Tarea.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Tarea(
      nombre: data?['nombre'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,

    };
  }

  setTarea(nombre)
  {
    this.nombre = nombre;

  }

}