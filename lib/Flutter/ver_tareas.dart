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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import "package:image_picker/image_picker.dart";
import 'dart:async';

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

  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose() {
    for (int i = 0; i < Sesion.tareas.length; i++) {
      for (int j = 0; j < Sesion.tareas[i].controladoresVideo.length; j++) {
        Sesion.tareas[i].controladoresVideo[j].dispose();
      }
      Sesion.tareas[i].controladoresVideo.clear();
    }

    if(temporizador != null)
      temporizador.cancel();
    super.dispose();
  }

  // Inicializar antes de construir la página

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;

    Sesion.seleccion = "";
    Sesion.tareas = [];

    if (Sesion.rol == Rol.alumno.toString()) {
      print("Cargando tareas");
      cargarTareas();
    }
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {


    return new Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Tareas'),
      ),
      body: SingleChildScrollView(
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
    );
  }

  formatTiempoRestante()
  {

    if(Sesion.tareas[tareaActual].terminada || Sesion.tareas[tareaActual].fallida)
      {
        mensajeTemporizador = "";
        actualizar();
        return;
      }

      var tiempoRestante = DateTime.fromMillisecondsSinceEpoch(Sesion.tareas[tareaActual].fechafinal).difference(DateTime.now());
      mensajeTemporizador = "Te quedan: ";
      if(tiempoRestante.isNegative)
      {
        mensajeTemporizador = "Te has retrasado ";

      }

    var diasRestantes ;
    var horasRestantes ;
    var minutosRestantes ;
    var segundosRestantes ;



    diasRestantes = (tiempoRestante.inDays).abs();
    if(diasRestantes != 0)
      mensajeTemporizador += " " + diasRestantes.toString() + (diasRestantes > 1?" días": " día");

    horasRestantes = (tiempoRestante.inHours - tiempoRestante.inDays * 24).abs();
    if(horasRestantes != 0)
      mensajeTemporizador += " " + horasRestantes.toString() + (horasRestantes > 1?" horas": " hora");

    minutosRestantes = (tiempoRestante.inMinutes - tiempoRestante.inHours*60).abs();
    if(minutosRestantes != 0)
      mensajeTemporizador += " " + minutosRestantes.toString() + (minutosRestantes > 1 ? " minutos" : " minuto");

    segundosRestantes = (tiempoRestante.inSeconds- tiempoRestante.inMinutes*60).abs();
    if(segundosRestantes != 0)
      mensajeTemporizador += " " + segundosRestantes.toString() + (segundosRestantes > 1?" segundos": " segundo");



    temporizador = Timer(Duration(milliseconds: 1000),formatTiempoRestante);

    actualizar();
  }


  String formatoFechafinalizado(minutos)
  {
    if(minutos <= 2)
    {
      return "ahora mismo";
    }
    else if( minutos < 60)
    {
      return "hace " + (minutos~/1).toString() + " minutos";
    }
    else if(minutos >= 60 && minutos < 60*2)
    {
      return "hace " + (minutos~/60).toString() + " hora";
    }
    else if( minutos < 24*60)
    {
      return "hace " + (minutos~/60).toString() + " horas";
    }
    else if(minutos < 2*24*60)
    {
      return "hace " + ((minutos~/60)~/24).toString() + " día";
    }
    else
    {
      return  "hace " + ((minutos~/60)~/24).toString() + " días";
    }
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {


    if (Sesion.tareas.length > 0)
      {

        if(temporizador == null)
          {
            print("inicializacion formatTiempoRestante");
            temporizador = "";
            formatTiempoRestante();
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
              child: Text(

                //"${"\nTareas de: " + Sesion.nombre + "\n"}",
                //DateFormat('d/M/y HH:mm').format(DateTime.fromMillisecondsSinceEpoch(Sesion.tareas[tareaActual].fechafinal)).toString(),
                mensajeTemporizador,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),

          ],
        ),
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
                                onPressed: () {
                                  if (tareaActual > 0) {
                                    tareaActual--;
                                    mostrarBotones = !Sesion.tareas[tareaActual].terminada && !Sesion.tareas[tareaActual].fallida;
                                    formatTiempoRestante();
                                    verFlechaDerecha = true;
                                  }
                                  verFlechaIzquierda = tareaActual != 0;

                                  actualizar();
                                },
                                child: const Icon(Icons.arrow_left)),
                                visible: verFlechaIzquierda,
                          ),


                      )),

              ///CONTENEDOR DE LA TAREA

              Flexible(
                  flex: 40,
                   child:Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2),
                        color: Color.fromRGBO(143, 125, 178, 1)),
                    child: Column(children: [
                      if (Sesion.tareas.length > 0) ...[
                        Center(
                            child: Text(
                          "\n" + Sesion.tareas[tareaActual].nombre + "\n",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        )),
                        resetIndicesTarea(),
                        for (int j = 0;
                            j < Sesion.tareas[tareaActual].orden.length;
                            j++)
                          LecturaTarea(
                              Sesion.tareas[tareaActual].orden[j], tareaActual)
                      ] else ...[
                        Text("BIEN. No tienes tareas que hacer")
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
                                onPressed: () {
                                  if (tareaActual < Sesion.tareas.length) {
                                    tareaActual++;
                                    mostrarBotones = !Sesion.tareas[tareaActual].terminada && !Sesion.tareas[tareaActual].fallida;
                                    formatTiempoRestante();
                                    verFlechaIzquierda = true;
                                  }

                                  verFlechaDerecha =
                                      (tareaActual != Sesion.tareas.length - 1);

                                  actualizar();
                                },
                                child: const Icon(Icons.arrow_right)),
                              visible: verFlechaDerecha,
                          ),

                      ))
            ]),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

          Visibility(
              visible: !Sesion.tareas[tareaActual].fallida && !Sesion.tareas[tareaActual].terminada && mostrarBotones,
              child:
              FloatingActionButton(
                  child:Icon(Icons.cancel_outlined),
                  onPressed: (){

                    base.fallarTarea(Sesion.tareas[tareaActual].idRelacion);
                    mostrarBotones = false;
                    actualizar();

                  })),

          Visibility(
              visible: !Sesion.tareas[tareaActual].terminada && !Sesion.tareas[tareaActual].fallida && mostrarBotones,
              child:
              FloatingActionButton(
                  child:Icon(Icons.check),
                  onPressed: (){

                    base.completarTarea(Sesion.tareas[tareaActual].idRelacion);
                    mostrarBotones = false;
                    actualizar();

                  })),



        ],),


        Visibility(
            visible: Sesion.tareas[tareaActual].terminada,
            child:Text("Tarea terminada " + formatoFechafinalizado(Sesion.tareas[tareaActual].fechaentrega) + " :)"),
        ),

        Visibility(
          visible: Sesion.tareas[tareaActual].fallida,
          child:Text("Tarea sin poder completar :("),
        )

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
                    child:
                        Center(child: Text("No tienes ninguna Tarea Asignada")))
              ],
            ))
      ]
    ]);
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return Container();
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
                color: Colors.white,
              )));
    } else if (valor == "I" &&
        Sesion.tareas[i].imagenes.length > indiceImagenes) {
      String pathImagen = Sesion.tareas[i].imagenes[indiceImagenes];
      indiceImagenes++;

      return Container(
          decoration: BoxDecoration(border: Border.all(width: 2)),
          margin: EdgeInsets.only(bottom: 15),
          child: Image.network(pathImagen, width: 200, height: 200));
    } else if (valor == "V" && Sesion.tareas[i].controladoresVideo.length > 0) {
      return Container(
          decoration: BoxDecoration(border: Border.all(width: 2)),
          margin: EdgeInsets.only(bottom: 15),
          width: 200,
          height: 200,
          child: ReproductorVideo(
              Sesion.tareas[i].controladoresVideo[indiceVideos++]));
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

  // Widget que se encarga de construir un reproductor de video
  Widget ReproductorVideo(controlador) {
    /*
    if(controlador.value.position == controlador.value.duration)
      {
        print("fin del video");
        controlador.seekTo(Duration(minutes:0,seconds:0,milliseconds: 0));
        controlador.pause();
      }*/
    return ElevatedButton(
        onPressed: () {
          if (controlador.value.isPlaying) {
            controlador.pause();
          } else {
            controlador.play();
          }
          setState(() {});
        },
        child: Container(
            margin: EdgeInsets.only(top: 10),
            child: Column(children: [
              AspectRatio(
                  aspectRatio: 12.0 / 9.0, child: VideoPlayer(controlador)),
              Icon(
                controlador.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 20,
                semanticLabel:
                    controlador.value.isPlaying ? "Pausa" : "Reanudar",
              ),
              Container(
                //duration of video
                child: Text(
                    "Total Duration: " + controlador.value.duration.toString()),
              ),
            ])));
  }

  // Accede a las tareas de la base de datos
  cargarTareas() async {
    await base.consultarTareasAsignadasAlumno(Sesion.id, true);
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
    if (Sesion.tareas.length > 1 && tareaActual == 0) {
      verFlechaDerecha = true;
    }
    if(tareaActual >= Sesion.tareas.length && Sesion.tareas.length > 0)
    {
      tareaActual = Sesion.tareas.length - 1;
      formatTiempoRestante();
    }
    setState(() {});
  }
}
