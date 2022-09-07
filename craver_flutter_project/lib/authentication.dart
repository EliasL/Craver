//https://github.com/auth0-blog/flutter-authentication

// [deprication] warning is a known problem
// https://github.com/mogol/flutter_secure_storage/issues/162

/// -----------------------------------
///          External Packages
/// -----------------------------------

import 'dart:convert';

import 'package:craver/pages/control_panel.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bottom_nav.dart';
import 'support/settings.dart' as settings;
import 'dart:async';
import 'dart:developer' as dev;
import 'support/alert.dart';

const FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

/// -----------------------------------
///           Auth0 Variables
/// -----------------------------------

const String AUTH0_DOMAIN = 'cern';
const String AUTH0_CLIENT_ID = 'craver';
const String AUTH0_REDIRECT_URI = 'ch.cern.auth0.craver://login-callback';
const String AUTH0_ISSUER = 'https://auth.cern.ch/auth/realms/cern';

/// -----------------------------------
///           Profile Widget
/// -----------------------------------

class Profile extends StatelessWidget {
  final Future<void> Function() logoutAction;
  final String name;
  final String? picture;

  const Profile(this.logoutAction, this.name, this.picture, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        // Looks better without anything...
        // Consider creating an articifical delay
        //Text('Logged in as ${settings.userName}'),
        //const Text('Loading control panel...'),
      ],
    );
  }
}

/// -----------------------------------
///            Login Widget
/// -----------------------------------

class Login extends StatelessWidget {
  final Future<void> Function() loginAction;
  final VoidCallback loginAsGuestAction;
  final String loginError;

  const Login(this.loginAction, this.loginAsGuestAction, this.loginError,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            await loginAction();
          },
          child: const Text('Log in with CERN account'),
        ),
        Text(
          loginError,
          style: TextStyle(color: Colors.red[800]),
        ),
        ElevatedButton(
          onPressed: () {
            loginAsGuestAction();
          },
          child: const Text('Continue as guest'),
        ),
      ],
    );
  }
}

/// -----------------------------------
///          Authentication
/// -----------------------------------

class Authentication extends StatefulWidget {
  static Future<void> logout(context) async {
    ControlPanel.stopTimer();
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => Authentication(
                logout_on_init: true,
              )),
    );
  }

  bool logout_on_init;
  Authentication({Key? key, this.logout_on_init = false}) : super(key: key);

  @override
  State<Authentication> createState() => _AuthenticationState();
}

/// -----------------------------------
///       Authentication State
/// -----------------------------------

class _AuthenticationState extends State<Authentication> {
  static bool isBusy = false;
  static bool isLoggedIn = false;
  String errorMessage = '';
  String name = '';
  String picture = '';

  static Timer? timer;

  // Timer to refresh the token
  void startTimer() {
    // Only let there be one timer
    timer?.cancel();
    timer = Timer.periodic(
        // The token expires after 20 minutes
        const Duration(minutes: 15),
        (Timer t) => refreshToken());
  }

  @override
  void dispose() {
    //timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Log in')),
      ),
      body: Center(
        child: isBusy
            ? const CircularProgressIndicator()
            : isLoggedIn
                ? Profile(logoutAction, name, picture)
                : Login(loginAction, loginAsGuestAction, errorMessage),
      ),
    );
  }

  Map<String, Object> parseIdToken(String idToken) {
    final List<String> parts = idToken.split('.');
    assert(parts.length == 3);
    return Map<String, Object>.from(jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))));
  }

  Future<Map<String, Object>> getUserDetails(String accessToken) async {
    Uri url = Uri.parse(
        'https://auth.cern.ch/auth/realms/cern/protocol/openid-connect/userinfo');
    final http.Response response = await http.get(
      url,
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return Map<String, Object>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<void> handleToken(TokenResponse? token) async {
    // Do what you want to usually do with the token
    final Map<String, Object> idToken = parseIdToken(token!.idToken!);
    final Map<String, Object> profile =
        await getUserDetails(token.accessToken!);

    await secureStorage.write(key: 'refresh_token', value: token.refreshToken);

    settings.userName = idToken['name'] as String;
    settings.idToken = token.idToken!;
    isLoggedIn = true;
    isBusy = false;
  }

  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'refresh_token');
    settings.userName = 'Guest';
    settings.idToken = '';
    isLoggedIn = false;
    isBusy = false;
  }

  Future<void> refreshToken() async {
    dev.log('refreshing token');
    final String? storedRefreshToken =
        await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) return;

    try {
      final TokenResponse? response = await appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: AUTH0_ISSUER,
        refreshToken: storedRefreshToken,
      ));

      await handleToken(response);
      return;
    } on Exception catch (e, s) {
      debugPrint('error on refresh token: $e - stack: $s');
      showLogoutDialog('Authentication error!',
          'Error trying to refresh token. Please log in again.');
    }
  }

  Future<void> loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: AUTH0_ISSUER,
          scopes: <String>['openid', 'profile', 'offline_access'],
          promptValues: ['login'],
        ),
      );

      await handleToken(result);

      settings.loggedIn = true;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNav()),
      );
      return;
    } on Exception catch (e, s) {
      debugPrint('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        errorMessage = 'Log in failed. Please try again';
      });
    }
  }

  Future<void> loginAsGuestAction() async {
    await deleteToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BottomNav()),
    );
  }

  Future<void> logoutAction() async {
    settings.loggedIn = false;
    await secureStorage.delete(key: 'refresh_token');
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  @override
  void initState() {
    initAction();
    super.initState();
  }

  Future<void> initAction() async {
    if (widget.logout_on_init) {
      await logoutAction();
    }
    setState(() {
      isBusy = true;
    });
    startTimer();
    await refreshToken();
    setState(() {
      isBusy = false;
    });
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNav()),
      );
    }
  }
}
