import 'package:firebase_auth/firebase_auth.dart';

Future<void> signInUserAnon() async {
  try {
    final UserCredential = await FirebaseAuth.instance.signInAnonymously();
    print("Signed in with temporary account. UID: ${UserCredential.user?.uid}");
  }
  catch (e) {
    print(e);
  }
}