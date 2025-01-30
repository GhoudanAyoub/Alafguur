import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../app/service/random_service.dart';

class FirebaseAuthService {
  final String twitterConsumerKey;
  final String twitterConsumerSecret;
  final RandomService randomService;
  final String appleConnectClientId;
  final String apiProtocol;
  final String apiDomain;
  final String bundleName;
  final bool isPwaMode;

  FirebaseAuthService({
    required this.twitterConsumerKey,
    required this.twitterConsumerSecret,
    required this.randomService,
    required this.appleConnectClientId,
    required this.apiProtocol,
    required this.apiDomain,
    required this.bundleName,
    required this.isPwaMode,
  });

  Future<UserCredential?> appleSignIn() {
    return !kIsWeb ? _nativeAppleSignIn() : _webAppleSignIn();
  }

  Future<UserCredential?> googleSignIn() {
    return !kIsWeb ? _nativeGoogleSignIn() : _webGoogleSignIn();
  }

  Future<UserCredential?> facebookSignIn() {
    return !kIsWeb ? _nativeFacebookSignIn() : _webFacebookSignIn();
  }

  // TODO: replace flutter_twitter_login
  // Future<UserCredential?> twitterSignIn() {
  //   return !kIsWeb ? _nativeTwitterSignIn() : _webTwitterSignIn();
  // }

  Future<UserCredential> _nativeGoogleSignIn() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    ) as GoogleAuthCredential;

    FirebaseAuth auth = FirebaseAuth.instance;

    // Once signed in, return the UserCredential
    return await auth.signInWithCredential(credential);
  }

  Future<UserCredential> _nativeAppleSignIn() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = randomService.generateNonce();
    final nonce = randomService.sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: appleConnectClientId,
        redirectUri: Uri.parse(
          '$apiProtocol://$apiDomain/firebaseauth/android-redirect?package=$bundleName',
        ),
      ),
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    FirebaseAuth auth = FirebaseAuth.instance;

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await auth.signInWithCredential(oauthCredential);
  }

  Future<UserCredential?> _webAppleSignIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final appleProvider = OAuthProvider('apple.com');

    appleProvider.addScope('name');
    appleProvider.addScope('email');

    if (isPwaMode) {
      await auth.signInWithRedirect(appleProvider);

      return null;
    }

    return await auth.signInWithPopup(appleProvider);
  }

  Future<UserCredential?> getPwaRedirectAuthResult() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    return await auth.getRedirectResult();
  }

  Future<UserCredential?> _webGoogleSignIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('profile');
    googleProvider.addScope('email');

    if (isPwaMode) {
      await auth.signInWithRedirect(googleProvider);

      return null;
    }

    return await auth.signInWithPopup(googleProvider);
  }

  Future<UserCredential?> _webFacebookSignIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FacebookAuthProvider facebookProvider = FacebookAuthProvider();

    facebookProvider.addScope('email');
    facebookProvider.setCustomParameters({
      'display': 'popup',
    });

    if (isPwaMode) {
      await auth.signInWithRedirect(facebookProvider);

      return null;
    }

    return await auth.signInWithPopup(facebookProvider);
  }

  Future<UserCredential> _nativeFacebookSignIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    final LoginResult result = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString)
            as FacebookAuthCredential;

    // Once signed in, return the UserCredential
    return await auth.signInWithCredential(facebookAuthCredential);
  }

  // TODO: replace flutter_twitter_login
  // Future<UserCredential?> _webTwitterSignIn() async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   TwitterAuthProvider twitterProvider = TwitterAuthProvider();

  //   if (isPwaMode) {
  //     await auth.signInWithRedirect(twitterProvider);

  //     return null;
  //   }

  //   return await auth.signInWithPopup(twitterProvider);
  // }

  // TODO: replace flutter_twitter_login
  // Future<UserCredential> _nativeTwitterSignIn() async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //
  //   // Create a TwitterLogin instance
  //   final TwitterLogin twitterLogin = TwitterLogin(
  //     consumerKey: twitterConsumerKey,
  //     consumerSecret: twitterConsumerSecret,
  //   );
  //
  //   // Trigger the sign-in flow
  //   final TwitterLoginResult loginResult = await twitterLogin.authorize();
  //
  //   // Get the Logged In session
  //   final TwitterSession twitterSession = loginResult.session!;
  //
  //   // Create a credential from the access token
  //   final AuthCredential twitterAuthCredential = TwitterAuthProvider.credential(
  //     accessToken: twitterSession.token,
  //     secret: twitterSession.secret,
  //   );
  //
  //   // Once signed in, return the UserCredential
  //   return await auth.signInWithCredential(twitterAuthCredential);
  // }
}
