import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_profesor.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';

class CustomSearchDelegate extends SearchDelegate {
// Demo list to show querying
  List<String> searchTerms = [];
  var vez = 0;

  crearLista(){
    for(var i = 0; i < Sesion.profesores.length; i++){
      searchTerms.add(Sesion.profesores[i].nombre);
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
        for (int i = 0; i < Sesion.profesores.length; i++)
          if(result.toString().toUpperCase() == Sesion.profesores[i].nombre.toUpperCase())
            pos=i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            children: [
              Container(
                  width: 130,
                  height: 150,
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    child: Column(
                      children: [
                        Text(
                          Sesion.profesores[pos].nombre.toString().toUpperCase(),
                          style: TextStyle(
                            color: GuardadoLocal.colores[2],
                            fontSize: 25,
                          ),
                        ),
                        Image.network(
                          Sesion.profesores[pos].foto,
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Sesion.seleccion = Sesion.profesores[pos];
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PerfilProfesor()));
                    },
                  ))
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
        for (int i = 0; i < Sesion.profesores.length; i++)
          if(result.toString().toUpperCase() == Sesion.profesores[i].nombre.toUpperCase())
            pos=i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            children: [
              Container(
                  width: 130,
                  height: 150,
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    child: Column(
                      children: [
                        Text(
                          Sesion.profesores[pos].nombre.toString().toUpperCase(),
                          style: TextStyle(
                            color: GuardadoLocal.colores[2],
                            fontSize: 25,
                          ),
                        ),
                        Image.network(
                          Sesion.profesores[pos].foto,
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Sesion.seleccion = Sesion.profesores[pos];
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PerfilProfesor()));
                    },
                  ))
            ],
          ),
        );
      },
    );
  }
}
