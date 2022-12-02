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

//Boton con Advertencia
class BotonWarning extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _BotonWarningState();
}

class _BotonWarningState extends State<BotonWarning> {
  @override
  Widget build(BuildContext context) {

    return Container(

    );
  }

}

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
    int marcosR = (255-GuardadoLocal.colores[1].red) as int;
    int marcosG =(255-GuardadoLocal.colores[1].green) as int;
    int marcosB =(255-GuardadoLocal.colores[1].blue) as int;
    Color marcos = Color.fromRGBO(marcosR, marcosG, marcosB, GuardadoLocal.colores[0].opacity);

    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                        color: GuardadoLocal.colores[1],
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: const EdgeInsets.all(10),
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
                                  ElevatedButton(onPressed: (){_elegirColor('p');}, child: Text('Cambiar color'.toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 25),))
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
                                  ElevatedButton(onPressed: (){_elegirColor('b');}, child: Text('Cambiar color'.toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 25),))
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
                                  ElevatedButton(onPressed: (){_elegirColor('l');}, child: Text('Cambiar color'.toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 25),))
                                ],
                              )
                            ],
                          ),
                          //Previsulizacion
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(top:30),
                                  child:Text('PREVISUALIZACIÓN',style: TextStyle(fontSize:30,color: GuardadoLocal.colores[0]),)
                              ),
                              Container(
                                  margin: EdgeInsets.only(top:10,bottom: 10),
                                  child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                            child: Column(
                                                children: [
                                                  Text('ACTUAL',style: TextStyle(fontSize:30,color: GuardadoLocal.colores[0]),),
                                                  Container(
                                                    color: marcos,
                                                    padding:  const EdgeInsets.all(1),
                                                    child: previsualizacionColores(GuardadoLocal.colores[0],GuardadoLocal.colores[1],GuardadoLocal.colores[2]),
                                                  )]
                                            ),
                                      ),

                                      Expanded(
                                              child: Column(
                                                  children: [
                                                    Text('SELECCIONADO',style: TextStyle(fontSize:30,color: GuardadoLocal.colores[0])),
                                                    Container(
                                                      color: marcos,
                                                      padding:  const EdgeInsets.all(1),
                                                      child: previsualizacionColores(p,b,l),
                                                    )]
                                              )
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                          //Cancelar/Aplicar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                  child: Container(
                                    margin: EdgeInsets.all(2),
                                    child:ElevatedButton(onPressed: (){
                                      p=GuardadoLocal.colores[0];
                                      b=GuardadoLocal.colores[1];
                                      l=GuardadoLocal.colores[2];
                                      Navigator.pop(context);
                                    },
                                        child: Text('Cancelar'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),)),
                                  )
                              ),
                              Expanded(
                                  child: Container(
                                    margin: EdgeInsets.all(2),
                                    child:ElevatedButton(
                                      child: Text('Por defecto'.toUpperCase(), style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),),
                                      onPressed: () async{
                                        await GuardadoLocal.eliminarColores();
                                        _aplicarColor();
                                      },),
                                  )
                              ),
                              Expanded(
                                  child: Container(
                                      margin: EdgeInsets.all(2),
                                      child:ElevatedButton(
                                        child: Text('Aplicar'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),),
                                        onPressed: () async{
                                          await GuardadoLocal.almacenarColores(p, b, l);
                                          _aplicarColor();
                                        },)
                                  )
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                ),
          );
        });
  }

  //Widget de previsualizacion de colores
  Widget previsualizacionColores(Color p, Color b, Color l){
    return Column(
          children: [
            Container(
              color:p,
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back,color: l,),
                  Expanded(child: Text('       TuCole       ',style: TextStyle(color: l),),),
                  Icon(Icons.settings,color: l,)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 5),
              alignment: Alignment.center,
              color:b,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('TEXTO SOBRE FONDO',style: TextStyle(color: p),),
                    ElevatedButton(onPressed: (){},
                      style: ElevatedButton.styleFrom(primary: p),
                      child: Text('BOTÓN',style: TextStyle(color: l,fontSize: 25),),)
                  ],
                ),
              )
          ],
        );
  }

  _elegirColor(String actual){

    ContrastChecker comprobadorDeContraste = new ContrastChecker();
    ColorPicker colorPicker = new ColorPicker(pickerColor: Colors.white, onColorChanged: (Color){});
    StreamController<String> controladorStream = StreamController<String>.broadcast();


    //Comprobar color
    bool comprobarColor(pC){
      switch(actual){
        case 'p':
            return (comprobadorDeContraste.contrastCheck(100,pC,b,WCAG.AA)
                  && comprobadorDeContraste.contrastCheck(100,pC,l,WCAG.AA));
        case 'b':
          return (comprobadorDeContraste.contrastCheck(100,pC,p,WCAG.AA));
        case 'l':
          return (comprobadorDeContraste.contrastCheck(100,pC,p,WCAG.AA));
      }
      return false;
    }

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
      setState(() {
        pickerColor = color;
      });
      controladorStream.add("");
    }

    colorPicker = new ColorPicker(pickerColor: currentColor, onColorChanged: changeColor);
// raise the [showDialog] widget
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          backgroundColor: GuardadoLocal.colores[1],
          title: Text('Elige un color'.toUpperCase(),style: TextStyle(color: GuardadoLocal.colores[0],fontSize: 25),),
          content: SingleChildScrollView(
            child: colorPicker,
          ),
          actions: <Widget>[
            StreamBuilder(
              stream: controladorStream.stream,
              initialData: "",
              builder: (context,AsyncSnapshot snapshot){
                return ElevatedButton(
                  style: comprobarColor(pickerColor)?
                    ElevatedButton.styleFrom(primary: GuardadoLocal.colores[0]):ElevatedButton.styleFrom(primary: Colors.red),
                  child: comprobarColor(pickerColor)?
                    Text('Aplicar'.toUpperCase(),style: TextStyle(fontSize: 30,color: GuardadoLocal.colores[2]),):
                    Icon(Icons.warning,color: Colors.red[900],size: 36,),
                  onPressed: () {
                    bool esAccesible = false;
                    setState(() {
                      switch(actual){
                        case 'p':
                          if(comprobarColor(pickerColor)){
                            p = pickerColor;
                            esAccesible = true;
                          }
                          break;
                        case 'b':
                          if(comprobarColor(pickerColor)){
                            b = pickerColor;
                            esAccesible = true;
                          }
                          break;
                        case 'l':
                          if(comprobarColor(pickerColor)){
                            l = pickerColor;
                            esAccesible = true;
                          }
                          break;
                      }});

                    //Si es accesible actualizo los colores
                    if(esAccesible){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      ventanaColores();
                    }
                    //Si no es accesible lo indico y no aplico ese color
                    else{
                      showDialog(context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.red,
                              title: Text('EL COLOR SELECCIONADO NO PRESENTA UN CONTRASTE ADECUADO',style: TextStyle(fontSize:30,color: Colors.white)),
                              content: Text('Selecciona otro color'.toUpperCase(),style: TextStyle(fontSize:25,color: Colors.white)),
                              actions: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(primary: Colors.red[900]),
                                    onPressed: (){
                                      Navigator.pop(context, false);
                                    },
                                    child: Text('ACEPTAR',style: TextStyle(fontSize:30,color: Colors.white))),
                              ],
                            );}
                      );
                    }
                  },
                );
              },
            )
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
        title: Center(child: Text("Configuración".toUpperCase(),textAlign: TextAlign.center,style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 30),),
      )),
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
