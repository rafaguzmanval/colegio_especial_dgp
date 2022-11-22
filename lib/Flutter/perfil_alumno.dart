/*
*   Archivo: perfil_alumno.dart
*
*   Descripción:
*   Pagina para ver el perfil del alumno
*
*   Includes:
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   tarea.dart : Carga la tarea desde la base de datos
* */

import 'dart:async';

import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Flutter/ver_tareas.dart';
import '../Dart/tarea.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PerfilAlumno extends StatefulWidget {
  @override
  PerfilAlumnoState createState() => PerfilAlumnoState();
}

class PerfilAlumnoState extends State<PerfilAlumno> {

  var usuarioPerfil;

  var imagenPerfil;

  //Tareas del alumno que están asignadas y se muestran en su perfil
  var tareasAlumno = [];

  //Todas las tareas que el profesor selecciona para asignar al alumno
  var tareas = [];
  var nombresTareas = ["NADA SELECCIONADO"];

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

    Sesion.tareas = [];
    Sesion.argumentos.clear();
    Sesion.paginaActual = this;
    cargarUsuario();
    cargarTareas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: (){Navigator.pop(context);}),
          title: Text('PERFIL DE: ${Sesion.seleccion.nombre}'
              '',style: TextStyle(color: GuardadoLocal.colores[2]),),
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
            ),
      ),
    );
  }

  // Carga el perfil del alumno
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

  // Carga el perfil del alumno
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

  // Carga el perfil del alumno
  Widget perfilAlumno() {
    return Expanded(

        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child: SingleChildScrollView(
      child: Column(
        children: [
          if (usuarioPerfil != null) ...[
            Text("NOMBRE: " + usuarioPerfil.nombre.toString().toUpperCase() + "\n",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
            Text("APELLIDOS: " + usuarioPerfil.apellidos.toString().toUpperCase() + "\n",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
            Text(
                "FECHA DE NACIMIENTO: " + usuarioPerfil.fechanacimiento.toString().toUpperCase() + "\n",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
            Text("IMAGEN DE PERFIL:\n",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
            Image(
              width: 100,
              height: 100,
              image: NetworkImage(usuarioPerfil.foto),
            ),
            Text("\nTAREAS ASIGNADAS:",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
            if (Sesion.tareas != null) ...[
              for (int i = 0; i < Sesion.tareas.length; i++)
                if (Sesion.tareas[i] is Tarea) ...[
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              Sesion.argumentos.add(i);
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VerTareas()));
                              Sesion.paginaActual = this;
                            },
                            child: Text(Sesion.tareas[i].nombre.toString().toUpperCase(),style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[2]),),
                          ),
                          IconButton(
                              onPressed: () async {
                                await Sesion.db.eliminarTareaAlumno(
                                    Sesion.tareas[i].idRelacion);

                                esTareaEliminandose = true;
                                tareaEliminandose = i;
                                actualizar();
                              },
                              icon: Icon(Icons.delete,color: GuardadoLocal.colores[0],)),
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
            if (tareas != null && nombresTareas.length > 1) ...[
              Container(
                  margin: EdgeInsets.only(top: 20),
                  child: FloatingActionButton(
                      heroTag: "addtarea",
                      onPressed: () => addTarea(context: context),
                      child: Icon(Icons.add,color: GuardadoLocal.colores[2],)))
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
    usuarioPerfil = await Sesion.db.consultarIDusuario(Sesion.seleccion.id);
    await Sesion.db.consultarTareasAsignadasAlumno(Sesion.seleccion.id, false);
    actualizar();
  }

  // Metodo que carga las tareas del alumno
  cargarTareas() async {
    tareas = await Sesion.db.consultarTodasLasTareas();

    for (int i = 0; i < tareas.length; i++) {
      nombresTareas.add(tareas[i].nombre);
    }

    actualizar();
  }

  // Actualizar la pagina
  void actualizar() {
    setState(() {});
    esTareaEliminandose = false;
  }

  addTarea({required BuildContext context}) {
    var tareaElegida = "NADA SELECCIONADO";
    var idTareaElegida = null;
    var fechafinal = null;
    var horafinal = null;
    bool esNuevaTareaCargando = false;
    StreamController controladorStream = StreamController.broadcast();

    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: StreamBuilder(
                  stream: controladorStream.stream,
                  initialData: "",
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return Container(
                      color: GuardadoLocal.colores[1],
                        height: MediaQuery.of(context).size.height - 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: GuardadoLocal.colores[1],
                              margin:
                                  EdgeInsets.only(top: 10, left: 10),
                              child: DropdownButton(
                                style: TextStyle(fontFamily:"Escolar",color: GuardadoLocal.colores[0]),
                                dropdownColor: GuardadoLocal.colores[1],
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

                                  controladorStream.add("");
                                },
                              ),
                            ),
                            Container(
                              color: GuardadoLocal.colores[1],
                              margin: EdgeInsets.only(top: 5),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: GuardadoLocal.colores[0]),
                                  onPressed: () async {
                                    await showDatePicker(
                                            context: context,
                                            locale: const Locale("es", "ES"),
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2100))
                                        .then((e) {
                                      fechafinal = e;
                                      controladorStream.add("");
                                    });
                                  },
                                  child: Text((fechafinal == null)
                                      ? "ELIGE FECHA DE ENTREGA LIMITE"
                                      : DateFormat('d/M/y')
                                          .format(fechafinal),style: TextStyle(color: GuardadoLocal.colores[2]),)),
                            ),
                            Container(
                              color: GuardadoLocal.colores[1],
                              margin: EdgeInsets.only(top: 5),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: GuardadoLocal.colores[0]),
                                onPressed: () async {
                                  await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((e) {
                                    horafinal = e;
                                    controladorStream.add("");
                                  });
                                },
                                child: Text((horafinal == null)
                                    ? "ELIGE HORA DE ENTREGA LIMITE"
                                    : horafinal.hour.toString() +
                                        ":" +
                                        ((horafinal.minute > 9)
                                            ? horafinal.minute.toString()
                                            : "0" +
                                                horafinal.minute.toString()),style: TextStyle(color: GuardadoLocal.colores[2]),),
                              ),
                            ),
                            Visibility(
                              visible: tareaElegida != "NADA SELECCIONADO",
                              child: Container(
                                color: GuardadoLocal.colores[1],
                                margin: EdgeInsets.only(bottom: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: GuardadoLocal.colores[0]),
                                  child: Text(
                                    "AÑADIR TAREA",
                                    style: TextStyle(
                                      color: GuardadoLocal.colores[2],
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (idTareaElegida != null) {
                                      if (fechafinal == null)
                                        fechafinal = DateTime.now();
                                      if (horafinal == null)
                                        horafinal =
                                            TimeOfDay(hour: 23, minute: 59);

                                      var tiempoFinal = DateTime(
                                              fechafinal.year,
                                              fechafinal.month,
                                              fechafinal.day,
                                              horafinal.hour,
                                              horafinal.minute)
                                          .millisecondsSinceEpoch;
                                      await Sesion.db
                                          .addTareaAlumno(Sesion.seleccion.id,
                                              idTareaElegida, tiempoFinal)
                                          .then((valor) {
                                        esNuevaTareaCargando = false;
                                        Navigator.pop(context);
                                      });
                                      esNuevaTareaCargando = true;
                                      controladorStream.add("");
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (esNuevaTareaCargando) ...[
                              new CircularProgressIndicator()
                            ]
                          ],
                        ));
                  }));
        });
  }
}
