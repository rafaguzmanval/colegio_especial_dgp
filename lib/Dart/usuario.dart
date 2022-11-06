import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/passport_method.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';

/*
*   Archivo: usuario.dart
*
*   Descripción:
*   La clase Usuario almacena la información de un usuario que puede ser de cualquier tipo de rol (alumno, profesor, administrador,..)
*   esta clase se utiliza especialmente cuándo se va a registrar un usuario y se crea una nueva instancia cuyos datos pueden introducirse en la base de datos
*   y también de forma inversa cuándo se quiere consultar la información de un usuario desde la base de datos y se introduce en una nueva instancia
*
*   Es una clase que relaciona información de la BD con la información que necesita tener la aplicación con un paradigma orientado a objetos.
*
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   passport_method.dart : Contiene el enum que indica el tipo de contraseña que va a usarse (clave, pin,...)
*
* */

class Usuario{
  var id;
  var nombre;
  var apellidos ;
  var fechanacimiento; // fecha de nacimiento de la que se calculará la edad
  var password; // contraseña hasheada
  var rol;
  var foto;
  var metodoLogeo; // Si el usuario necesita algún otro método para meter contraseña


  Usuario({
          this.id,
          this.nombre,
          this.apellidos,
          this.password,
          this.fechanacimiento,
          this.rol,
          this.foto,
          this.metodoLogeo});


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
      metodoLogeo : data?['metodoLogeo'],
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
      if(metodoLogeo != null) "metodoLogeo" : metodoLogeo,

    };
  }

  setUsuario(nombre,apellidos,password,fechanacimiento,rol,foto,metodoLogeo)
  {
    this.nombre = nombre;
    this.apellidos = apellidos;
    this.password = password;
    this.fechanacimiento = fechanacimiento;
    this.rol = rol;
    this.foto = foto;
    this.metodoLogeo = metodoLogeo;

  }

}