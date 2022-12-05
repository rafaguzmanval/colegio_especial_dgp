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
import 'package:colegio_especial_dgp/Dart/usuario.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Flutter/localizacion.dart';
import 'package:colegio_especial_dgp/Flutter/ver_tareas.dart';
import '../Dart/tarea.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import "package:image_picker/image_picker.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:colegio_especial_dgp/Dart/passport_method.dart';
import 'dart:io';

enum SeleccionImagen { camara, galeria }

class PerfilAlumno extends StatefulWidget {
  @override
  PerfilAlumnoState createState() => PerfilAlumnoState();
}

class PerfilAlumnoState extends State<PerfilAlumno> {

  var usuarioPerfil;
  var tareasSinFinalizar = [];
  var tareasCompletadas = [];
  var tareasCanceladas = [];
  var controladorNombre = TextEditingController();
  var controladorApellidos = TextEditingController();
  final myController = TextEditingController();
  var fechaElegida = null;
  var fechaAntigua;
  var fotoTomada;
  var registrando = false;
  var mensajeDeRegistro = "";
  var vez = 0;
  ImagePicker capturador = new ImagePicker();
  final controladorPassword = TextEditingController();
  var metodoElegido;
  var rolElegido;

  //Todas las tareas que el profesor selecciona para asignar al alumno
  var tareas = [];
  var nombresTareas = ["NADA SELECCIONADO"];

  bool esTareaEliminandose = false;

  int tareaEliminandose = 0;


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
          title: Center(child: Text('${Sesion.seleccion.nombre.toUpperCase()}'
              '',textAlign: TextAlign.center,style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 30),),
        )),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            alignment: Alignment.center,
            child: Column(
              children: [
               cargando(),

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

  seleccionarImagen(seleccion) async {
    try {
      if (seleccion == SeleccionImagen.camara) {
        print("Se va a abrir la cámara de fotos");
        fotoTomada = await capturador.pickImage(
          source: ImageSource.camera,
          imageQuality: 15,
        );
      } else {
        print("Se coger una foto de la galería");
        fotoTomada = await capturador.pickImage(
            source: ImageSource.gallery, imageQuality: 15);
      }
    } catch (e) {
      print(e);
    }
    actualizar();
  }

  // Carga el perfil del alumno
  Widget perfilAlumno() {
    if (vez == 0) {
      controladorNombre.text = usuarioPerfil.nombre.toUpperCase();
      controladorApellidos.text = usuarioPerfil.apellidos.toUpperCase();
      fechaAntigua = usuarioPerfil.fechanacimiento;
      fotoTomada = usuarioPerfil.foto;
      controladorPassword.text = usuarioPerfil.password;
      rolElegido = usuarioPerfil.rol;
      metodoElegido = usuarioPerfil.metodoLogeo;
      if(metodoElegido == "Passportmethod.text"){
        metodoElegido = "clave";
      }
      else{
        metodoElegido = "pin";
      }
      vez++;
    }

    tareasSinFinalizar.clear();
    tareasCompletadas.clear();
    tareasCanceladas.clear();

    for(int i = 0; i < Sesion.tareas.length; i++)
    {
      if(Sesion.tareas[i].estado == "sinFinalizar")
      {
        tareasSinFinalizar.add(Sesion.tareas[i]);
        tareasSinFinalizar.add(i);
      }
      else if(Sesion.tareas[i].estado == "completada")
      {
        tareasCompletadas.add(Sesion.tareas[i]);
        tareasCompletadas.add(i);
      }
      else{
        tareasCanceladas.add(Sesion.tareas[i]);
        tareasCanceladas.add(i);
      }
    }

    return Expanded(

        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child: SingleChildScrollView(
      child: Column(
        children: [
          if (usuarioPerfil != null) ...[
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 500,
              child: TextField(
                style:
                TextStyle(fontSize: 30.0, color: GuardadoLocal.colores[0]),
                obscureText: false,
                maxLength: 40,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: GuardadoLocal.colores[0], width: 0.0),
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'NOMBRE *',
                    hintStyle: TextStyle(color: GuardadoLocal.colores[0])),
                controller: controladorNombre,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 500,
              child: TextField(
                style:
                TextStyle(fontSize: 30.0, color: GuardadoLocal.colores[0]),
                obscureText: false,
                maxLength: 40,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: GuardadoLocal.colores[0], width: 0.0),
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'APELLIDOS *',
                    hintStyle: TextStyle(color: GuardadoLocal.colores[0])),
                controller: controladorApellidos,
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  await showDatePicker(
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: GuardadoLocal.colores[1],
                            colorScheme: ColorScheme.light(
                                primary:
                                GuardadoLocal.colores[0] // <-- SEE HERE
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                primary: GuardadoLocal
                                    .colores[0], // button text color
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                      context: context,
                      locale: const Locale("es", "ES"),
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now())
                      .then((e) {
                    fechaElegida = e;
                    actualizar();
                  });
                },
                child: Text(
                  (fechaElegida == null)
                      ? fechaAntigua
                      : DateFormat('d/M/y').format(fechaElegida),
                  style:
                  TextStyle(color: GuardadoLocal.colores[2], fontSize: 25),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: GuardadoLocal.colores[0])),
            SizedBox(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                  border:
                  Border.all(width: 2, color: GuardadoLocal.colores[0])),
              height: 150,
              width: 230,
              child: fotoTomada == null
                  ? Center(
                  child: Text(
                    'NINGUNA FOTO ELEGIDA ****',
                    textAlign: TextAlign.center,
                  ))
                  : Stack(
                children: [
                  Center(
                      child: fotoTomada is String
                          ? Image.network(fotoTomada)
                          : Image.network(fotoTomada)),
                  Container(
                    child: ElevatedButton(
                        onPressed: () {
                          fotoTomada = null;
                          actualizar();
                        },
                        child: Icon(
                          Icons.remove,
                          color: GuardadoLocal.colores[2],
                        )),
                    alignment: Alignment.topLeft,
                  )
                ],
              ),
            ),
            SizedBox(height: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (fotoTomada == null) ...[
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      child: Text(
                        'HAZ UNA FOTO DESDE LA CAMARA',
                        style: TextStyle(
                            color: GuardadoLocal.colores[2], fontSize: 25),
                      ),
                      onPressed: () {
                        seleccionarImagen(SeleccionImagen.camara);
                      }),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      child: Text('ELIGE FOTO DE LA GALERIA',
                          style: TextStyle(
                              color: GuardadoLocal.colores[2], fontSize: 25)),
                      onPressed: () {
                        seleccionarImagen(SeleccionImagen.galeria);
                      }),
                ]
              ],
            ),
            ///BOTON DE LOCALIZACION

            SizedBox(height: 15),
            ElevatedButton(onPressed: () async{
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Localizacion()));
              Sesion.paginaActual = this;
              actualizar();

            }, child: Icon(Icons.map_outlined)),


            /// se muestran las tareas del alumno
            if (Sesion.tareas != null) ...[
              if(tareasSinFinalizar.length != 0)...[
              Text("\nTAREAS EN CURSO: ",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
                visualizarTareaLista("sinFinalizar"),
              ],
              if(tareasCompletadas.length != 0)...[
              Text("\nTAREAS COMPLETADAS: ",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
                visualizarTareaLista("completada"),
              ],

              if(tareasCanceladas.length != 0)...[
              Text("\nTAREAS CANCELADAS: ",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
              visualizarTareaLista("cancelada")
              ],

              if(tareasSinFinalizar.length == 0 && tareasCompletadas.length == 0 && tareasCanceladas.length == 0)...[
                Text("SIN TAREAS",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
              ]
            ],

            /// Añadir una nueva tarea al alumno
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
          ],
          Text(
            mensajeDeRegistro,
            style: TextStyle(fontSize: 25),
          ),
          Visibility(
              visible: !registrando,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(GuardadoLocal.colores[0]),
                ),
                child: Text(
                  "EDITAR",
                  style: TextStyle(
                      backgroundColor: Colors.transparent,
                      color: GuardadoLocal.colores[2],
                      fontSize: 25),
                ),
                onPressed: () {
                  editarUsuario();
                },
              )),
          Visibility(
              visible: registrando, child: new CircularProgressIndicator()),
        ],
      ),
    ));
  }

  cargarUsuario() async // EN sesion seleccion estara el id del usuario que se ha elegido
  {
    usuarioPerfil = await Sesion.db.consultarIDusuario(Sesion.seleccion.id);
    await Sesion.db.consultarTareasAsignadasAlumno(Sesion.seleccion.id, false);


    print(tareasSinFinalizar.length.toString() + " " + tareasCompletadas.length.toString());

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

  editarUsuario() async{
    // FALTARIA HACER COMPROBACIÓN DE QUE EL NOMBRE Y APELLIDOS YA ESTÁN REGISTRADOS EN LA BASE DE DATOS

    if (controladorNombre.text.isNotEmpty &&
        controladorApellidos.text.isNotEmpty &&
        controladorPassword.text.isNotEmpty &&
        fechaAntigua != null &&
        rolElegido != "ningun rol elegido") {
      registrando = true;
      actualizar();
      var fechanacimiento =  "" + fechaAntigua;
      var nombre = "" + controladorNombre.text;
      var apellidos = "" + controladorApellidos.text;
      var password = "" + controladorPassword.text;
      if(fechaElegida != null){
        fechanacimiento = "" + DateFormat('d/M/y').format(fechaElegida);
      }

      var rol = "" + rolElegido;

      Usuario usuario = Usuario();
      usuario.setUsuario(
          nombre,
          apellidos,
          password,
          fechanacimiento,
          rol,
          "",
          metodoElegido == "clave"
              ? Passportmethod.text.toString()
              : Passportmethod.pin.toString());

      var foto = null;
      if (fotoTomada != null) {
        if (fotoTomada is String) {
          if (fotoTomada.startsWith("http")) {
            foto = fotoTomada;
          }
        } else {
          foto = File(fotoTomada.path);
        }
      }

      await Sesion.db.editarUsuario(usuario, foto, usuarioPerfil).then((value) {
        registrando = false;

        if (value) {
          mensajeDeRegistro =
          "EDICION COMPLETADA PERFECTAMENETE\nPUEDES VOLVER A EDITAR OTRO USUARIO";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                duration: Duration(seconds: 2),
                elevation: 0,
                content: Container(
                  padding: const EdgeInsets.all(16),
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6BFF67),
                    borderRadius: BorderRadius.all(Radius.circular(29)),
                  ),
                  child: Text(
                    mensajeDeRegistro,
                    style: TextStyle(
                        color: GuardadoLocal.colores[2], fontSize: 25),
                  ),
                )),
          );
          Navigator.pop(context);
        } else {
          mensajeDeRegistro =
          "FALLO EN EL PROCESO DE REGISTRO, INTENTELO DE NUEVO";
          mostrarError(mensajeDeRegistro, true);
        }

        actualizar();
      });
    } else {
      mensajeDeRegistro = "DEBE RELLENAR TODOS LOS CAMPOS CON *";
      mostrarError(mensajeDeRegistro, true);
      actualizar();
    }
  }

  mostrarError(mensaje, error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          duration: Duration(seconds: 2),
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: BoxDecoration(
              color: Color(error ? 0xFFC72C41 : 0xFF6BFF67),
              borderRadius: BorderRadius.all(Radius.circular(29)),
            ),
            child: Text(
              mensaje,
              style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 25),
            ),
          )),
    );
  }


  Widget cargando() {
    if (usuarioPerfil == null)
      return Center(
        child: Text(
          '\nCARGANDO EL USUARIO',
          textAlign: TextAlign.center,
        ),
      );
    else {
      return vista();
    }
  }

  vista() {
    if (Sesion.rol == Rol.alumno.toString()) {
      return VistaAlumno();
    } else if (Sesion.rol == Rol.profesor.toString()) {
      return VistaProfesor();
    } else if (Sesion.rol == Rol.administrador.toString()) {
      return VistaAdministrador();
    } else if (Sesion.rol == Rol.programador.toString()) {
      return VistaProgramador();
    }
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
                                    child: Text(value,style: TextStyle(fontSize: 25),),
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
                                          .format(fechafinal),style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 25),)),
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
                                                horafinal.minute.toString()),style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 25),),
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
                                      fontSize: 25
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

  Widget visualizarTareaLista(condicion)
  {
    var listaIterar;
    if(condicion == "sinFinalizar")
      {
        listaIterar = tareasSinFinalizar;
      }
    else if(condicion == "completada")
      {
        listaIterar = tareasCompletadas;
      }
    else
      {
        listaIterar = tareasCanceladas;
      }
    return Column(
        children: [
        for (int i = 0; i < listaIterar.length; i+=2)
            Container(
            margin: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            ElevatedButton(
            onPressed: () async {
            Sesion.argumentos.add(listaIterar[i+1]);
            await Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => VerTareas()));
            Sesion.paginaActual = this;
            },
            child: Text(listaIterar[i].nombre.toString().toUpperCase(),style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[2]),),
            ),
              IconButton(
              onPressed: () async {
            await Sesion.db.eliminarTareaAlumno(
                listaIterar[i].idRelacion);

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
        ]
    );

  }
}
