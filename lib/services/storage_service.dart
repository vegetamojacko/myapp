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
      return Stream.value([]);
    }

    final ref = _database.ref('users/${currentUser.uid}/claims');

    return ref.onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        List<Claim> claims = [];
        if (data is List) {
          // It's a dense list, filter out any nulls
          claims = data
              .where((item) => item != null && item is Map)
              .map((item) => Claim.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        } else if (data is Map) {
          // It's a sparse list (map with int keys) or just a map of claims.
          // Iterate over values to be safe.
          for (final item in data.values) {
            if (item != null && item is Map) {
              try {
                claims.add(Claim.fromJson(Map<String, dynamic>.from(item)));
              } catch (e) {
                print('Error parsing a claim from map: $e');
              }
            }
          }
        }
        return claims;
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
    if (currentUser == null) {
      return [];
    }

    final snapshot = await _database.ref('users/${currentUser.uid}/claims').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = snapshot.value;
      List<Claim> claims = [];
      if (data is List) {
        claims = data
            .where((item) => item != null && item is Map)
            .map((item) => Claim.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      } else if (data is Map) {
        for (final item in data.values) {
          if (item != null && item is Map) {
            try {
              claims.add(Claim.fromJson(Map<String, dynamic>.from(item)));
            } catch (e) {
              print('Error parsing a claim from map: $e');
            }
          }
        }
      }
      return claims;
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
