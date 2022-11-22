import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart";

import '../Dart/sesion.dart';

class Configuracion extends StatefulWidget {
  @override
  ConfiguracionState createState() => ConfiguracionState();
}

class ConfiguracionState extends State<Configuracion> {
  var posicion = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Sesion.colores[2]),
            onPressed: (){Navigator.pop(context);}),
        title: Text("Configuración".toUpperCase(),style: TextStyle(color: Sesion.colores[2]),),
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
                          onPressed: () {},
                          child: Text("Elegir color".toUpperCase(),
                              style: TextStyle(fontSize: 30,color: Sesion.colores[2])))),
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
