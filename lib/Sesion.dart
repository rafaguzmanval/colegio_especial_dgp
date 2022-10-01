
class Sesion{
   static var id;
   static var nombre;
   static var rol;
   static var misTareas;
   static var seleccion;
   static var paginaActual;

   static reload(){
      id = null;
      nombre = null;
      rol = null;
      misTareas = [];
      seleccion = null;

   }

   Sesion(){
      id = null;
      nombre = null;
      rol = null;
      misTareas = [];
      seleccion = null;
   }
}