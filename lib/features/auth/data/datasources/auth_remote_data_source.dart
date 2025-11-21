import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithGoogle();
  Future<UserModel> loginWithFacebook();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FacebookAuth facebookAuth;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.facebookAuth,
  });

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      if (userCredential.user == null) {
        throw const ServerFailure('Firebase Auth failed');
      }
      return UserModel.fromFirebase(userCredential.user!);
    } catch (e, s) {
      print('Google Login Error: $e');
      print('Stack trace: $s');
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> loginWithFacebook() async {
    try {
      final LoginResult result = await facebookAuth.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final AuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );
        final UserCredential userCredential = await firebaseAuth
            .signInWithCredential(credential);

        if (userCredential.user == null) {
          throw const ServerFailure('Firebase Auth failed');
        }
        return UserModel.fromFirebase(userCredential.user!);
      } else {
        print('Facebook Login Failed: ${result.message}');
        throw ServerFailure('Facebook Login failed: ${result.message}');
      }
    } catch (e, s) {
      print('Facebook Login Error: $e');
      print('Stack trace: $s');
      throw ServerFailure(e.toString());
    }
  }
}
