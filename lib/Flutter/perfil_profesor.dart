/*
*   Archivo: perfil_profesor.dart
*
*   Descripción:
*   Pagina para ver el perfil del profesor
*
*   Includes:
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
* */

import 'dart:async';

import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:image_picker/image_picker.dart";
import 'package:colegio_especial_dgp/Dart/passport_method.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';
import 'dart:io';
import 'package:colegio_especial_dgp/Flutter/lista_profesores.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';

enum SeleccionImagen { camara, galeria }

class PerfilProfesor extends StatefulWidget {
  @override
  PerfilProfesorState createState() => PerfilProfesorState();
}

class PerfilProfesorState extends State<PerfilProfesor> {
  var usuarioPerfil;
  var controladorNombre = TextEditingController();
  var controladorApellidos = TextEditingController();
  final myController = TextEditingController();
  var fechaElegida = null;
  var fechaAntigua;
  var fotoTomada;
  var registrando = false;
  var mensajeDeRegistro = "";
  var vez = 0;
  ImagePicker capturador = new ImagePicker();
  final controladorPassword = TextEditingController();
  var metodoElegido;
  var rolElegido;
  StreamController controladorStream = StreamController.broadcast();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;
    cargarUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios_new, color: GuardadoLocal.colores[2]),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Center(
            child: Text(
          'PERFIL DE ${Sesion.seleccion.nombre.toUpperCase()}'
          '',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold,color: GuardadoLocal.colores[2], fontSize: 30),
        )),
      ),
      body: SingleChildScrollView(child: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          alignment: Alignment.center,
          child: Column(
            children: [
              cargando(),
            ],
          )),
    ));
  }

  // Carga el perfil del profesor
  Widget VistaProfesor() {
    return perfilProfesor();
  }

  Widget VistaAlumno() {
    Navigator.pop(context);
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  // Carga el perfil del profesor
  Widget VistaAdministrador() {
    return perfilProfesor();
  }

  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  seleccionarImagen(seleccion) async {
    try {
      if (seleccion == SeleccionImagen.camara) {
        print("Se va a abrir la cámara de fotos");
        fotoTomada = await capturador.pickImage(
          source: ImageSource.camera,
          imageQuality: 15,
        );
      } else {
        print("Se coger una foto de la galería");
        fotoTomada = await capturador.pickImage(
            source: ImageSource.gallery, imageQuality: 15);
      }
    } catch (e) {
      print(e);
    }
    actualizar();
  }

  /// Carga el perfil del profesor
  Widget perfilProfesor() {
    if (vez == 0) {
      controladorNombre.text = usuarioPerfil.nombre.toUpperCase();
      controladorApellidos.text = usuarioPerfil.apellidos.toUpperCase();
      fechaAntigua = usuarioPerfil.fechanacimiento;
      fotoTomada = usuarioPerfil.foto;
      controladorPassword.text = usuarioPerfil.password;
      rolElegido = usuarioPerfil.rol;
      metodoElegido = usuarioPerfil.metodoLogeo;
      if(metodoElegido == "Passportmethod.text"){
        metodoElegido = "clave";
      }
      else{
        metodoElegido = "pin";
      }
      vez++;
    }
    return
    Column(
      children: [
        if (usuarioPerfil != null) ...[
          SizedBox(
            height: 10,
          ),

          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Flexible(
              flex: 25,
              child: Container(
                child: !(usuarioPerfil.foto is String)
                    ? Column(children: [
                  Text(
                    'NINGUNA FOTO ELEGIDA ****',
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        dialogEditarFoto();
                        actualizar();
                      },
                      child: Icon(
                        Icons.edit,
                        color: GuardadoLocal.colores[2],
                        size: 40,
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder())),
                ])
                    : CircleAvatar(
                  radius: 100,
                  backgroundImage: NetworkImage(usuarioPerfil.foto),
                  child: Stack(
                    children: [
                      Container(
                        child: ElevatedButton(
                            onPressed: () {
                              dialogEditarFoto();
                              actualizar();
                            },
                            child: Icon(
                              Icons.edit,
                              color: GuardadoLocal.colores[2],
                              size: 40,
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: CircleBorder())),
                        alignment: Alignment.bottomRight,
                      )
                    ],
                  ),
                ),
              ),
            ),

            Flexible(
                flex: 50,
                child: Column(
                  children: [
                    SizedBox(
                      width: 500,
                      child: TextButton(
                          child: Text(
                            usuarioPerfil.nombre.toUpperCase(),
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async{

                            var nombre = await dialogNombre(usuarioPerfil.nombre);
                            if(nombre != null)
                            {
                              Sesion.db.editarNombreUsuario(usuarioPerfil.id, nombre);
                              usuarioPerfil.nombre = nombre;
                              actualizar();
                            }

                          }),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 500,
                      child: TextButton(
                          child: Text(
                            usuarioPerfil.apellidos.toUpperCase(),
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async{

                            var apellidos = await dialogNombre(usuarioPerfil.apellidos);
                            if(apellidos != null)
                            {
                              Sesion.db.editarApellidosUsuario(usuarioPerfil.id, apellidos);
                              usuarioPerfil.apellidos = apellidos;
                              actualizar();
                            }

                          }),
                    ),
                  ],
                )),

            ///BOTON DE LOCALIZACION

            /*Flexible(
              flex: 25,
              child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Localizacion()));
                    Sesion.paginaActual = this;
                    actualizar();
                  },
                  child: Image.asset(
                    'assets/mapa.png',
                    width: 140,
                    height: 100,
                  )),
            )*/
          ]),

          Text('FECHA DE NACIMIENTO:'),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(usuarioPerfil.fechanacimiento),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  await showDatePicker(
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: GuardadoLocal.colores[1],
                            colorScheme: ColorScheme.light(
                                primary:
                                GuardadoLocal.colores[0] // <-- SEE HERE
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                primary: GuardadoLocal
                                    .colores[0], // button text color
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                      context: context,
                      locale: const Locale("es", "ES"),
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now())
                      .then((e) async{
                    if(e != null)
                    {
                      var fecha = DateFormat('d/M/y').format(e!);
                      await Sesion.db.editarNacimientoUsuario(usuarioPerfil.id, fecha).then((e){
                        usuarioPerfil.fechanacimiento = fecha;
                        actualizar();
                      });
                    }

                  });
                },
                child: Image.asset(
                  "assets/calendario.png",
                  width: 50,
                  height: 50,
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: GuardadoLocal.colores[0])),
          ]),

          SizedBox(
            height: 15,
          ),

          SizedBox(height: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (fotoTomada == null) ...[
                SizedBox(
                  height: 10,
                ),
              ]
            ],
          ),


        ] else ...[
          new CircularProgressIndicator()
        ],
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  /// Carga el usuario del profesor
  cargarUsuario() async // EN sesion seleccion estara el id del usuario que se ha elegido
  {
    usuarioPerfil = await Sesion.db.consultarIDusuario(Sesion.seleccion.id);
    actualizar();
  }

  /*
  editarUsuario() async{
    // FALTARIA HACER COMPROBACIÓN DE QUE EL NOMBRE Y APELLIDOS YA ESTÁN REGISTRADOS EN LA BASE DE DATOS

    if (controladorNombre.text.isNotEmpty &&
        controladorApellidos.text.isNotEmpty &&
        controladorPassword.text.isNotEmpty &&
        fechaAntigua != null &&
        rolElegido != "ningun rol elegido") {
      registrando = true;
      actualizar();
      var fechanacimiento =  "" + fechaAntigua;
      var nombre = "" + controladorNombre.text;
      var apellidos = "" + controladorApellidos.text;
      var password = "" + controladorPassword.text;
      if(fechaElegida != null){
        fechanacimiento = "" + DateFormat('d/M/y').format(fechaElegida);
      }

      var rol = "" + rolElegido;

      Usuario usuario = Usuario();
      usuario.setUsuario(
          nombre,
          apellidos,
          password,
          fechanacimiento,
          rol,
          "",
          metodoElegido == "clave"
              ? Passportmethod.text.toString()
              : Passportmethod.pin.toString());

      var foto = null;
      if (fotoTomada != null) {
        if (fotoTomada is String) {
          if (fotoTomada.startsWith("http")) {
            foto = fotoTomada;
          }
        } else {
          foto = File(fotoTomada.path);
        }
      }

      await Sesion.db.editarUsuario(usuario, foto, usuarioPerfil).then((value) {
        registrando = false;

        if (value) {
          mensajeDeRegistro =
          "EDICION COMPLETADA PERFECTAMENETE\nPUEDES VOLVER A EDITAR OTRO USUARIO";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                duration: Duration(seconds: 2),
                elevation: 0,
                content: Container(
                  padding: const EdgeInsets.all(16),
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6BFF67),
                    borderRadius: BorderRadius.all(Radius.circular(29)),
                  ),
                  child: Text(
                    mensajeDeRegistro,
                    style: TextStyle(
                        color: GuardadoLocal.colores[2], fontSize: 25),
                  ),
                )),
          );
          Navigator.pop(context);
        } else {
          mensajeDeRegistro =
          "FALLO EN EL PROCESO DE REGISTRO, INTENTELO DE NUEVO";
          mostrarError(mensajeDeRegistro, true);
        }

        actualizar();
      });
    } else {
      mensajeDeRegistro = "DEBE RELLENAR TODOS LOS CAMPOS CON *";
      mostrarError(mensajeDeRegistro, true);
      actualizar();
    }
  }*/

  mostrarError(mensaje, error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          duration: Duration(seconds: 2),
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: BoxDecoration(
              color: Color(error ? 0xFFC72C41 : 0xFF6BFF67),
              borderRadius: BorderRadius.all(Radius.circular(29)),
            ),
            child: Text(
              mensaje,
              style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 25),
            ),
          )),
    );
  }

  Widget cargando() {
    if (usuarioPerfil == null)
      return Center(
        child: Text(
          '\nCARGANDO EL USUARIO',
          textAlign: TextAlign.center,
        ),
      );
    else {
      return vista();
    }
  }

  vista() {
    if (Sesion.rol == Rol.alumno.toString()) {
      return VistaAlumno();
    } else if (Sesion.rol == Rol.profesor.toString()) {
      return VistaProfesor();
    } else if (Sesion.rol == Rol.administrador.toString()) {
      return VistaAdministrador();
    } else if (Sesion.rol == Rol.programador.toString()) {
      return VistaProgramador();
    }
  }

  /// Actualiza la pagina
  void actualizar() {
    setState(() {});
  }

  dialogNombre(texto) {
    var controlador = TextEditingController();
    controlador.text = texto.toUpperCase();
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              backgroundColor: GuardadoLocal.colores[1],
              child: Column(
                children: [
                  TextField(
                    controller: controlador,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 35, color: GuardadoLocal.colores[0]),
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: GuardadoLocal.colores[0], width: 0.0),
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          margin: EdgeInsets.all(15),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Column(children: [
                                Text(
                                  'No'.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 40,
                                      color: GuardadoLocal.colores[2]),
                                ),
                              ]))),
                      Container(
                          margin: EdgeInsets.all(15),
                          child: ElevatedButton(
                            onPressed: () {
                              if (controlador.text != "") {
                                Navigator.pop(context, controlador.text);
                              }
                            },
                            child: Text(
                              'Ok'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 40,
                                  color: GuardadoLocal.colores[2]),
                            ),
                          ))
                    ],
                  )
                ],
              ));
        });
  }

  dialogEditarFoto() {
    StreamController controlador = new StreamController();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              alignment: Alignment.center,
              child:
              StreamBuilder(
                stream: controlador.stream,
                builder: (context,snapshot){
                  return
                    snapshot.data == "carga"?
                    Container(width:50,height:50,child:CircularProgressIndicator())

                        :
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton(
                          child: Image.asset(
                            "assets/camara.png",
                            width: 100,
                            height: 100,
                          ),
                          onPressed: () async {
                            controlador.add("carga");
                            var imagen =
                            await seleccionarImagen(SeleccionImagen.camara);
                            var nuevaURL = await Sesion.db.editarFotoUsuario(
                                usuarioPerfil.id, File(imagen.path));

                            print("Nueva " + nuevaURL);
                            usuarioPerfil.foto = nuevaURL;
                            actualizar();

                            Navigator.pop(context);
                          }),

                      // Container(width: 10,alignment: Alignment.center,),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(

                          child: Image.asset(
                            'assets/galeria.png',
                            width: 100,
                            height: 100,
                          ),
                          onPressed: () async {
                            controlador.add("carga");
                            var imagen =
                            await seleccionarImagen(SeleccionImagen.galeria);
                            await Sesion.db.editarFotoUsuario(
                                usuarioPerfil.id, File(imagen.path)).then((foto){
                              print("Nueva " + foto);
                              usuarioPerfil.foto = foto;
                              actualizar();

                            });


                            Navigator.pop(context);
                          }),
                    ]);
                },
              )

          );
        });
  }
}
