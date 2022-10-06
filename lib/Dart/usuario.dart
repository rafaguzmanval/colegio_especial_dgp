import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/passportmethod.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';

class Usuario{
  var id;
  var nombre;
  var apellidos ;
  var fechanacimiento; // fecha de nacimiento de la que se calculará la edad
  var password; // contraseña hasheada
  var rol;
  var foto;
  var tareas;
  Passportmethod metodoLogeo = Passportmethod.free; // Si el usuario necesita algún otro método para meter contraseña


  Usuario({
          this.id,
          this.nombre,
          this.apellidos,
          this.password,
          this.fechanacimiento,
          this.rol,
          this.foto,
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
      foto: data?['foto'],
      tareas: data?['tareas'] is Iterable ? List.from(data?['tareas']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
      if (apellidos != null) "apellidos": apellidos,
      if (fechanacimiento != null) "fechanacimiento": fechanacimiento,
      if (rol != null) "rol": rol,
      if(foto != null) "foto" : foto,
      if (password != null) "password": password,
      if (tareas != null) "tareas": tareas,

    };
  }

  setUsuario(nombre,apellidos,password,fechanacimiento,rol,foto)
  {
    this.nombre = nombre;
    this.apellidos = apellidos;
    this.password = password;
    this.fechanacimiento = fechanacimiento;
    this.rol = rol;
    this.foto = foto;

  }

}