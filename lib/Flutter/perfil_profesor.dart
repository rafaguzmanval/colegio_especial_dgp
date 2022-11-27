/*
*   Archivo: perfil_profesor.dart
*
*   Descripción:
*   Pagina para ver el perfil del profesor
*
*   Includes:
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
* */

import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';

class PerfilProfesor extends StatefulWidget {
  @override
  PerfilProfesorState createState() => PerfilProfesorState();
}

class PerfilProfesorState extends State<PerfilProfesor> {
  var usuarioPerfil;

  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;
    cargarUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios_new, color: GuardadoLocal.colores[2]),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Center(
            child: Text(
          'PERFIL DE ${Sesion.seleccion.nombre.toUpperCase()}'
          '',
          textAlign: TextAlign.center,
          style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 30),
        )),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          alignment: Alignment.center,
          child: Column(
            children: [
              if (Sesion.rol == Rol.alumno.toString()) ...[
                VistaAlumno()
              ] else if (Sesion.rol == Rol.profesor.toString()) ...[
                VistaProfesor()
              ] else if (Sesion.rol == Rol.administrador.toString()) ...[
                VistaAdministrador()
              ] else if (Sesion.rol == Rol.programador.toString()) ...[
                VistaProgramador()
              ]
            ],
          )),
    );
  }

  // Carga el perfil del profesor
  Widget VistaProfesor() {
    return perfilProfesor();
  }

  Widget VistaAlumno() {
    Navigator.pop(context);
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  // Carga el perfil del profesor
  Widget VistaAdministrador() {
    return perfilProfesor();
  }

  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  /// Carga el perfil del profesor
  Widget perfilProfesor() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [
          if (usuarioPerfil != null) ...[
            Text(
              "NOMBRE: " + usuarioPerfil.nombre + "\n",
              style: TextStyle(color: GuardadoLocal.colores[0]),
            ),
            Text(
              "APELLIDOS: " + usuarioPerfil.apellidos + "\n",
              style: TextStyle(color: GuardadoLocal.colores[0]),
            ),
            Text(
              "FECHA DE NACIMIENTO: " + usuarioPerfil.fechanacimiento + "\n",
              style: TextStyle(color: GuardadoLocal.colores[0]),
            ),
            Text(
              "IMAGEN DE PERFIL:\n",
              style: TextStyle(color: GuardadoLocal.colores[0]),
            ),
            Image(
              width: 100,
              height: 100,
              image: NetworkImage(usuarioPerfil.foto),
            ),

            /* TextField(
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: 'Introduce nueva tarea',
                ),
                controller: myController,
              ),*/
          ]
        ],
      ),
    );
  }

  /// Carga el usuario del profesor
  cargarUsuario() async // EN sesion seleccion estara el id del usuario que se ha elegido
  {
    usuarioPerfil = await Sesion.db.consultarIDusuario(Sesion.seleccion.id);
    actualizar();
  }

  /// Actualiza la pagina
  void actualizar() {
    setState(() {});
  }
}
