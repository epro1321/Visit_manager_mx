import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/visit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// ignore: unused_import
import 'package:intl/intl.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'visits_database.db');
      return openDatabase(
        path,
        onCreate: (db, version) {
          _createDatabase(db);
        },
        onUpgrade: (db, oldVersion, newVersion) {
          if (oldVersion < 2) {
            _upgradeVersion1To2(db);
          }
        },
        version: 2,
      );
    } catch (e) {
      throw Exception('Error initializing database: $e');
    }
  }

  void _createDatabase(Database db) {
    db.execute(
      'CREATE TABLE visits(id TEXT PRIMARY KEY, name TEXT, company TEXT, reason TEXT, phone TEXT, email TEXT, department TEXT, visitTime TEXT, exitTime TEXT, signature BLOB, photo BLOB)',
    );
    db.execute('CREATE INDEX idx_visits_name_phone ON visits (name, phone)');
  }

  void _upgradeVersion1To2(Database db) {
    db.execute('ALTER TABLE visits ADD COLUMN exitTime TEXT;');
    db.execute('ALTER TABLE visits ADD COLUMN photo BLOB;');
  }

  Future<void> insertVisit(Visit visit) async {
    final db = await database;
    try {
      await db.insert(
        'visits',
        visit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error inserting visit: $e');
    }
  }

  Future<void> updateVisit(Visit visit) async {
    final db = await database;
    try {
      await db.update(
        'visits',
        visit.toMap(),
        where: 'id = ?',
        whereArgs: [visit.id],
      );
    } catch (e) {
      throw Exception('Error updating visit: $e');
    }
  }

  Future<void> insertExitTime(
      String name, String phone, DateTime exitTime) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'visits',
        where: 'name = ? AND phone = ?',
        whereArgs: [name, phone],
        orderBy: 'visitTime DESC',
      );

      if (maps.isNotEmpty) {
        // Verificar si ya existe un registro de salida para hoy
        bool hasExitedToday = maps.any((map) => map['exitTime'] != null);

        if (!hasExitedToday) {
          // Si no ha registrado salida hoy, insertar nueva visita como entrada
          Visit newVisit = Visit(
            id: UniqueKey()
                .toString(), // Generar un nuevo ID único para la nueva visita
            name: name,
            company: maps.first['company'],
            reason: maps.first['reason'],
            phone: phone,
            email: maps.first['email'],
            department: maps.first['department'],
            visitTime: DateTime.now(),
            exitTime: null,
            signature: null,
            photo: null,
          );

          await insertVisit(newVisit);
        } else {
          // Si ya ha registrado salida hoy, actualizar el registro existente con la hora de salida
          Visit lastVisit = Visit.fromMap(maps.first);
          lastVisit.exitTime = exitTime;
          await updateVisit(lastVisit);
        }
      } else {
        // Si no hay registros, lanzar una excepción o manejar el caso según sea necesario
        throw Exception(
            'No se encontró un registro existente para actualizar.');
      }
    } catch (e) {
      throw Exception('Error updating exit time: $e');
    }
  }

  Future<List<Visit>> getVisits() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('visits');
      return List.generate(maps.length, (i) {
        return Visit.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Error fetching visits: $e');
    }
  }

  Future<void> deleteVisit(String id) async {
    final db = await database;
    try {
      await db.delete(
        'visits',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting visit: $e');
    }
  }

  Future<void> deleteRecordsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    try {
      await db.delete(
        'visits',
        where: 'visitTime >= ? AND visitTime < ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );
    } catch (e) {
      throw Exception('Error deleting records by date: $e');
    }
  }
}
