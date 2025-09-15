import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/claim.dart';

class StorageService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    final snapshot = await _database.ref('users/${currentUser.uid}/claims').get();
    if (snapshot.exists) {
      final List<dynamic> claimsJson = snapshot.value as List<dynamic>;
      return claimsJson
          .where((json) => json != null) // Filter out null entries
          .map((json) => Claim.fromJson(json as Map<dynamic, dynamic>))
          .toList();
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
