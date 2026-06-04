import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class OAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? 
    (throw Exception('GOOGLE_WEB_CLIENT_ID has not set in .env')), 
  );

  Future<GoogleSignInAccount?> loginGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      if (user != null) {
      debugPrint('Google Sign-In successful');
      debugPrint('User: ${user.displayName}, Email: ${user.email}');        
      return user; 
      } else {
      debugPrint('User not found');        
      return null;
      }
    } catch (error) {
      debugPrint('OAuth failed: $error');      
      return null;
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }
}