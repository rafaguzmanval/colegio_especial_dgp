import 'dart:async';

import 'package:contrast_checker/contrast_checker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart";

import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';



class Localizacion extends StatefulWidget {
  @override
  LocalizacionState createState() => LocalizacionState();
}

class LocalizacionState extends State<Localizacion> {
  var latitudColegio = 37.18085;
  var longitudColegio = -3.60270;

  @override
  initState() {
    super.initState();
    Sesion.paginaActual = this;

    obtenerPosicion();
    Sesion.db.obtenerPosicion(Sesion.seleccion.id);
  }

  actualizar() {setState(() {

  });}

  Widget marcadorPersonal(foto) {
    return CircleAvatar(
      radius: 56,
      backgroundColor: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(2), // Border radius
        child: ClipOval(child: Image.network(foto)),
      ),
    );
  }


  Widget marcadorColegio() {
    return CircleAvatar(
      radius: 56,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2), // Border radius
        child: ClipOval(child: Image.asset("assets/sanjuandedios.png")),
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

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,

    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream( locationSettings: locationSettings).listen(
            (Position? position) {
          if(position != null)
            {
              Sesion.posicion = position;
              setState(() {

              });
            }
    });

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
            onPressed: (){Navigator.pop(context);}),
        title: Center(child: Text("LOCALIZACIÓN",textAlign: TextAlign.center,style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 30),),
      )),
      body:
                      Sesion.posicion == null
                          ? Center(child:Text("Calculando posición".toUpperCase()))
                          : FlutterMap(
                              options: MapOptions(
                                center:  LatLng(
                                    Sesion.argumentos[0],
                                    Sesion.argumentos[1]),
                                zoom: 18,
                                maxZoom: 18,
                              ),
                              nonRotatedChildren: [
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
                                        point: LatLng(Sesion.posicion.latitude,
                                            Sesion.posicion.longitude),
                                        width: 30,
                                        height: 30,
                                        builder: (context) =>
                                            marcadorPersonal(Sesion.foto)),

                                    Marker(
                                        point: LatLng(Sesion.argumentos[0],
                                            Sesion.argumentos[1]),
                                        width: 30,
                                        height: 30,
                                        builder: (context) =>
                                            marcadorPersonal(Sesion.seleccion.foto)),

                                    Marker(
                                        point: LatLng(latitudColegio,
                                            longitudColegio),
                                        width: 30,
                                        height: 30,
                                        builder: (context) =>
                                            marcadorColegio()),

                                  ],
                                )
                              ],
                            )

    );
  }
}
