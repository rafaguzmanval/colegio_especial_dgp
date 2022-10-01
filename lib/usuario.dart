import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/passportmethod.dart';
import 'package:colegio_especial_dgp/rol.dart';

class Usuario{
  var id;
  final nombre;
  final apellidos ;
  final fechanacimiento; // fecha de nacimiento de la que se calculará la edad
  final password; // contraseña hasheada
  final rol;
  final tareas;
  Passportmethod metodoLogeo = Passportmethod.free; // Si el usuario necesita algún otro método para meter contraseña


  Usuario({
          this.id,
          this.nombre,
          this.apellidos,
          this.password,
          this.fechanacimiento,
          this.rol,
          this.tareas});


  factory Usuario.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Usuario(
      nombre: data?['nombre'],
      apellidos: data?['apellidos'],
      password: data?['password'],
      fechanacimiento: data?['fechanacimiento'],
      rol: data?['rol'],
      tareas: data?['tareas'] is Iterable ? List.from(data?['tareas']) : null,

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
      if (apellidos != null) "apellidos": apellidos,
      if (fechanacimiento != null) "fechanacimiento": fechanacimiento,
      if (rol != null) "rol": rol,
      if (password != null) "password": password,
      if (tareas != null) "tareas": tareas,

    };
  }

}