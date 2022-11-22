import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:colegio_especial_dgp/Dart/sesion.dart';

///función con el dialog para encontrar imágenes de arasaac
buscadorArasaac({required BuildContext context}) {
  return showDialog(
      context: context,
      builder: (context) {
        return _estructura(context);
      });
}

///Dialogo con el buscador de imagenes online de ARASAAC
_estructura(context) {
  StreamController<String> controladorStream =
      StreamController<String>.broadcast();

  var controladorBusqueda = TextEditingController();

  var ultimaPeticion = "";


  controladorBusqueda.addListener(() async {

    if (controladorBusqueda.text != "" && controladorBusqueda.text.isNotEmpty) {
      ultimaPeticion = "https://api.arasaac.org/api/pictograms/es/search/" +
    controladorBusqueda.text;
      await http
          .get(Uri.parse(ultimaPeticion))
          .then((r) {

            //este if sirve para comprobar que la petición es la última que se ha hecho
        // (la petición que desea el usuario es la última que escribe, no la que tarda más)
            if(r.request?.url.toString() == ultimaPeticion && controladorBusqueda.text != "")
              controladorStream.add(r.body);
            //print(r.request?.url.toString());

      });
    }
    else
      {
        //si no hay nada se manda al stream un string vacio para no hacer perder
        // el tiempo al servidor de arasaac
        controladorStream.add("");
      }
  });

  return Dialog(
      child: SingleChildScrollView(
          child: StreamBuilder(
              stream: controladorStream.stream,
              initialData: "",
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                var msg = snapshot.data.toString() != ""
                    ? json.decode(snapshot.data.toString())
                    : "";
                var longitud = msg.length;

                return
                  Container(
                    color: Sesion.colores[1],
                    width: MediaQuery.of(context).size.width - 300,
                  child:
                  Column(children: [
                    //Textfield donde el usuario introduce la imágen que quiere buscar
                  TextField(
                    style: TextStyle(color: Sesion.colores[0]),
                    controller: controladorBusqueda,
                    decoration: InputDecoration(
                      enabledBorder:  OutlineInputBorder(
                        borderSide:  BorderSide(color: Sesion.colores[0], width: 0.0),
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'Buscar ...',
                      hintStyle: TextStyle(color: Sesion.colores[0])
                    ),
                  ),
                  if (snapshot.data.toString() != "" ) ...[
                    //Se fija como mucho 10 imágenes por motivos de rápidez y para
                    //no sobrecargar la búsqueda de arasaac
                    for (int i = 0; i < longitud && i < 10; i = i + 2)
                      Container(
                          child: Row(
                            //en una fila se ponen dos imágenes
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int j = i; j < i + 2 && j < longitud; j++)
                            //Se censuran los resultados con sexo o violencia
                            if (!msg[j]["sex"] && !msg[j]["violence"]) ...[
                              Flexible(
                                  flex: 50,
                                  child: _buscarImagen(context, msg, j))
                            ]
                        ],
                      ))
                  ]
                    else...
                      [
                        Container()
                      ]
                ])
                  );
              })));
}

//Se genera la imágen dentro de cada fila individualmente
_buscarImagen(context, mensaje, i) {
  return Container(
      child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
          ),
          onPressed: () {
            Navigator.pop(
                context,
                "https://api.arasaac.org/api/pictograms/" +
                    mensaje[i]["_id"].toString());
          },
          child: Column(children: [
            Center(
                child: Text(
              mensaje[i]["keywords"][0]["keyword"],
              style: TextStyle(color: Colors.black),
            )),
            Image.network(
              "https://api.arasaac.org/api/pictograms/" +
                  mensaje[i]["_id"].toString(),
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ])));
}
