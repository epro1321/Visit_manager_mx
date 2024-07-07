import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_service.dart';
// ignore: unused_import
import 'package:flutter_application_1/models/visit.dart';

class OutFormScreen extends StatefulWidget {
  final String name;
  final String phone;
  final Color backgroundColor; // Nuevo campo para el color de fondo

  const OutFormScreen({
    Key? key,
    required this.name,
    required this.phone,
    this.backgroundColor = Colors.white, // Color de fondo por defecto
  }) : super(key: key);

  @override
  _OutFormScreenState createState() => _OutFormScreenState();
}

class _OutFormScreenState extends State<OutFormScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  late String name;
  late String phone;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    phone = widget.phone;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _dbService.insertExitTime(name, phone, DateTime.now());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hora de salida registrada')),
        );
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar hora de salida: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(238, 71, 36, 1),
        title: Image.asset(
          'assets/images/logo.png',
          width: 250,
          height: 50,
        ),
      ),
      backgroundColor: widget.backgroundColor, // Color de fondo de la pantalla
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              Text(
                'Registro de Salida',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Color.fromRGBO(20, 59, 92, 1)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Color.fromRGBO(20, 59, 92, 1)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(0, 0, 0, 1)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    phone = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  'Registrar salida',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(238, 71, 36, 1),
                  minimumSize: Size(200, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
