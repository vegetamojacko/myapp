import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/claim.dart';

class StorageService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Claim>> getClaimsStream() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]); // Return an empty stream if no user is logged in
    }

    final ref = _database.ref('users/${currentUser.uid}/claims');

    return ref.onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        if (data is List) {
          return data
              .map((claim) => Claim.fromJson(Map<String, dynamic>.from(claim)))
              .toList();
        } else if (data is Map) {
          // Handle if data is a map (e.g., from older versions)
          return [Claim.fromJson(Map<String, dynamic>.from(data))];
        }
      }
      return [];
    });
  }

  Future<void> saveClaims(List<Claim> claims) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final claimsJson = claims.map((claim) => claim.toJson()).toList();
      await _database.ref('users/${currentUser.uid}/claims').set(claimsJson);
    }
  }

  Future<List<Claim>> loadClaims() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final snapshot = await _database
          .ref('users/${currentUser.uid}/claims')
          .get();
      if (snapshot.exists) {
        final List<dynamic> claimsJson = snapshot.value as List<dynamic>;
        return claimsJson.map((json) => Claim.fromJson(json)).toList();
      }
    }
    return [];
  }

  Future<void> clearClaims() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _database.ref('users/${currentUser.uid}/claims').remove();
    }
  }
}
