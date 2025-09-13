import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> register(
    String email,
    String password,
    String name,
    String whatsapp,
  ) async {
    User? user;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'whatsapp': whatsapp,
          'createdAt': FieldValue.serverTimestamp(),
        });
        // Successfully created user and saved data
        return user;
      }
      // This should not happen if createUserWithEmailAndPassword succeeds
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific auth errors (e.g., email-already-in-use)
      developer.log('FirebaseAuthException: ${e.message}', name: 'AuthService.register', error: e);
      rethrow;
    } catch (e, s) {
      developer.log(
        'An error occurred while saving user data to Firestore.',
        name: 'AuthService.register',
        error: e,
        stackTrace: s
      );
      // Rollback: Delete the user from Auth if Firestore write fails
      if (user != null) {
        try {
          await user.delete();
          developer.log('Successfully rolled back user creation for UID: ${user.uid}', name: 'AuthService.register');
        } catch (deleteError) {
          developer.log('Error rolling back user creation for UID: ${user.uid}', name: 'AuthService.register', error: deleteError);
          // If rollback fails, this is a critical state. Log it.
        }
      }
      // Let the UI layer know that registration failed.
      throw Exception('Registration failed: Could not save user details.');
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException on sign in: ${e.message}', name: 'AuthService.signIn', error: e);
      rethrow;
    } catch (e, s) {
      developer.log('Unexpected error on sign in.', name: 'AuthService.signIn', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
