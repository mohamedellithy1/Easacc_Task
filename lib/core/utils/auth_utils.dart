import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn.instance.signOut();
  await FacebookAuth.instance.logOut();
}
