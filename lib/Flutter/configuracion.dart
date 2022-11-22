import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart";

import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:restart_app/restart_app.dart';

class Configuracion extends StatefulWidget {
  @override
  ConfiguracionState createState() => ConfiguracionState();
}

class ConfiguracionState extends State<Configuracion> {
  var posicion = null;
  Color p = GuardadoLocal.colores[0];
  Color b = GuardadoLocal.colores[1];
  Color l = GuardadoLocal.colores[2];

  @override
  initState() {
    super.initState();
    Sesion.paginaActual = this;

    obtenerPosicion();
  }

  Widget marcadorPersonal() {
    return CircleAvatar(
      radius: 56,
      backgroundColor: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(2), // Border radius
        child: ClipOval(child: Image.network(Sesion.foto)),
      ),
    );
  }

  obtenerPosicion() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    await Geolocator.getCurrentPosition().then((value) {
      posicion = value;
      print(
          posicion.latitude.toString() + "  " + posicion.longitude.toString());
      setState(() {});
    });
  }

  ventanaColores() async{
    //Ajusto el color de la ventana
    int marcosR = (255-GuardadoLocal.colores[0].red) as int;
    int marcosG =(255-GuardadoLocal.colores[0].green) as int;
    int marcosB =(255-GuardadoLocal.colores[0].blue) as int;
    Color marcos = Color.fromRGBO(marcosR, marcosG, marcosB, GuardadoLocal.colores[0].opacity);

    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: Container(
                decoration: BoxDecoration(
                    color: GuardadoLocal.colores[1],
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                padding: const EdgeInsets.all(10),
                child: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Color primario
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: Text('COLOR PRINCIPAL Y ELEMENTOS SOBRE FONDO: ',style: TextStyle(color: GuardadoLocal.colores[0]),),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(5),
                                padding:  const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                    color: marcos,
                                    shape: BoxShape.circle),
                                child: CircleAvatar(backgroundColor: p),),
                              ElevatedButton(onPressed: (){_elegirColor('p');}, child: Text('Cambiar color'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),))
                            ],
                          )
                        ],
                      ),
                      //Color fondo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child:Text('COLOR DE FONDO: ',style: TextStyle(color: GuardadoLocal.colores[0]))),
                          Row(

                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(5),
                                padding:  const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                    color: marcos,
                                    shape: BoxShape.circle),
                                child: CircleAvatar(backgroundColor: b),),
                              ElevatedButton(onPressed: (){_elegirColor('b');}, child: Text('Cambiar color'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),))
                            ],
                          )
                        ],
                      ),
                      //Color fuente
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child:Text('COLOR LETRAS SOBRE ELEMENTOS: ',style: TextStyle(color: GuardadoLocal.colores[0]))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(5),
                                padding:  const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                    color: marcos,
                                    shape: BoxShape.circle),
                                child: CircleAvatar(backgroundColor: l),),
                              ElevatedButton(onPressed: (){_elegirColor('l');}, child: Text('Cambiar color'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),))
                            ],
                          )
                        ],
                      ),
                      //Cancelar/Aplicar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text('Cancelar'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),)),
                          ElevatedButton(child: Text('Por defecto'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),),
                            onPressed: () async{
                              await GuardadoLocal.eliminarColores();
                              _aplicarColor();
                            },),
                          ElevatedButton(child: Text('Aplicar'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),),
                            onPressed: () async{
                              await GuardadoLocal.almacenarColores(p, b, l);
                                _aplicarColor();
                            },)
                        ],
                      )
                    ],
                  ),
                )
              )
          );
        });
  }

  _elegirColor(String actual){
    //Crear las variables
    Color currentColor = Colors.white;
    switch(actual){
      case 'p':
        currentColor = p;
        break;
      case 'b':
        currentColor = b;
        break;
      case 'l':
        currentColor = l;
        break;
    }
    Color pickerColor = currentColor;

// ValueChanged<Color> callback
    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

// raise the [showDialog] widget
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          backgroundColor: GuardadoLocal.colores[1],
          title: Text('Elige un color'.toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[0]),),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Aplicar'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),),
              onPressed: () {
                setState(() {
                  switch(actual){
                    case 'p':
                      p = pickerColor;
                      break;
                    case 'b':
                      b = pickerColor;
                      break;
                    case 'l':
                      l = pickerColor;
                      break;
                }});
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ventanaColores();
              },
            ),
          ],
        );
      }
    );
  }

  _aplicarColor() async{

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: GuardadoLocal.colores[1],
            title: Text('PARA APLICAR CAMBIOS HAY QUE REINICIAR',style: TextStyle(fontSize:30,color: GuardadoLocal.colores[0])),
            content: Text('¿Quiere reiniciar ahora?'.toUpperCase(),style: TextStyle(fontSize:25,color: GuardadoLocal.colores[0])),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('NO',style: TextStyle(color: GuardadoLocal.colores[2]))),
              ElevatedButton(
                  onPressed: () async{
                    Restart.restartApp();
                  },
                  child: Text('SÍ',style: TextStyle(color: GuardadoLocal.colores[2]))),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
            onPressed: (){Navigator.pop(context);}),
        title: Text("Configuración".toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[2]),),
      ),
      body: SingleChildScrollView(
          child: Container(
              alignment: Alignment.center,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.all(20),
                      child: ElevatedButton(
                          onPressed: () async {
                            return await ventanaColores();
                          },
                          child: Text("Elegir color".toUpperCase(),
                              style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2])))),
                  Container(
                      alignment: Alignment.center,
                      width: 650,
                      height: 600,
                      margin: EdgeInsets.only(bottom: 20),
                      child: posicion == null
                          ? Text("Calculando posición".toUpperCase())
                          : Flexible(
                              child: FlutterMap(
                              options: MapOptions(
                                center: LatLng(
                                    posicion.latitude, posicion.longitude),
                                zoom: 18,
                                maxZoom: 18,
                              ),
                              nonRotatedChildren: [
                                AttributionWidget.defaultWidget(
                                  source: 'OpenStreetMap contributors',
                                  onSourceTapped: null,
                                ),
                              ],
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                        point: LatLng(posicion.latitude,
                                            posicion.longitude),
                                        width: 30,
                                        height: 30,
                                        builder: (context) =>
                                            marcadorPersonal())
                                  ],
                                )
                              ],
                            ))),
                ],
              ))),
    );
  }
}
