/*
*   Archivo: tablon_comunicacion.dart
*
*   Descripción:
*   Tablón de comunicacion de los alumnos a profesores con botones que emiten sonidos con significado.
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   flutter_tts.dart : Convertir un string en audio
* */


import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:flutter/material.dart';
import "package:flutter_tts/flutter_tts.dart";

class TablonComunicacion extends StatefulWidget {
  @override
  TablonComunicacionState createState() => TablonComunicacionState();

}

class TablonComunicacionState extends State<TablonComunicacion> {
  bool verFlechaIzquierda = true;
  bool verFlechaDerecha = true;
  double offSetActual = 0;
  ScrollController homeController = new ScrollController();
  double offSetActual2 = 0;
  ScrollController homeController2 = new ScrollController();
  double offSetActual3 = 0;
  ScrollController homeController3 = new ScrollController();

  var tablon;
  var frase = "";
  var hablar = true;
  var lenguajes;

  FlutterTts tts = new FlutterTts();

  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {

    super.initState();

    Sesion.paginaActual = this;

    Sesion.seleccion = "";
    inicializar();

    initTTS();
  }

  // Este metodo inicializa el text to speech con sus caracteristicas
  void initTTS() async {
    lenguajes = List<String>.from(await tts.getLanguages);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    await tts.setLanguage("es-ES");
    actualizar();
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
            onPressed: (){Navigator.pop(context);}),
        title: Center(child: Text('TABLÓN DE COMUNICACIÓN',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: GuardadoLocal.colores[2],fontSize: 30),),
      )),
      body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Column(
                children: [

                  cargando(),
                ],
              ))),
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    return Column(children: [
      SizedBox(
        height: 10,
      ),
      Stack(alignment: Alignment.center, children: [
        SingleChildScrollView(
          controller: homeController,
          scrollDirection: Axis.horizontal,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  for (int i = 0; i < tablon.length; i++)
                    //TAREA
                    if(tablon[i].tipos == "sustantivo")
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)))),
                          child: Container(
                            constraints:
                                BoxConstraints(maxWidth: 150, minWidth: 100),
                            width: 10,
                            margin: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.lightGreenAccent,
                                borderRadius: BorderRadius.circular(20)),
                            alignment: Alignment.center,
                            child: Column(children: [
                              Image(image: NetworkImage(tablon[i].imagenes)),
                              Text(
                                tablon[i].nombres.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                          ),
                          onPressed: () {
                            if(hablar == true){
                              _speak(tablon[i].nombres);
                            }
                            else{
                              frase += tablon[i].nombres+" ";
                            }
                          }),
                    ),
                ],
              )),
        ),
        Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.topLeft,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaIzquierda1",
                    onPressed: () {
                      offSetActual -= 100.0;
                      if (offSetActual <
                          homeController.position.minScrollExtent)
                        offSetActual = homeController.position.minScrollExtent;

                      homeController.animateTo(
                        offSetActual, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_left)),
                visible: verFlechaIzquierda,
              ),
            )),
        Container(
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.topRight,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaDerecha",
                    onPressed: () {
                      offSetActual += 100;

                      if (offSetActual >
                          homeController.position.maxScrollExtent)
                        offSetActual = homeController.position.maxScrollExtent;

                      homeController.animateTo(
                        offSetActual, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_right)),
                visible: verFlechaDerecha,
              ),
            )),
      ]),
      SizedBox(
        height: 10,
      ),
      Stack(alignment: Alignment.center, children: [
        SingleChildScrollView(
          controller: homeController2,
          scrollDirection: Axis.horizontal,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  for (int i = 0; i < tablon.length; i++)
                    //TAREA
                    if(tablon[i].tipos =="verbo")
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)))),
                          child: Container(
                            constraints:
                                BoxConstraints(maxWidth: 150, minWidth: 100),
                            width: 10,
                            margin: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.lightGreenAccent,
                                borderRadius: BorderRadius.circular(20)),
                            alignment: Alignment.center,
                            child: Column(children: [
                              Image(image: NetworkImage(tablon[i].imagenes)),
                              Text(
                                tablon[i].nombres.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                          ),
                          onPressed: () {
                            if(hablar == true){
                              _speak(tablon[i].nombres);
                            }
                            else{
                              frase += tablon[i].nombres+" ";
                            }
                          }),
                    ),
                ],
              )),
        ),
        Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.topLeft,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaIzquierda2",
                    onPressed: () {
                      offSetActual2 -= 100.0;
                      if (offSetActual2 <
                          homeController2.position.minScrollExtent)
                        offSetActual2 =
                            homeController2.position.minScrollExtent;

                      homeController2.animateTo(
                        offSetActual2, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_left)),
                visible: verFlechaIzquierda,
              ),
            )),
        Container(
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.topRight,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaDerecha2",
                    onPressed: () {
                      offSetActual2 += 100;

                      if (offSetActual2 >
                          homeController2.position.maxScrollExtent)
                        offSetActual2 =
                            homeController2.position.maxScrollExtent;

                      homeController2.animateTo(
                        offSetActual2, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_right)),
                visible: verFlechaDerecha,
              ),
            )),
      ]),
      SizedBox(
        height: 10,
      ),
      Stack(alignment: Alignment.center, children: [
        SingleChildScrollView(
          controller: homeController3,
          scrollDirection: Axis.horizontal,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  for (int i = 0; i < tablon.length; i++)
                    //TAREA
                    if(tablon[i].tipos == "adjetivo")
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)))),
                          child: Container(
                            constraints:
                                BoxConstraints(maxWidth: 150, minWidth: 100),
                            width: 10,
                            margin: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.lightGreenAccent,
                                borderRadius: BorderRadius.circular(20)),
                            alignment: Alignment.center,
                            child: Column(children: [
                              Image(image: NetworkImage(tablon[i].imagenes)),
                              Text(
                                tablon[i].nombres.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                          ),
                          onPressed: () {
                            if(hablar == true){
                              _speak(tablon[i].nombres);
                            }
                            else{
                              frase += tablon[i].nombres+" ";
                            }
                          }),
                    ),
                ],
              )),
        ),
        Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.topLeft,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaIzquierda3",
                    onPressed: () {
                      offSetActual3 -= 100.0;
                      if (offSetActual3 <
                          homeController3.position.minScrollExtent)
                        offSetActual3 =
                            homeController3.position.minScrollExtent;

                      homeController3.animateTo(
                        offSetActual3, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_left)),
                visible: verFlechaIzquierda,
              ),
            )),
        Container(
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.topRight,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaDerecha3",
                    onPressed: () {
                      offSetActual3 += 100;

                      if (offSetActual3 >
                          homeController3.position.maxScrollExtent)
                        offSetActual3 =
                            homeController3.position.maxScrollExtent;

                      homeController3.animateTo(
                        offSetActual3, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_right)),
                visible: verFlechaDerecha,
              ),
            )),
      ]),
      SizedBox(
        height: 10,
      ),
      Stack(alignment: Alignment.center, children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(18.0)))),
                            child: Container(
                              constraints:
                              BoxConstraints(maxWidth: 150, minWidth: 100),
                              width: 10,
                              margin: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.lightGreenAccent,
                                  borderRadius: BorderRadius.circular(20)),
                              alignment: Alignment.center,
                              child: Column(children: [
                                Image.asset('assets/frase.png'),
                                Text(
                                  "Crear Frase".toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ]),
                            ),
                            onPressed: () {
                              _speak("CREAR frase");
                              hablar = false;
                            }),
                      ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(18.0)))),
                        child: Container(
                          constraints:
                          BoxConstraints(maxWidth: 150, minWidth: 100),
                          width: 10,
                          margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.lightGreenAccent,
                              borderRadius: BorderRadius.circular(20)),
                          alignment: Alignment.center,
                          child: Column(children: [
                            Image.asset('assets/hablar.png'),
                            Text(
                              "Decir Frase".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            ),
                          ]),
                        ),
                        onPressed: () {
                          _speak(frase);
                          hablar = true;
                          frase = "";
                        }),
                  ),
                ],
              )),
        ),
      ]),
    ]);
  }
  Widget cargando() {
    if (tablon == null)
      return Center(child:
        Text('\nCARGANDO EL TABLÓN',textAlign: TextAlign.center,),
      );
    else {
      return Vista();
    }
  }

  Vista()
  {
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
  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return Container();
  }

  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  inicializar() async
  {

    tablon = await Sesion.db.consultarTodosTablon();

    actualizar();

  }
  // Este metodo actualiza la pagina
  void actualizar() async {
    setState(() {});
  }

  // Este metodo lee el texto y que se escuche por los altavoces
  void _speak(text) async {
    await tts.speak(text);
  }
}
