/*
*   Archivo: ver_tareas.dart
*
*   Descripción:
*   Pagina que consulta el alumno para ver la lista de tareas pendientes
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   video_player.dart : Necesario para cargar los videos del storage y cargarlos en el controlador de los reproductores de video. 
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   image_picker.dart : Libreria para acceder a la cámara y a la galería de imagenes del dispositivo.
* */

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:colegio_especial_dgp/Flutter/reproductor_video.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import "package:image_picker/image_picker.dart";
import 'dart:async';
import 'package:share_plus/share_plus.dart';


import 'package:http/http.dart' as http;
import 'dart:convert';

//Función para mandar un email.
Future sendEmail(String name, String email,String subject, String message) async {
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  const serviceId = 'servicioCorreo';
  const templateId = 'template_xxh3jhv';
  const userId = '2wgqbl0rcKfvIgaCQ';
  final response = await http.post(url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json'
      }, //This line makes sure it works for all platforms.
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': email,
          'message': message,
          'subject' : subject
        }
      }));
  return response.body;
}


class VerTareas extends StatefulWidget {
  @override
  VerTareasState createState() => VerTareasState();
}

// Clase que construye la pagina
class VerTareasState extends State<VerTareas> {
  var msg = "null";
  var imagen = null;
  var video = null;
  var alumnos = [];
  var fotoTomada;
  var mostrarBotones = true;

  ImagePicker capturador = new ImagePicker();

  var registrando = false;
  var mensajeDeRegistro = "";

  var indiceTextos = 0;
  var indiceImagenes = 0;
  var indiceVideos = 0;
  int tareaActual = 0;

  var iconoAtras = Icons.home;

  double offSetActual = 0;
  ScrollController homeController = new ScrollController();
  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();

  var controladoresVideo = [];

  var lenguajes;

  bool verFlechaIzquierda = false;
  bool verFlechaDerecha = false;
  var temporizador = null;
  var mensajeTemporizador = "";
  var controladorTemporizador = StreamController();

  var indiceComanda = 0;

  tomarFoto() async
  {
    fotoTomada = await capturador.pickImage(
      source: ImageSource.camera,
      imageQuality: 15,
    );
    return fotoTomada;
  }

  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose() {
    for (int i = 0; i < Sesion.tareas.length; i++) {
      for (int j = 0; j < Sesion.tareas[i].controladoresVideo.length; j++) {
        if( Sesion.tareas[i].controladoresVideo[j] != 0)
        Sesion.tareas[i].controladoresVideo[j].dispose();

      }
      //Sesion.tareas[i].controladoresVideo.clear();
    }

    Sesion.db.desactivarSubscripcion();
    if (temporizador != null) {
      temporizador.cancel();
      temporizador = false;
    }

    super.dispose();
  }

  // Inicializar antes de construir la página

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;

    Sesion.tareas = [];


    enfocarTarea();
    if (Sesion.rol == Rol.alumno.toString()) {
      print("Cargando tareas");
      cargarTareas(Sesion.id);
    } else {
      cargarTareas(Sesion.seleccion.id);
    }
  }

  void enfocarTarea()
  {
    if (Sesion.argumentos.length == 1) {
      tareaActual = Sesion.argumentos[0];
      iconoAtras = Icons.arrow_back;
      if(tareaActual == Sesion.tareas.length -1)
        verFlechaDerecha = false;
      Sesion.argumentos = [];
    }
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    var dragInicial = 0.0;
    var distancia = 0.0;

    return new Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(iconoAtras, color: GuardadoLocal.colores[2]),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Center(
                  child: Text('Tareas de ' +
                      (Sesion.rol == Rol.alumno.toString()
                          ? Sesion.nombre
                          : Sesion.seleccion.nombre),style: TextStyle(color: GuardadoLocal.colores[2]),)),
            ),
            body: GestureDetector(
              onPanStart: (DragStartDetails details) {
                dragInicial = details.globalPosition.dx;
              },
              onPanUpdate: (details) {
                distancia = details.globalPosition.dx - dragInicial;
              },
              onPanEnd: (details) {
                dragInicial = 0;
                if (Sesion.tareas.length > 0) {
                  if (distancia > 100) {
                    desplazarIzquierda();
                    actualizar();
                  } else if (distancia < -100) {
                    desplazarDerecha();
                    actualizar();
                  }
                }
              },
              child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Stack(
                    children: [
                      if (Sesion.rol == Rol.alumno.toString()) ...[
                        VistaAlumno(),
                      ] else if (Sesion.rol == Rol.profesor.toString()) ...[
                        VistaProfesor()
                      ] else if (Sesion.rol == Rol.administrador.toString()) ...[
                        VistaAdministrador()
                      ] else if (Sesion.rol == Rol.programador.toString()) ...[
                        VistaProgramador()
                      ]
                    ],
                  )),
            ));
  }

  formatTiempoRestante() {
    if (Sesion.tareas[tareaActual].estado != "sinFinalizar") {
      mensajeTemporizador = "";
      temporizador.cancel();

      actualizar();
      return;
    }

    var tiempoRestante = DateTime.fromMillisecondsSinceEpoch(
            Sesion.tareas[tareaActual].fechafinal)
        .difference(DateTime.now());
    mensajeTemporizador = "Quedan: ";
    if (tiempoRestante.isNegative) {
      mensajeTemporizador = "Tarea retrasada ";
    }

    var diasRestantes;
    var horasRestantes;
    var minutosRestantes;
    var segundosRestantes;

    diasRestantes = (tiempoRestante.inDays).abs();
    if (diasRestantes != 0)
      mensajeTemporizador += " " +
          diasRestantes.toString() +
          (diasRestantes > 1 ? " días" : " día");

    horasRestantes =
        (tiempoRestante.inHours - tiempoRestante.inDays * 24).abs();
    if (horasRestantes != 0)
      mensajeTemporizador += " " +
          horasRestantes.toString() +
          (horasRestantes > 1 ? " horas" : " hora");

    minutosRestantes =
        (tiempoRestante.inMinutes - tiempoRestante.inHours * 60).abs();
    if (minutosRestantes != 0)
      mensajeTemporizador += " " +
          minutosRestantes.toString() +
          (minutosRestantes > 1 ? " minutos" : " minuto");

    segundosRestantes =
        (tiempoRestante.inSeconds - tiempoRestante.inMinutes * 60).abs();
    if (segundosRestantes != 0)
      mensajeTemporizador += " " +
          segundosRestantes.toString() +
          (segundosRestantes > 1 ? " segundos" : " segundo");

    controladorTemporizador.add("");
  }

  String formatoFechafinalizado(minutos) {
    if (Sesion.tareas[tareaActual].estado == "sinFinalizar") return "";

    if (minutos <= 2) {
      return "ahora mismo";
    } else if (minutos < 60) {
      return "hace " + (minutos ~/ 1).toString() + " minutos";
    } else if (minutos >= 60 && minutos < 60 * 2) {
      return "hace " + (minutos ~/ 60).toString() + " hora";
    } else if (minutos < 24 * 60) {
      return "hace " + (minutos ~/ 60).toString() + " horas";
    } else if (minutos < 2 * 24 * 60) {
      return "hace " + ((minutos ~/ 60) ~/ 24).toString() + " día";
    } else {
      return "hace " + ((minutos ~/ 60) ~/ 24).toString() + " días";
    }
  }

  desplazarDerecha() {
    if (tareaActual < Sesion.tareas.length - 1) {
      tareaActual++;
      mostrarBotones = Sesion.tareas[tareaActual].estado == "sinFinalizar";
      formatTiempoRestante();
      verFlechaIzquierda = true;
      temporizador.cancel();
      temporizador = null;
    }

    verFlechaDerecha = (tareaActual != Sesion.tareas.length - 1);
  }

  desplazarIzquierda() {
    if (tareaActual > 0) {
      tareaActual--;
      mostrarBotones = Sesion.tareas[tareaActual].estado == "sinFinalizar";
      formatTiempoRestante();
      verFlechaDerecha = true;
      temporizador.cancel();
      temporizador = null;
    }
    verFlechaIzquierda = tareaActual != 0;
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return VistaAlumno();
  }




  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    if (Sesion.tareas.length > 0) {
      if (temporizador == null) {
        print("inicializacion formatTiempoRestante");
        temporizador = Timer.periodic(Duration(seconds: 1), (timer) {
          formatTiempoRestante();
        });

        ;
      }
    }

    return Column(children: <Widget>[
      if (Sesion.tareas.length > 0) ...[
        Wrap(
          //ROW 2
          alignment: WrapAlignment.end,
          //spacing: 800,
          children: [



              Container(
              child:
              StreamBuilder(
                stream:controladorTemporizador.stream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return
                    Text(
                    "\n" + mensajeTemporizador + "\n",
                    //DateFormat('d/M/y HH:mm').format(DateTime.fromMillisecondsSinceEpoch(Sesion.tareas[tareaActual].fechafinal)).toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    color: GuardadoLocal.colores[0],
                    fontSize: 20.0,
                  ),
                );
              },

              )

              ),
              ///TEXTO DE RETROALIMENTACIÓN DE LA APP CUANDO SE TERMINA UNA TAREA
              Visibility(
              visible: Sesion.tareas[tareaActual].estado == "completada",
              child: Text("\nTarea terminada " +
              formatoFechafinalizado(Sesion.tareas[tareaActual].fechaentrega) +
              " :)"),
              ),
              Visibility(
              visible: Sesion.tareas[tareaActual].estado == "cancelada",
              child: Text("\nTarea sin poder completar :("),
              ),

          ]


            ),

            if(Sesion.rol != Rol.alumno.toString() && Sesion.tareas[tareaActual].estado != "sinFinalizar" && Sesion.tareas[tareaActual].formularios.length > 4)...[
                ElevatedButton(onPressed: (){
                  var mensaje = "";
                  Map contador = new Map();

                          for (int i = 0; i < Sesion.tareas[tareaActual].formularios.length; i = i + 2 + (Sesion.tareas[tareaActual].formularios[i + 1] as int) * 3)
                            {
                              mensaje += Sesion.tareas[tareaActual].formularios[i] + "\n";
                              for (int j = i + 2; j < i + 2 + (Sesion.tareas[tareaActual].formularios[i + 1] as int) * 3; j = j + 3)
                                {

                                  mensaje += "   "+ Sesion.tareas[tareaActual].formularios[j].toString() + " : " + Sesion.tareas[tareaActual].formularios[j+2].toString() + "\n";

                                  var index = contador.containsKey(Sesion.tareas[tareaActual].formularios[j].toString());

                                  var valor = Sesion.tareas[tareaActual].formularios[j+2];
                                  if(valor is String )
                                    {
                                      valor = int.parse(valor);
                                    }

                                  if(index)
                                    {
                                      contador[Sesion.tareas[tareaActual].formularios[j].toString()] += valor;
                                    }
                                  else
                                    {
                                      contador[Sesion.tareas[tareaActual].formularios[j].toString()] = valor;

                                    }
                                }

                            }

                          mensaje+="\nTotal:\n";


                          contador.forEach((key, value) {
                            mensaje += "   "+key.toString() + " : " + value.toString()+ "\n";
                          });



                      Share.share(mensaje);

                    //dialogCorreo(mensaje);
                   }, child: Column(children: [
                      Text('\nEnviar'),
                      Image.asset(
                      "assets/enviarunemail.png",
                      height: 100,
                      width: 100,
                      )
                      ]))
            ],

        Row(
            //ROW 2
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ///FLECHA IZQUIERDA
              Container(
                  height: 60,
                  width: 60,
                  margin: EdgeInsets.only(top: 100.0, left: 10.0, right: 10),
                  child: FittedBox(
                    child: Visibility(
                      child: FloatingActionButton(
                          heroTag: "flechaIzquierda",
                          onPressed: () {
                            desplazarIzquierda();
                            actualizar();
                          },
                          child: Icon(Icons.arrow_left,color: GuardadoLocal.colores[2],)),
                      visible: verFlechaIzquierda,
                    ),
                  )),



              ///CONTENEDOR DE LA TAREA
              Flexible(
                  flex: 40,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2,color: GuardadoLocal.colores[2]),
                        color: GuardadoLocal.colores[0]),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (Sesion.tareas.length > 0) ...[

                            Center(
                                child: Text(
                              "\n" + Sesion.tareas[tareaActual].nombre + "\n",
                              style:  TextStyle(
                                color: GuardadoLocal.colores[2],
                              ),
                            )),
                            resetIndicesTarea(),
                            for (int j = 0;
                                j < Sesion.tareas[tareaActual].orden.length;
                                j++)
                              LecturaTarea(Sesion.tareas[tareaActual].orden[j],
                                  tareaActual),
                            if (Sesion.tareas[tareaActual].formularios !=
                                null && Sesion.tareas[tareaActual].formularios != []) ...[
                              for (int i = 0; i < Sesion.tareas[tareaActual].formularios.length; i = i + 2 + (Sesion.tareas[tareaActual].formularios[i + 1] as int) * 3)
                                Container(
                                    child: Column(
                                  children: [
                                    Text(Sesion
                                        .tareas[tareaActual].formularios[i],style: TextStyle(color: GuardadoLocal.colores[2]),),
                                    for (int j = i + 2; j < i + 2 + (Sesion.tareas[tareaActual].formularios[i + 1] as int) * 3; j = j + 3)
                                      comanda(j)
                                  ],
                                ))
                            ]
                          ]
                        ]),
                  )),

              ///FLECHA DERECHA
              Container(
                  height: 60,
                  width: 60,
                  margin: EdgeInsets.only(top: 100.0, left: 10.0, right: 10),
                  child: FittedBox(
                    child: Visibility(
                      child: FloatingActionButton(
                          heroTag: "flechaDerecha",
                          onPressed: () {
                            desplazarDerecha();
                            actualizar();
                          },
                          child:  Icon(Icons.arrow_right,color: GuardadoLocal.colores[2],)),
                      visible: verFlechaDerecha,
                    ),
                  ))
            ]),
        if (Sesion.rol == Rol.alumno.toString()) ...[
          ///BOTONES DE COMPLETAR O RECHAZAR TAREA QUE VE SOLO EL ALUMNO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                  visible:
                      Sesion.tareas[tareaActual].estado == "sinFinalizar" &&
                          mostrarBotones,
                  child: Container(
                      margin: EdgeInsets.all(15),
                      width: 150,
                      height: 150,
                      child: FloatingActionButton(
                          heroTag: "Cancelar tarea",
                          child: Image.asset(
                            "assets/tachar.png",
                            height: 100,
                            width: 100,
                          ),
                          onPressed: () {
                            dialogCompletarTarea(false);
                          }))),
              Visibility(
                visible: Sesion.tareas[tareaActual].estado == "sinFinalizar" &&
                    mostrarBotones,
                child: Container(
                  margin: EdgeInsets.all(15),
                  width: 150,
                  height: 150,
                  child: FloatingActionButton(
                      heroTag: "aceptarTarea",
                      child: Image.asset(
                        "assets/correcto.png",
                        height: 100,
                        width: 100,
                      ),
                      onPressed: () {
                        dialogCompletarTarea(true);
                      }),
                ),
              ),
            ],
          ),
        ],

        ///COMENTARIO DEL ALUMNO AL TERMINAR LA TAREA
        Visibility(
          visible: Sesion.tareas[tareaActual].respuesta != "",
          child: Column(children: [
            Text(
              "\nComentario de " +
                  (Sesion.rol == Rol.alumno.toString()
                      ? Sesion.nombre + ":\n"
                      : Sesion.seleccion.nombre + ":\n"),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(Sesion.tareas[tareaActual].respuesta ),
            if(Sesion.tareas[tareaActual].fotoRespuesta != "")...
              [
                Image.network(Sesion.tareas[tareaActual].fotoRespuesta,width: 200,height: 200,)
              ]


          ]),
        ),

        /// RETROALIMENTACIÓN DEL PROFESOR
        Visibility(
          visible: Sesion.tareas[tareaActual].retroalimentacion != "",
          child: Column(children: [
            Text("\n Retroalimentacion: \n",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(Sesion.tareas[tareaActual].retroalimentacion + "\n")
          ]),
        ),
        if (Sesion.rol != Rol.alumno.toString()) ...[
          Visibility(
              visible: Sesion.tareas[tareaActual].estado != "sinFinalizar",
              child: ElevatedButton(
                onPressed: () {
                  dialogRetroalimentacion();
                },
                child: Text((Sesion.tareas[tareaActual].retroalimentacion != ""
                    ? "Editar retroalimentación"
                    : "Enviar retroalimentación").toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[2])),
              )),

        ],

        Visibility(
          visible: Sesion.tareas[tareaActual].estado != "sinFinalizar",
          child: ElevatedButton(
              onPressed: () {
                Sesion.db.resetTarea(Sesion.tareas[tareaActual].idRelacion);
              },
              child: Text("Reinicia la tarea".toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[2]),)),
        ),
      ] else ...[
        Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(border: Border.all(width: 2)),
                    child: Center(
                        child: Text("¡¡¡Bien!!!  \nNo tienes ninguna tarea")))
              ],
            ))
      ]
    ]);
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return VistaProfesor();
  }

  // Este metodo itera sobre las tareas que tiene el usuario y las muestra
  Widget LecturaTarea(String valor, i) {

    if (valor == "T" && Sesion.tareas[i].textos.length > indiceTextos) {
      String pathTexto = Sesion.tareas[i].textos[indiceTextos];
      indiceTextos++;
      return Center(
          child: Text(pathTexto + "\n",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GuardadoLocal.colores[2],
              )));
    } else if (valor == "I" &&
        Sesion.tareas[i].imagenes.length > indiceImagenes) {
      String pathImagen = Sesion.tareas[i].imagenes[indiceImagenes];
      indiceImagenes++;

      return Container(
          decoration: BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[2])),
          margin: EdgeInsets.only(bottom: 15),
          child: Image.network(pathImagen, width: 200, height: 200));

    } else if (valor == "V" && Sesion.tareas[i].controladoresVideo.length > 0) {
      var indice = indiceVideos;
      indiceVideos++;
      return Container(
          decoration: BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[2])),
          margin: EdgeInsets.only(bottom: 15),
          child: ElevatedButton(
            onPressed: (){
              if(Sesion.tareas[i].controladoresVideo[indice] == 0 )
                {
                  var nuevoControlador = VideoPlayerController.network(
                      Sesion.tareas[i].videos[indice]);
                  Sesion.tareas[i].controladoresVideo[indice] = nuevoControlador;
                  Sesion.tareas[i].controladoresVideo[indice].initialize();
                }

              ventanaVideo(
                  Sesion.tareas[i].controladoresVideo[indice],context);
            },
              child:Text("ver video".toUpperCase(),style: TextStyle(fontSize:25, color: GuardadoLocal.colores[2]),)
            ),

          );
    } else
      return Container();
  }

  // Vista del programador sin uso
  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  // Accede a las tareas de la base de datos
  cargarTareas(id) async {
    await Sesion.db.consultarTareasAsignadasAlumno(id, true);
  }

  // Muestra la vista en horizontal
  buildLandscape() {
    return SingleChildScrollView(
      controller: homeController,
      child: VistaTareas(),
    );
  }

  // Muestra la vista en vertical
  buildPortrait() {
    return SingleChildScrollView(
      controller: homeController,
      child: VistaTareas(),
    );
  }

  // Muestra las tareas segun el rol del usuario
  VistaTareas() {
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

  // Cada vez que se cambia de tarea, hay que resetear los indices
  Widget resetIndicesTarea() {
    indiceImagenes = 0;
    indiceTextos = 0;
    indiceVideos = 0;

    return Container();
  }

  // Actualizar la pagina
  void actualizar() async {
    //print("nueva actualización");
    indiceComanda = 0;
    if (Sesion.tareas.length > 1 && tareaActual == 0) {
      verFlechaDerecha = true;
    } else if (Sesion.tareas.length > 2 &&
        tareaActual > 0 &&
        tareaActual < Sesion.tareas.length - 1) {
      verFlechaIzquierda = true;
      verFlechaDerecha = true;
    } else if (Sesion.tareas.length > 1 &&
        tareaActual == Sesion.tareas.length - 1) {
      verFlechaIzquierda = true;
    }

    if (tareaActual >= Sesion.tareas.length && Sesion.tareas.length > 0) {
      tareaActual = Sesion.tareas.length - 1;
      formatTiempoRestante();
    }


    if (!mounted) return;
    setState(() {});
  }

  dialogCompletarTarea(estado) {
    var controladorRespuesta = TextEditingController();
    var controladorStream = StreamController();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(children: [
              Text("\nIntroduce un comentario opcional:"),
              TextField(
                minLines: 3,
                maxLines: 6,
                controller: controladorRespuesta,
              ),
              Text("\Envia una foto (opcional):"),
              ElevatedButton(onPressed: () async{
                await tomarFoto();
                controladorStream.add("");

              }, child: Column(children: [
                Text("Tomar foto"),
                Icon(Icons.camera_alt_outlined)
                
              ],)),

              StreamBuilder(stream: controladorStream.stream,builder: (context,snapshot){
                return fotoTomada==null?Container(width: 100,height: 100):Container(width: 200,height: 200,child:Image.file(File(fotoTomada.path)),);
              }),



              Text("\nSeguro que quieres " +
                  (estado ? "terminar" : "cancelar") +
                  " la tarea"),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: () {

                          Navigator.pop(context);
                        },
                        child: Column(children: [
                          Text('\nNo'),
                          Image.asset(
                            "assets/no.png",
                            height: 100,
                            width: 100,
                          )
                        ]))),
                Container(
                  margin: EdgeInsets.all(10),
                  child: ElevatedButton(
                      onPressed: () {
                        if (estado) {
                          Sesion.db.updateComanda(
                              Sesion.tareas[tareaActual].idRelacion,
                              Sesion.tareas[tareaActual].formularios);
                          Sesion.db.completarTarea(
                              Sesion.tareas[tareaActual].idRelacion);
                        } else {
                          Sesion.db.fallarTarea(
                              Sesion.tareas[tareaActual].idRelacion);
                        }

                        if (controladorRespuesta.text != null) {
                          var file = null;
                          if(fotoTomada != null)
                            {
                              file = File(fotoTomada.path);
                            }
                          Sesion.db.addRespuestaTarea(
                              Sesion.tareas[tareaActual].idRelacion,
                              controladorRespuesta.text,file);
                        }

                        mostrarBotones = false;
                        actualizar();

                        Navigator.pop(context);
                      },
                      child: Column(children: [
                        Text('\nEnviar'),
                        Image.asset(
                          "assets/enviarunemail.png",
                          height: 100,
                          width: 100,
                        )
                      ])),
                )
              ])
            ]),
          );
        });
  }

  dialogRetroalimentacion() {
    var controlador = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: GuardadoLocal.colores[1],
            child: Column(children: [
              Text("\nIntroduce una realimentacion para el alumno:"),
              TextField(
                style: TextStyle(color: GuardadoLocal.colores[0]),
                decoration: InputDecoration(
                    enabledBorder:  OutlineInputBorder(
                      borderSide:  BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                    ),
                    border: OutlineInputBorder(),
                ),
                controller: controlador,
              ),
              Text("\nSeguro que quieres dar" + " esa realimentacion?"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Column(children: [
                            Text('\nSalir'.toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[2]),),
                            Image.asset(
                              "assets/cerrar.png",
                              height: 100,
                              width: 100,
                            )
                          ]))),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: () {
                          if (controlador.text != null) {
                            Sesion.db.addFeedbackTarea(
                                Sesion.tareas[tareaActual].idRelacion,
                                controlador.text);
                          }

                          actualizar();

                          Navigator.pop(context);
                        },
                        child: Column(children: [
                          Text('\nEnviar'.toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[2]),),
                          Image.asset(
                            "assets/enviarunemail.png",
                            height: 100,
                            width: 100,
                          )
                        ])),
                  )
                ],
              )
            ]),
          );
        });
  }

  Widget comanda(j) {
    var indice = indiceComanda;
    indiceComanda++;

    if(indice >= Sesion.tareas[tareaActual].controladoresComandas.length)
      {
        return Text("Error : se ha pasado el indice " + indice.toString() + " cuando el máximo es" + Sesion.tareas[tareaActual].controladoresComandas.length.toString());
      }

    return Container(
        decoration: BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[2])),
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(Sesion.tareas[tareaActual].formularios[j],style: TextStyle(color: GuardadoLocal.colores[2]),),
            ),
            Flexible(
              child: Container(
                  margin: EdgeInsets.only(right: 20, left: 10),
                  child: Image.network(
                    Sesion.tareas[tareaActual].formularios[j + 1],
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  )),
            ),
            if (Sesion.tareas[tareaActual].estado == "sinFinalizar") ...[
              Flexible(
                  child: Container(
                      margin: EdgeInsets.only(left: 20),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder:  OutlineInputBorder(
                          borderSide:  BorderSide(color: GuardadoLocal.colores[2], width: 0.0),
                        )),
                        style: TextStyle(color:GuardadoLocal.colores[2]),
                        textAlign: TextAlign.center,
                        controller: Sesion.tareas[tareaActual].controladoresComandas[indice],
                        keyboardType: TextInputType.number,
                        onChanged: (nuevoNumero) {
                          if (nuevoNumero == null) {
                            Sesion.tareas[tareaActual].formularios[j + 2] = 0;
                          } else {
                            Sesion.tareas[tareaActual].formularios[j + 2] =
                                nuevoNumero;
                          }

                          print(Sesion.tareas[tareaActual].formularios[j + 2]
                              .toString());
                        },
                      ))),

              Flexible(
                  child: Container(
                      decoration: BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[2])),
                      margin: EdgeInsets.only(left: 25),
                      child: ElevatedButton(
                        child: Icon(Icons.remove,color: GuardadoLocal.colores[2],),
                        onPressed: () {
                          var valor = Sesion.tareas[tareaActual].controladoresComandas[indice].text;

                          if(valor != "")
                              {
                                var num = int.parse(valor);
                                if(num > 0)
                                  {
                                    num--;
                                    Sesion.tareas[tareaActual].controladoresComandas[indice].text = num.toString();
                                    Sesion.tareas[tareaActual].formularios[j + 2] = num;

                                  }
                              }

                        },
                      ))),

              Flexible(
                  child: Container(
                      decoration: BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[2])),
                      margin: EdgeInsets.only(left: 25),
                      child: ElevatedButton(
                        child: Icon(Icons.add,color: GuardadoLocal.colores[2],),
                        onPressed: () {
                          var valor = Sesion.tareas[tareaActual].controladoresComandas[indice].text;
                          if(valor == "")
                            {
                              Sesion.tareas[tareaActual].controladoresComandas[indice].text = "1";
                              Sesion.tareas[tareaActual].formularios[j + 2] = 1;
                            }
                          else
                            {
                              var num = int.parse(valor);
                              num++;
                              Sesion.tareas[tareaActual].controladoresComandas[indice].text = num.toString();
                              Sesion.tareas[tareaActual].formularios[j + 2] = num;
                            }


                        },
                      ))),

            ] else ...[
              Flexible(
                  child: Text(Sesion.tareas[tareaActual].formularios[j + 2]
                      .toString(),style: TextStyle(color: GuardadoLocal.colores[2]),)),
            ]
          ],
        ));
  }



  dialogCorreo(mensaje)
  {
    var controladorAsunto = TextEditingController();
    var controladorEnviar = TextEditingController();
    var controladorMensaje = TextEditingController();

        controladorMensaje.text = mensaje;

    return showDialog(context: context, builder: (context){
        return Dialog(
          child:
              SingleChildScrollView(child:
          Column(
            children: [
              //Flexible(child: Row(children: [Text("Asunto:"),TextField(controller: controladorAsunto,)],) ),

              Text("Asunto:"),
              TextField(controller: controladorAsunto,),


              Text("Enviar a:"),
              TextField(controller: controladorEnviar,),

              Text("Mensaje:"),
              TextField(controller: controladorMensaje,minLines: 10,maxLines: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text("cancelar")),
                  ElevatedButton(onPressed: () async{


                      if(controladorEnviar.text != "" && controladorAsunto.text != "" && controladorMensaje.text != "")
                        {
                          await sendEmail("mochileros", controladorEnviar.text, controladorAsunto.text, controladorMensaje.text).then((e){
                            print(e);
                          });

                          Navigator.pop(context);
                        }
                      },

                      child: Text("enviar")),

                ],),
            ],
          ),
        )
        );
    });
  }
}
