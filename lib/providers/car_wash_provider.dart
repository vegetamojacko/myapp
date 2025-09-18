import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  factory CarWash.fromJson(String id, Map<String, dynamic> json) {
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

  List<CarWash> get carWashes => _carWashes;

  Future<void> loadCarWashes() async {
    try {
      final String response = await rootBundle.loadString('assets/car_washes.json');
      final data = await json.decode(response);
      final carWashesData = data['car_washes'] as Map<String, dynamic>;
      final List<CarWash> loadedCarWashes = [];
      carWashesData.forEach((id, carWashData) {
        loadedCarWashes.add(CarWash.fromJson(id, carWashData));
      });
      _carWashes = loadedCarWashes;
      notifyListeners();
    } catch (e) {
      print('Error loading car washes: $e');
    }
  }
}
