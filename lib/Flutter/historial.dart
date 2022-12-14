import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_profesor.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_tarea.dart';
import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Flutter/search_tarea.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
/*
*   Archivo: lista_profesores.dart
*
*   Descripción:
*   Pagina para consultar la lista de profesores y acceder a sus perfiles
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   perfil_profesor.dart : Para acceder al perfil del profeosr
* */



class VerHistorial extends StatefulWidget {
  @override
  VerHistorialState createState() => VerHistorialState();
}

class VerHistorialState extends State<VerHistorial> {
  ScrollController homeController = new ScrollController();
  late Map<String,int> _charData = new Map();
  late List<DatosHist> _charDataList=[];
  var tareas = [];
  var retroalimentacion="";

  @override
  void initState() {
    super.initState();
    Sesion.tareas = [];
    cargarHistorial();
    Sesion.paginaActual = this;


  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Center(
              child: Text(
                'Historial'.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 30, fontWeight: FontWeight.bold),
              )),
        ),
        body: Stack(children: [
          OrientationBuilder(
            builder: (context, orientation) =>
            orientation == Orientation.portrait
                ? buildPortrait()
                : buildLandscape(),
          ),
        ]));
  }

  buildLandscape() {
    return SingleChildScrollView(
      controller: homeController,
      child: lista(),
    );
  }

  buildPortrait() {
    return SingleChildScrollView(
      controller: homeController,
      child: lista(),
    );
  }
  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return VistaAlumno();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    //Navigator.pop(context);
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 10),
      child: Column(
       children: [
         Container(
           child: SfCartesianChart(

             plotAreaBorderColor: GuardadoLocal.colores[0],
             title: ChartTitle(
               text: "HISTORIAL DE TAREAS COMPLETADAS",
               textStyle: TextStyle(
                 color: GuardadoLocal.colores[0],
                 fontFamily: "Escolar",
                   fontSize: 20,
                   fontWeight: FontWeight.bold
               )
             ),
             series: <ChartSeries>[
               ColumnSeries<DatosHist,String>(
                   dataSource: _charDataList,
                   xValueMapper: (DatosHist dato,_) => dato.tarea,
                   yValueMapper: (DatosHist hist,_) =>  hist.veces_realizada,
                   dataLabelSettings: DataLabelSettings(
                       textStyle:TextStyle(
                         color: GuardadoLocal.colores[0],
                       ),
                       isVisible: true
                   ),
                   borderRadius: BorderRadius.all(Radius.circular(15)),
                   color: GuardadoLocal.colores[0],
                   trackColor: GuardadoLocal.colores[0],
                   trackBorderColor: GuardadoLocal.colores[0],
               ),
             ],
             primaryXAxis: CategoryAxis(labelStyle: TextStyle(color: GuardadoLocal.colores[0], fontFamily: "Escolar", fontSize: 20,fontWeight: FontWeight.bold)),
             primaryYAxis: NumericAxis(labelStyle: TextStyle(color: GuardadoLocal.colores[0], fontFamily: "Escolar",fontSize: 20,fontWeight: FontWeight.bold), edgeLabelPlacement: EdgeLabelPlacement.shift),
           ),
         ),
           const Text(
             "RETROALIMENTACIÓN:\n",
               style: TextStyle(
                 decoration: TextDecoration.underline,
               ),
           ),
         Text(retroalimentacion)
       ],
      )
    );
  }

  void getChartData(){
    _charData.forEach((key, value) {
      _charDataList.add(DatosHist(key, value));
    });
  }

  // Metodo que carga las tareas del alumno
  cargarHistorial() async {
    var id = Sesion.rol == Rol.alumno.toString() ? Sesion.id : Sesion.seleccion.id;
    tareas = await Sesion.db.consultarTareasCompletas(id);
    log(tareas.toString());
    for (int i = 0; i < tareas.length; i++) {
      var valor = _charData[tareas[i].nombre.toString()];
      if(valor is int){
        _charData[tareas[i].nombre.toString()] = valor + 1;
        log("HA entrado en el if ${tareas[i].nombre.toString()}");
      }else{
        _charData[tareas[i].nombre.toString()] = 1;
        log("HA entrado en el else ${tareas[i].nombre.toString()}");
        log(_charData.length.toString());
      }
      valor = 0;

      var cadena;

      if(tareas[i].retroalimentacion.toString().isEmpty){
         cadena = tareas[i].nombre.toString().toUpperCase() + ": SIN RETROALIMENTACIÓN \n";
      }else{
         cadena = tareas[i].nombre.toString().toUpperCase() + ": " + tareas[i].retroalimentacion.toString().toUpperCase() + "\n";
      }
      retroalimentacion += cadena;
    }

    getChartData();
    actualizar();
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return VistaAlumno();
  }

  // Este metodo devuelve una lista con todos los profesores

  /*
  *
  * */

  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  // segun el tipo de usuario devuelve diferentes tipos de listas
  lista() {
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


  // metodo para actualizar la pagina
  void actualizar() async {
    setState(() {});

  }
}

class DatosHist{
  final String tarea;
  final int veces_realizada;

  DatosHist(this.tarea, this.veces_realizada);
}