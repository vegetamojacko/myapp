import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CarWash {
  final String id;
  final String name;
  final String address;
  final double price;

  CarWash({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
  });

  factory CarWash.fromJson(String id, Map<dynamic, dynamic> json) {
    return CarWash(
      id: id,
      name: json['name'],
      address: json['address'],
      price: json['price'].toDouble(),
    );
  }
}

class CarWashProvider with ChangeNotifier {
  List<CarWash> _carWashes = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  List<CarWash> get carWashes => _carWashes;

  Future<void> loadCarWashes() async {
    try {
      final snapshot = await _database.child('carWashes').get();
      if (snapshot.exists) {
        final carWashesData = snapshot.value as Map<dynamic, dynamic>;
        final List<CarWash> loadedCarWashes = [];
        carWashesData.forEach((id, carWashData) {
          loadedCarWashes.add(CarWash.fromJson(id, carWashData));
        });
        _carWashes = loadedCarWashes;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading car washes: $e');
    }
  }
}
