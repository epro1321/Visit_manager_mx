import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/screens/form_screen.dart';
import 'screens/screens/list_screen.dart';
import 'screens/screens/out_form_screen.dart'; // Importa el archivo de la pantalla de salida

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Visitas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blueGrey[50],
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Color.fromRGBO(243, 243, 243, 1)),
        ),
      ),
      initialRoute: '/form', // Cambia la ruta inicial a '/form'
      routes: {
        '/form': (context) => FormScreen(),
        '/list': (context) => ListScreen(),
        '/out': (context) => OutFormScreen(
              name: '',
              phone: '',
            ), // Nueva ruta para la pantalla de salida
      },
    );
  }
}
