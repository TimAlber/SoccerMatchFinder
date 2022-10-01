import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  Future<bool> signIn({
    required String email,
    required String pw,
  }) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pw);
      return true;
    } catch (e) {
      Logger().e(e);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String pw,
    required String username
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );
      await credential.user?.updateDisplayName(username);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        return false;
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
    return false;
  }
}