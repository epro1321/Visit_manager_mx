import 'dart:typed_data';

class Visit {
  String id;
  String name;
  String company;
  String reason;
  String phone;
  String email;
  String department;
  DateTime visitTime;
  Uint8List? signature;
  Uint8List? photo;
  DateTime? exitTime; // Añadir este campo

  Visit({
    required this.id,
    required this.name,
    required this.company,
    required this.reason,
    required this.phone,
    required this.email,
    required this.department,
    required this.visitTime,
    this.signature,
    this.photo,
    this.exitTime, // Añadir esto
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'reason': reason,
      'phone': phone,
      'email': email,
      'department': department,
      'visitTime': visitTime.toIso8601String(),
      'signature': signature,
      'photo': photo,
      'exitTime': exitTime?.toIso8601String(), // Añadir esto
    };
  }

  static Visit fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id'],
      name: map['name'],
      company: map['company'],
      reason: map['reason'],
      phone: map['phone'],
      email: map['email'],
      department: map['department'],
      visitTime: DateTime.parse(map['visitTime']),
      signature: map['signature'],
      photo: map['photo'],
      exitTime: map['exitTime'] != null
          ? DateTime.parse(map['exitTime'])
          : null, // Añadir esto
    );
  }
}
