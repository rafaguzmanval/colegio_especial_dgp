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

import '../Dart/rol.dart';

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

  Color p = GuardadoLocal.colores[0];
  Color b = GuardadoLocal.colores[1];
  Color l = GuardadoLocal.colores[2];

  @override
  initState() {
    super.initState();
    Sesion.paginaActual = this;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: (){Navigator.pop(context);}),
          title: Center(child: Text("Configuración".toUpperCase(),textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: GuardadoLocal.colores[2],fontSize: 30),),
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: GuardadoLocal.colores[2])))),

                  Container(
                      margin: EdgeInsets.all(20),
                      child: ElevatedButton(
                          onPressed: () async {
                            Sesion.db.eliminarTodosLosMensajes();
                          },
                          child: Text("Limpiar chats".toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: GuardadoLocal.colores[2])))),

                ],
              ))),
    );
  }

  actualizar()
  {setState(() {

  });}



  ventanaColores() async{
    //Ajusto el color de la ventana
    int marcosR = (255-GuardadoLocal.colores[1].red) as int;
    int marcosG =(255-GuardadoLocal.colores[1].green) as int;
    int marcosB =(255-GuardadoLocal.colores[1].blue) as int;
    Color marcos = Color.fromRGBO(marcosR, marcosG, marcosB, GuardadoLocal.colores[0].opacity);

    Orientation orientacion = MediaQuery.of(context).orientation;

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
                                  IconButton(color:GuardadoLocal.colores[0],onPressed: (){_elegirColor('p');}, icon: Icon(Icons.color_lens))],
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
                                  IconButton(color:GuardadoLocal.colores[0],onPressed: (){_elegirColor('b');}, icon: Icon(Icons.color_lens))
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
                                  IconButton(color:GuardadoLocal.colores[0],onPressed: (){_elegirColor('l');}, icon: Icon(Icons.color_lens))
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
                                        child: Text('Cancelar'.toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: GuardadoLocal.colores[2]),)),
                                  )
                              ),
                              Expanded(
                                  child: Container(
                                    margin: EdgeInsets.all(2),
                                    child:ElevatedButton(
                                      child: Text('Por defecto'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: GuardadoLocal.colores[2]),),
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
                                        child: Text('Aplicar'.toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: GuardadoLocal.colores[2]),),
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
                      child: Text('BOTÓN',style: TextStyle(fontWeight: FontWeight.bold,color: l,fontSize: 25),),)
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


}
