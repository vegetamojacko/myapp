import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarWash {
  final String id;
  final String name;

  CarWash({required this.id, required this.name});
}

class CarWashProvider with ChangeNotifier {
  List<CarWash> _carWashes = [];

  List<CarWash> get carWashes => _carWashes;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadCarWashes() async {
    await fetchCarWashes();
  }

  Future<void> fetchCarWashes() async {
    try {
      final snapshot = await _firestore.collection('car_washes').get();
      _carWashes = snapshot.docs
          .map((doc) => CarWash(id: doc.id, name: doc['name']))
          .toList();
      notifyListeners();
    } catch (error) {
      print('Error fetching car washes: $error');
    }
  }

  Future<void> addCarWash(String name) async {
    try {
      final existingCarWashes = await _firestore
          .collection('car_washes')
          .where('name', isEqualTo: name)
          .get();

      if (existingCarWashes.docs.isEmpty) {
        await _firestore.collection('car_w ashes').add({'name': name});
        fetchCarWashes(); // Refresh the list after adding
      }
    } catch (error) {
      print('Error adding car wash: $error');
    }
  }
}
