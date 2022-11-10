import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class PerfilProfesor extends StatefulWidget {
  @override
  PerfilProfesorState createState() => PerfilProfesorState();
}

class PerfilProfesorState extends State<PerfilProfesor> {
  AccesoBD base = new AccesoBD();

  var usuarioPerfil;

  var imagenPerfil;

  //Tareas del alumno que están asignadas y se muestran en su perfil
  var tareasAlumno = [];

  //Todas las tareas que el profesor selecciona para asignar al alumno
  var tareas = [];
  var nombresTareas = ["Nada seleccionado"];
  var tareaElegida = "Nada seleccionado";
  var idTareaElegida = null;

  bool esNuevaTareaCargando = false;
  bool esTareaEliminandose = false;

  int tareaEliminandose = 0;

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
        title: Text('Perfil de ${Sesion.seleccion.nombre}'
            ''),
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

  Widget perfilProfesor() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [
          if (usuarioPerfil != null) ...[
            Text("Nombre: " + usuarioPerfil.nombre + "\n"),
            Text("Apellidos: " + usuarioPerfil.apellidos + "\n"),
            Text(
                "Fecha de nacimiento: " + usuarioPerfil.fechanacimiento + "\n"),
            Text("Imagen de perfil:\n"),
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

  cargarUsuario() async // EN sesion seleccion estara el id del usuario que se ha elegido
  {
    usuarioPerfil = await base.consultarIDusuario(Sesion.seleccion.id);
    actualizar();
  }

  void actualizar() {
    setState(() {});
  }
}
