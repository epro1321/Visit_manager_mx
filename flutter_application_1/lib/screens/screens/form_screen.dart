// ignore: unused_import
import 'dart:convert';
import 'dart:io';
// ignore: unused_import
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/visit.dart';
import 'package:flutter_application_1/screens/screens/out_form_screen.dart';
import 'package:flutter_application_1/screens/screens/out_pin_screen.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String company = '';
  String reason = '';
  String phone = '';
  String email = '';
  String department = '';
  File? _photo;
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );

  final ImagePicker _picker = ImagePicker();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_signatureController.isNotEmpty && _photo != null) {
        final signature = await _signatureController.toPngBytes();
        final photoBytes = await _photo!.readAsBytes();
        final newVisit = Visit(
          id: DateTime.now().toString(),
          name: name,
          company: company,
          reason: reason,
          phone: phone,
          email: email,
          department: department,
          visitTime: DateTime.now(),
          signature: signature,
          photo: photoBytes,
        );
        try {
          await _dbService.insertVisit(newVisit);
          _signatureController.clear();
          _formKey.currentState!.reset();
          setState(() {
            _photo = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Visita registrada')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar visita: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, firma y toma una foto')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
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
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PinScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              Text(
                'Registro de Visitas entrada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(10, 40, 65, 1),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre';
                  }
                  return null;
                },
                onChanged: (value) => name = value,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Empresa',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(10, 40, 65, 1),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la empresa';
                  }
                  return null;
                },
                onChanged: (value) => company = value,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Motivo',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(10, 40, 65, 1),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el motivo';
                  }
                  return null;
                },
                onChanged: (value) => reason = value,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(10, 40, 65, 1),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el teléfono';
                  }
                  return null;
                },
                onChanged: (value) => phone = value,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Correo',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(10, 40, 65, 1),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (value) => email = value,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Departamento',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(10, 40, 65, 1),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (value) => department = value,
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Firma:',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      margin: EdgeInsets.all(10),
                      child: Signature(
                        controller: _signatureController,
                        height: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _signatureController.clear();
                      },
                      child: Text(
                        'Limpiar firma',
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
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Foto:',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    _photo != null
                        ? Image.file(
                            _photo!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 200,
                            width: 200,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                          ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text(
                        'Tomar foto',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(238, 71, 36, 1),
                        minimumSize: Size(200, 50),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Registrar visita',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(238, 71, 36, 1),
                      minimumSize: Size(200, 50),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OutFormScreen(
                                  name: '',
                                  phone: '',
                                )),
                      );
                    },
                    child: Text('Registrar salida',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(200, 50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
