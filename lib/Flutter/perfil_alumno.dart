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
  var tareasFinalizadas = [];
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
          title: Center(child: Text('PERFIL DE ${Sesion.seleccion.nombre.toUpperCase()}'
              '',textAlign: TextAlign.center,style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 30),),
        )),
        body: SingleChildScrollView(child: Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            alignment: Alignment.center,
            child: Column(
              children: [
               cargando(),

              ],
            ),
      ),
    ));
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
        return await capturador.pickImage(
          source: ImageSource.camera,
          imageQuality: 15,
        );
      } else {
        print("Se coger una foto de la galería");
        return await capturador.pickImage(
            source: ImageSource.gallery, imageQuality: 15);
      }
    } catch (e) {
      print(e);
    }
    actualizar();
  }

  // Carga el perfil del alumno
  Widget perfilAlumno() {


    tareasSinFinalizar.clear();
    tareasCompletadas.clear();
    tareasCanceladas.clear();
    tareasFinalizadas.clear();

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
      else if(Sesion.tareas[i].estado == "cancelada"){
        tareasCanceladas.add(Sesion.tareas[i]);
        tareasCanceladas.add(i);
      }
      else
        {
          tareasFinalizadas.add(Sesion.tareas[i]);
          tareasFinalizadas.add(i);
        }
    }

    return

        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),

      Column(
        children: [
          if (usuarioPerfil != null) ...[
            SizedBox(
              height: 10,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
              Flexible(
                flex: 25,

    child:                Container(

      child: !(usuarioPerfil.foto is String)
          ? Column(
          children: [
            Text(
            'NINGUNA FOTO ELEGIDA ****',
            textAlign: TextAlign.center,
          ),ElevatedButton(
                onPressed: () {
                  dialogEditarFoto();
                  actualizar();
                },
                child: Icon(
                  Icons.edit,
                  color: GuardadoLocal.colores[2],
                  size: 40,
                ),
                style: ElevatedButton.styleFrom(shape: CircleBorder(

                )
                )
            ),])
          :

                CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(usuarioPerfil.foto),
                child:
                  Stack(
                  children: [
                    Container(
                      child: ElevatedButton(
                          onPressed: () {
                            dialogEditarFoto();
                            actualizar();
                          },
                          child: Icon(
                            Icons.edit,
                            color: GuardadoLocal.colores[2],
                            size: 40,
                          ),
                        style: ElevatedButton.styleFrom(shape: CircleBorder(

                        )
                        )
                      ),
                      alignment: Alignment.bottomRight,
                    )

                  ],
                  ),

                ),


                  ),


              ),

              Flexible(
                  flex: 50,
                  child: Column(children: [

                    SizedBox(
                      width: 500,
                      child:
                        TextButton(child:Text(usuarioPerfil.nombre.toUpperCase(),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                            onPressed:(){

                            }
                        ),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                  SizedBox(
                    width: 500,
                    child:
                    TextButton(child:Text(usuarioPerfil.apellidos.toUpperCase(),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                        onPressed:(){

                        }
                    ),
                  ),

              ],)),
                  ///BOTON DE LOCALIZACION

                  Flexible(
                    flex:25,
                    child:
                  ElevatedButton(onPressed: () async{
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Localizacion()));
                    Sesion.paginaActual = this;
                    actualizar();

                  }, child: Image.asset('assets/mapa.png',

                    width: 140,
                    height: 100,
                  )),
                  )

            ]),


            Text('FECHA DE NACIMIENTO:'),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children:[
              Text(usuarioPerfil.fechanacimiento),
              SizedBox(width: 20,),
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
                  child:
                    Image.asset("assets/calendario.png",
                      width: 50,
                      height: 50,),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: GuardadoLocal.colores[0])),

            ]),

            SizedBox(
              height: 15,
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

                ]
              ],
            ),

            SizedBox(height: 15),




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


              if(tareasFinalizadas.length != 0)...[
                Text("\nTAREAS FINALIZADAS: ",style: TextStyle(fontFamily:"Escolar",fontSize: 30,color: GuardadoLocal.colores[0])),
                visualizarTareaLista("finalizada")
              ],

              if(tareasSinFinalizar.length == 0 && tareasCompletadas.length == 0 && tareasCanceladas.length == 0 && tareasFinalizadas.length == 0)...[
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
          SizedBox(height: 10,)
        ],
      );
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
    else if(condicion == "cancelada")
      {
        listaIterar = tareasCanceladas;
      }
    else
      {
        listaIterar = tareasFinalizadas;
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


  dialogEditarFoto()
  {
    showDialog( context: context,
        builder: (context)
    {
      return Dialog(
        alignment: Alignment.center,
        child:Row(

            children:[
                ElevatedButton(
                    child: Image.asset(
                      "assets/camara.png",
                      width: 100,
                      height: 100,
                    ),
                    onPressed: () async{
                      var imagen = await seleccionarImagen(SeleccionImagen.camara);
                      await Sesion.db.editarFotoUsuario(usuarioPerfil.id, File(imagen.path));
                      actualizar();
                      Navigator.pop(context);

                    }),

         // Container(width: 10,alignment: Alignment.center,),

            ElevatedButton(
                child: Image.asset('assets/galeria.png',
                  width: 100,
                  height: 100,
                ),
                onPressed: () async{
                  var imagen = await seleccionarImagen(SeleccionImagen.galeria);
                  await Sesion.db.editarFotoUsuario(usuarioPerfil.id, File(imagen.path));
                  actualizar();
                  Navigator.pop(context);
                }),

        ])
      );
    }
    );
  }
}
