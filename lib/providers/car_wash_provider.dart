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
}

class CarWashProvider with ChangeNotifier {
  final List<CarWash> _carWashes = [
    CarWash(
      id: 'cw001',
      name: 'Sparkle & Shine',
      address: '123 Main St, Anytown',
      price: 150.00,
    ),
    CarWash(
      id: 'cw002',
      name: 'Gleam Team',
      address: '456 Oak Ave, Anytown',
      price: 175.00,
    ),
    CarWash(
      id: 'cw003',
      name: 'The Car Spa',
      address: '789 Pine Ln, Anytown',
      price: 200.00,
    ),
  ];

  List<CarWash> get carWashes => _carWashes;

  // In a real app, you would fetch this from your database
  // Future<void> fetchCarWashes() async {
  //   // Fetch from Firebase and update _carWashes
  //   notifyListeners();
  // }
}
