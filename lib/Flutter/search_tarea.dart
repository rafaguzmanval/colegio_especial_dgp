import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_tarea.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';

class CustomSearchDelegate extends SearchDelegate {
// Demo list to show querying
  List<String> searchTerms = [];
  var vez = 0;
  bool esTareaEliminandose = false;
  int tareaEliminandose = 0;


  crearLista(){
    for(var i = 0; i < Sesion.tareas.length; i++){
      searchTerms.add(Sesion.tareas[i].nombre);
    }
  }

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    if(vez == 0)
    {
      crearLista();
      vez++;
    }
    return [
      IconButton(
        onPressed: () {
          cargarTareas();
        },
        icon: Icon(Icons.update),
      ),
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.cleaning_services),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    var pos = 0;
    for (var nombre in searchTerms) {
      if (nombre.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(nombre);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        for (int i = 0; i < Sesion.tareas.length; i++)
          if(result.toString().toUpperCase() == Sesion.tareas[i].nombre.toUpperCase())
            pos=i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 200,
                          height: 220,
                          margin: EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            child: Column(
                              children: [
                                Text(
                                  Sesion.tareas[pos].nombre.toString().toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: GuardadoLocal.colores[2],
                                  ),
                                ),
                                if (!Sesion.tareas[pos].imagenes.isEmpty) ...[
                                  Image.network(
                                    Sesion.tareas[pos].imagenes[0],
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.fill,
                                  ),
                                ]
                              ],
                            ),
                            onPressed: () async {
                              Sesion.seleccion = Sesion.tareas[pos];
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PerfilTarea()));
                              cargarTareas();
                            },
                          )),
                      IconButton(
                          onPressed: () async {

                            await Sesion.db.eliminarTarea(Sesion.tareas[pos].id).then(
                                    (e){
                                  esTareaEliminandose = true;
                                  tareaEliminandose = pos;
                                  cargarTareas();
                                }
                            );


                          },
                          icon: Icon(
                            Icons.delete,
                            color: GuardadoLocal.colores[0],
                          )),
                      if (esTareaEliminandose && pos == tareaEliminandose) ...[
                        new CircularProgressIndicator(),
                      ]
                    ])
            ],
          ),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    var pos = 0;
    for (var nombre in searchTerms) {
      if (nombre.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(nombre);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        for (int i = 0; i < Sesion.tareas.length; i++)
          if(result.toString().toUpperCase() == Sesion.tareas[i].nombre.toUpperCase())
            pos=i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 200,
                          height: 220,
                          margin: EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            child: Column(
                              children: [
                                Text(
                                  Sesion.tareas[pos].nombre.toString().toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: GuardadoLocal.colores[2],
                                  ),
                                ),
                                if (!Sesion.tareas[pos].imagenes.isEmpty) ...[
                                  Image.network(
                                    Sesion.tareas[pos].imagenes[0],
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.fill,
                                  ),
                                ]
                              ],
                            ),
                            onPressed: () async {
                              Sesion.seleccion = Sesion.tareas[pos];
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PerfilTarea()));
                              cargarTareas();
                            },
                          )),
                      IconButton(
                          onPressed: () async {

                            await Sesion.db.eliminarTarea(Sesion.tareas[pos].id).then(
                                    (e){
                                  esTareaEliminandose = true;
                                  tareaEliminandose = pos;
                                  cargarTareas();
                                }
                            );


                          },
                          icon: Icon(
                            Icons.delete,
                            color: GuardadoLocal.colores[0],
                          )),
                      if (esTareaEliminandose && pos == tareaEliminandose) ...[
                        new CircularProgressIndicator(),
                      ]
                    ])
            ],
          ),
        );
      },
    );
  }

  cargarTareas() async {
    Sesion.tareas = await Sesion.db.consultarTodasLasTareas();
    actualizar();
  }

  // metodo para actualizar la pagina
  void actualizar() async {
    esTareaEliminandose = false;
    searchTerms.clear();
    crearLista();
  }
}
