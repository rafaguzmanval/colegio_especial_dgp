
import 'package:colegio_especial_dgp/Dart/Sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import '../Dart/clase.dart';
import '../Dart/tarea.dart';
import '../Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/AccesoBD.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';


class perfilAlumno extends StatefulWidget{

  @override
  perfilAlumnoState createState() => perfilAlumnoState();

}

class perfilAlumnoState extends State<perfilAlumno>{


  AccesoBD base = new AccesoBD();

  var usuarioPerfil;

  var imagenPerfil;

  //Tareas del alumno que están asignadas y se muestran en su perfil
  var tareasAlumno = [];

  //Todas las tareas que el profesor selecciona para asignar al alumno
  var tareas = [];
  var nombresTareas = ["Nada seleccionado"];
  var tareaElegida = "Nada seleccionado";
  var idTareaElegida = null;

  final myController = TextEditingController();

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    Sesion.paginaActual = this;
    cargarUsuario();
    cargarTareas();



  }

  @override
  Widget build(BuildContext context){



    return Scaffold(
      appBar:AppBar(
        title: Text('Perfil de ${Sesion.seleccion.nombre}'
            ''),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal:  10),
        child: Column(
          children: [


            if(Sesion.rol == Rol.alumno.toString())...[
              VistaAlumno()
            ]
            else if(Sesion.rol == Rol.profesor.toString())...[
              VistaProfesor()
            ]
            else if(Sesion.rol == Rol.administrador.toString())...[
                VistaAdministrador()
              ]
              else if(Sesion.rol == Rol.programador.toString())...[
                  VistaProgramador()
                ]
          ],
        )


      ),
    );
  }


  Widget VistaProfesor()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            if(usuarioPerfil != null)...[
              Text(usuarioPerfil.nombre),
              Text(usuarioPerfil.apellidos),
              Text(usuarioPerfil.fechanacimiento),
              Text(usuarioPerfil.rol),

              Image(
                width: 100,
                height: 100,
                image: NetworkImage(usuarioPerfil.foto),
              )
              ,
              Text("\nTAREAS:"),


              if(Sesion.misTareas != null)...
                [

                  for(int i = 0; i < Sesion.misTareas.length; i++)

                    if(Sesion.misTareas[i] is Tarea)...[
                    Container(

                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                                Text(Sesion.misTareas[i].nombre),
                                IconButton(onPressed: () {base.eliminarTareaAlumno(Sesion.seleccion.id, i);},
                                icon: Icon(Icons.delete)
                                )


                          ],
                        )

                    ),
                    ]
                  else...[
                    new CircularProgressIndicator()
                    ]
                ],




              Text("\n Añadir Tarea: "),

             /* TextField(
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: 'Introduce nueva tarea',
                ),
                controller: myController,
              ),*/

              if(tareas != null && nombresTareas.length > 1)...[
              DropdownButton(

                  value: tareaElegida,

                  items: nombresTareas.map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),

                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    tareaElegida = value!;

                    if(tareaElegida == "Nada seleccionado"){
                      idTareaElegida = null;
                    }
                    else
                      {
                        int i = 0;
                        bool salir = false;
                        while(i < tareas.length && !salir){

                          if(tareas[i].nombre == tareaElegida){
                            idTareaElegida = tareas[i].id;
                            salir = true;
                          }
                          i++;
                        }
                      }


                  });
                },
              ),

              ElevatedButton(
                child: Text("Añadir Tarea",
                  style: TextStyle(
                      color: Colors.amberAccent,
                  ),
                ),
                onPressed: () {
                  if(idTareaElegida != null)
                    {
                      base.addTareaAlumno(Sesion.seleccion.id, idTareaElegida);
                    }
                },


              )
              ]



            ]else ...[
              new CircularProgressIndicator()
            ]



          ],
        ),
      );
  }


  Widget VistaAlumno()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child:Column(
              children:[
                        Text("Eres un alumno"),


                    ],
                  ),
      );
  }


  Widget VistaAdministrador()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un profesor")

          ],
        ),
      );
  }

  Widget VistaProgramador()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un profesor")

          ],
        ),
      );
  }

  cargarUsuario() async// EN sesion seleccion estara el id del usuario que se ha elegido
  {
    usuarioPerfil = await base.consultarIDusuario(Sesion.seleccion.id);
    await base.consultarTareasAsignadasAlumno(Sesion.seleccion.id);
    actualizar();
  }

  cargarTareas() async
  {
    tareas = await base.consultarTodasLasTareas();

    for(int i = 0; i < tareas.length; i++){
      nombresTareas.add(tareas[i].nombre);
    }

    actualizar();
  }

  lecturaImagen(path) async
  {
     return await base.leerImagen(path);
  }


  void actualizar()
  {

    setState(() {

    });
  }

}








