/*
*   Archivo: registro_usuarios.dart
*
*   Descripción:
*   Formulario de registro de usuarios
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   passport_method.dart: Enumeracion de los metodos de acceso.
*   usuario.dart: Objeto usuario que va a introducirse en la base de datos.
*   image_picker.dart : Libreria para acceder a la cámara y a la galería de imagenes del dispositivo.
* */

import 'dart:io';
import 'package:colegio_especial_dgp/Dart/passport_method.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';
import 'package:flutter/material.dart';
import "package:image_picker/image_picker.dart";
import 'package:intl/intl.dart';

enum SeleccionImagen { camara, galeria }

class RegistroUsuarios extends StatefulWidget {
  @override
  RegistroUsuariosState createState() => RegistroUsuariosState();
}

class RegistroUsuariosState extends State<RegistroUsuarios> {
  var fotoTomada;
  ImagePicker capturador = new ImagePicker();

  var registrando = false;
  var mensajeDeRegistro = "";
  var rolElegido = "NINGUN ROL ELEGIDO";
  var fechaElegida = null;

  final controladorNombre = TextEditingController();
  final controladorApellidos = TextEditingController();
  final controladorPassword = TextEditingController();

  var pictogramasPin = [
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpin%2Fconejo.png?alt=media&token=b93aefd5-f2f8-4056-949d-863b6bbec317",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpin%2Fduende.png?alt=media&token=3fc18f70-ecce-4d23-8506-79a7bc048b87",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpin%2Fmariposa.png?alt=media&token=acb62a95-3373-4ec0-82e2-881fb5a8ab5e",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpin%2Fprincesa.png?alt=media&token=d890b321-1136-41e4-8317-0f7f2fb88689"
  ];

  var metodos = ["clave", "pin"];
  var metodoElegido = "clave";
  var pulsaciones = 0;
  var ordenPin = ["", "", "", ""];

  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;
  }

  ///introduce en el atributo @fototomada la imagen, @seleccion nos indica si el método va a ser desde la cámara o de galería
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

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Center(
            child: Text(
              'REGISTRA UN NUEVO USUARIO',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold,color: GuardadoLocal.colores[2], fontSize: 30),
            ),
          )),
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          child: Column(
            children: [
              if (Sesion.rol == Rol.alumno.toString()) ...[
                VistaAlumno(),
              ] else if (Sesion.rol == Rol.profesor.toString()) ...[
                VistaProfesor()
              ] else if (Sesion.rol == Rol.administrador.toString()) ...[
                VistaAdministrador()
              ]
            ],
          )),
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    Navigator.pop(context);
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    Navigator.pop(context);
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return Container(
      alignment: Alignment.center,
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 15,
          ),

          DropdownButton(
            style: TextStyle(color: GuardadoLocal.colores[0]),
            value: rolElegido,
            items: [
              Rol.profesor.toString(),
              Rol.administrador.toString(),
              Rol.alumno.toString(),
              "NINGUN ROL ELEGIDO"
            ].map((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 25),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                controladorPassword.text = "";
                rolElegido = value!;
              });
            },
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: GuardadoLocal.colores[0]),
              obscureText: false,
              maxLength: 20,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'INTRODUCE EL NOMBRE *',
                  hintStyle:
                      TextStyle(fontWeight: FontWeight.bold,color: GuardadoLocal.colores[0], fontSize: 25)),
              controller: controladorNombre,
            ),
          ),
          SizedBox(
            width: 500,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: GuardadoLocal.colores[0]),
              obscureText: false,
              maxLength: 40,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'INTRODUCE LOS APELLIDOS *',
                  hintStyle:
                      TextStyle(fontWeight: FontWeight.bold,color: GuardadoLocal.colores[0], fontSize: 25)),
              controller: controladorApellidos,
            ),
          ),
          DropdownButton(
            style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 25),
            value: metodoElegido,
            items: metodos.map((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 25),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                metodoElegido = value!;
              });
            },
          ),
          SizedBox(height: 10,),
          Visibility(
              visible: metodoElegido == "clave",
              child: SizedBox(
                width: 500,

                child: TextField(
                  style:
                      TextStyle(color: GuardadoLocal.colores[0], fontSize: 25),
                  obscureText: true,
                  maxLength: 20,
                  decoration: InputDecoration(
                      focusColor: GuardadoLocal.colores[0],
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: GuardadoLocal.colores[0], width: 0.0),
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'INTRODUCE LA CONTRASEÑA *',
                      hintStyle: TextStyle(fontWeight: FontWeight.bold,
                          color: GuardadoLocal.colores[0], fontSize: 25)),
                  controller: controladorPassword,
                ),
              )),
          Visibility(
              visible: metodoElegido == "pin",
              child: Container(
                width: 400,
                height: 400,
                child: vistaPin(),
              )),
          Text(
            "INTRODUCE LA FECHA DE NACIMIENTO: *",
            style: TextStyle(
                fontSize: 25.0, height: 2.0, color: GuardadoLocal.colores[0]),
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
                    .then((e) {
                  fechaElegida = e;
                  actualizar();
                });
              },
              child: Column(children: [
                Text(
                  (fechaElegida == null)
                      ? "SIN FECHA"
                      : DateFormat('d/M/y').format(fechaElegida),
                  style:
                      TextStyle(fontWeight: FontWeight.bold,color: GuardadoLocal.colores[2], fontSize: 25),
                ),
                Image.asset("assets/calendario.png",
                width: 140,
                height: 100,),
                SizedBox(height: 10,)
              ]),
              style: ElevatedButton.styleFrom(
                  backgroundColor: GuardadoLocal.colores[0])),
          Text(
            "ELIGE FOTO DE PERFIL (OPCINAL):",
            style: TextStyle(
                fontSize: 25.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  child: Image.asset(
                    "assets/camara.png",
                    width: 140,
                    height: 100,
                  ),
                  onPressed: () {
                    seleccionarImagen(SeleccionImagen.camara);
                  }),
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  child: Image.asset('assets/galeria.png',
                    width: 140,
                    height: 100,
                      ),
                  onPressed: () {
                    seleccionarImagen(SeleccionImagen.galeria);
                  }),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 120,
            width: 120,
            child: fotoTomada == null
                ? Center(
                    child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: GuardadoLocal.colores[0])),
                    child: Image.asset(
                      'assets/desconocido.jpg',
                      width: 160,
                      height: 120,
                    ),
                  ))
                : Center(child: Image.file(File(fotoTomada.path))),
          ),
          Text(
            mensajeDeRegistro,
            style: TextStyle(fontSize: 25),
          ),
          Visibility(
              visible: !registrando,
              child: Container(
                  alignment: Alignment.bottomRight,
                  margin: EdgeInsets.only(right: 10),
                  child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(GuardadoLocal.colores[0]),
                ),
                child: Image.asset(
                  "assets/disquete.png",
                  width: 140,
                  height: 100,
                ),
                onPressed: () {
                  registrarUsuario();
                },
              ))),
          Visibility(
              visible: registrando, child: new CircularProgressIndicator()),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget vistaPin() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            concatenarPin("conejo", 0);
                          },
                          child: Column(children: [
                            Text(
                              ordenPin[0],
                              style: TextStyle(color: GuardadoLocal.colores[2]),
                            ),
                            Image.network(pictogramasPin[0])
                          ]))),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            concatenarPin("duende", 1);
                          },
                          child: Column(children: [
                            Text(ordenPin[1]),
                            Image.network(pictogramasPin[1])
                          ]))),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            concatenarPin("mariposa", 2);
                          },
                          child: Column(children: [
                            Text(ordenPin[2]),
                            Image.network(pictogramasPin[2])
                          ]))),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            concatenarPin("princesa", 3);
                          },
                          child: Column(children: [
                            Text(ordenPin[3]),
                            Image.network(pictogramasPin[3])
                          ]))),
                ),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () {
                resetPin();
              },
              child: Text(
                "VOLVER A INTRODUCIR",
                style: TextStyle(fontSize: 25),
              )),
        ]);
  }

  resetPin() {
    controladorPassword.text = "";
    pulsaciones = 0;
    ordenPin = ["", "", "", ""];
    actualizar();
  }

  concatenarPin(String nuevo, id) {
    pulsaciones++;
    controladorPassword.text += nuevo;
    ordenPin[id] += " " + pulsaciones.toString();
    actualizar();
  }

  onDateChanged() {}

  //Método para registrar usuario
  registrarUsuario() {
    // FALTARIA HACER COMPROBACIÓN DE QUE EL NOMBRE Y APELLIDOS YA ESTÁN REGISTRADOS EN LA BASE DE DATOS

    if (controladorNombre.text.isNotEmpty &&
        controladorApellidos.text.isNotEmpty &&
        controladorPassword.text.isNotEmpty &&
        fechaElegida != null &&
        rolElegido != "ningun rol elegido") {
      registrando = true;
      actualizar();

      var nombre = "" + controladorNombre.text;
      var apellidos = "" + controladorApellidos.text;
      var password = "" + controladorPassword.text;
      var fechanacimiento = "" + DateFormat('d/M/y').format(fechaElegida);
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
        foto = File(fotoTomada.path);
      }


      Future<bool> future = Sesion.db.registrarUsuario(usuario, foto);

      future.then((value) {
        registrando = false;

        if (value) {
          controladorNombre.text = "";
          controladorApellidos.text = "";
          controladorPassword.text = "";

          fotoTomada = null;
          resetPin();
          metodoElegido = "clave";
          fechaElegida = null;
          rolElegido = "NINGUN ROL ELEGIDO";

          mensajeDeRegistro =
              "REGISTRO COMPLETADO\nPUEDES VOLVER A REGISTRAR OTRO USUARIO";
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
  }

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
  /*
  Future<Null> _selectDate(BuildContext context) async{
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      firstDate: DateTime(1940),
      lastDate: DateTime(2101));

    if(picked != null)
      setState(() {
        fechaElegida = picked;
        Date
        controladorFechanacimiento.text = DateFormat.yMd().format(fechaElegida);
      });
  }*/

  // Metodo para actualizar la pagina
  void actualizar() async {
    setState(() {});
  }
}
