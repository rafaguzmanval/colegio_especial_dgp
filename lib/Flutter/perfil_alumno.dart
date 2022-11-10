import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import '../Dart/tarea.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class PerfilAlumno extends StatefulWidget {
  @override
  PerfilAlumnoState createState() => PerfilAlumnoState();
}

class PerfilAlumnoState extends State<PerfilAlumno> {
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
    cargarTareas();
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
    return perfilAlumno();
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
    return perfilAlumno();
  }

  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  Widget perfilAlumno() {
    return Expanded(

        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child: SingleChildScrollView(
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
            Text("\nTAREAS ASIGNADAS:"),
            if (Sesion.tareas != null) ...[
              for (int i = 0; i < Sesion.tareas.length; i++)
                if (Sesion.tareas[i] is Tarea) ...[
                  Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(Sesion.tareas[i].nombre),
                          IconButton(
                              onPressed: () {
                                base.eliminarTareaAlumno(
                                    Sesion.tareas[i].idRelacion);
                                esTareaEliminandose = true;
                                tareaEliminandose = i;
                                actualizar();
                              },
                              icon: Icon(Icons.delete)),
                          if (esTareaEliminandose &&
                              i == tareaEliminandose) ...[
                            new CircularProgressIndicator(),
                          ]
                        ],
                      )),
                ] else ...[
                  new CircularProgressIndicator()
                ],
            ],
            Text("\n Añadir Tarea: \n"),

            /* TextField(
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: 'Introduce nueva tarea',
                ),
                controller: myController,
              ),*/

            if (tareas != null && nombresTareas.length > 1) ...[
              DropdownButton(
                key: Key("Multiselección"),
                value: tareaElegida,
                items: nombresTareas.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    tareaElegida = value!;

                    if (tareaElegida == "Nada seleccionado") {
                      idTareaElegida = null;
                    } else {
                      int i = 0;
                      bool salir = false;
                      while (i < tareas.length && !salir) {
                        if (tareas[i].nombre == tareaElegida) {
                          idTareaElegida = tareas[i].id;
                          salir = true;
                        }
                        i++;
                      }
                    }
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                child: Text(
                  "Añadir Tarea",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  if (idTareaElegida != null) {
                    base.addTareaAlumno(Sesion.seleccion.id, idTareaElegida);
                    esNuevaTareaCargando = true;
                    actualizar();
                  }
                },
              ),
              if (esNuevaTareaCargando) ...[new CircularProgressIndicator()]
            ],
          ] else ...[
            new CircularProgressIndicator()
          ]
        ],
      ),
    ));
  }

  cargarUsuario() async // EN sesion seleccion estara el id del usuario que se ha elegido
  {
    usuarioPerfil = await base.consultarIDusuario(Sesion.seleccion.id);
    await base.consultarTareasAsignadasAlumno(Sesion.seleccion.id, false);
    actualizar();
  }

  cargarTareas() async {
    tareas = await base.consultarTodasLasTareas();

    for (int i = 0; i < tareas.length; i++) {
      nombresTareas.add(tareas[i].nombre);
    }

    actualizar();
  }

  void actualizar() {
    setState(() {});
  }
}
