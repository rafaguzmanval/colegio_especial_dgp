import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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
            if(r.request?.url.toString() == ultimaPeticion && controladorBusqueda.text != "")
              controladorStream.add(r.body);
            print(r.request?.url.toString());

      });
    }
    else
      {
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
                    width: MediaQuery.of(context).size.width - 300,
                  child:
                  Column(children: [
                  TextField(
                    controller: controladorBusqueda,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Buscar ...',
                    ),
                  ),
                  if (snapshot.data.toString() != "" ) ...[
                    for (int i = 0; i < longitud && i < 20; i = i + 2)
                      Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int j = i; j < i + 2 && j < longitud; j++)
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
