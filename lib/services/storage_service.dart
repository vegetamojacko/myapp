import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/claim.dart';

class StorageService {
  static const _claimsKey = 'claims';

  Future<void> saveClaims(List<Claim> claims) async {
    final prefs = await SharedPreferences.getInstance();
    final claimsJson = claims.map((claim) => claim.toJson()).toList();
    await prefs.setString(_claimsKey, json.encode(claimsJson));
  }

  Future<List<Claim>> loadClaims() async {
    final prefs = await SharedPreferences.getInstance();
    final claimsString = prefs.getString(_claimsKey);
    if (claimsString != null) {
      final List<dynamic> claimsJson = json.decode(claimsString);
      return claimsJson.map((json) => Claim.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> clearClaims() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claimsKey);
  }
}
