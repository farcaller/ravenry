// Copyright 2022 Vladimir Pouzanov <farcaller@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glog/glog.dart';
import 'package:res_client/client.dart';
import 'package:res_client/error.dart';
import 'package:res_client/event.dart';
import 'package:res_client/password.dart';

const logger = GlogContext('client_provider');

const kAuthUsername = 'AUTH_USERNAME';
const kAuthPassword = 'AUTH_PASSWORD';
const kAuthDomain = 'AUTH_DOMAIN';
const kAuthMuckletName = 'AUTH_MUCKLET_NAME';
const kAuthMuckletApi = 'AUTH_MUCKLET_API';

typedef ClientConfiguredCallback = void Function(ResClient client);

class ClientState extends StatefulWidget {
  final Widget child;

  const ClientState({Key? key, required this.child}) : super(key: key);

  @override
  State<ClientState> createState() => ClientStateState();
}

class ClientStateState extends State<ClientState> {
  String? _apiEndpont;
  late final ResClient _client;
  StreamSubscription? _clientEvents;

  final _storage = const FlutterSecureStorage();
  bool _authSuccessful = false;
  String? _authError;
  Completer<bool> _authResolved = Completer();
  bool _isAuthenticating = false;

  ClientStateState() {
    _client = ResClient(authCallback: _authCallback);
    _client.events.listen(onResEvent);
  }

  @override
  dispose() {
    if (_clientEvents != null) {
      _clientEvents!.cancel();
    }
    super.dispose();
  }

  Future<bool> get authResolved => _authResolved.future;
  Future<bool> _authCallback() => authResolved;

  onResEvent(ResEvent event) {
    if (event is DisconnectedEvent) {
      logger.debug('authProvider resetting due to disconnect');
      if (!mounted) return;
      setState(() {
        _authResolved = Completer();
        _authSuccessful = false;
        _isAuthenticating = false;
      });

      _client.reconnect(Uri.parse(_apiEndpont!));
    }
  }

  setClient(String api) async {}

  Future<bool> hasStoredCredentials() async {
    if ((await _storage.read(key: kAuthUsername) ?? '').isEmpty) return false;
    if ((await _storage.read(key: kAuthPassword) ?? '').isEmpty) return false;
    if ((await _storage.read(key: kAuthMuckletApi) ?? '').isEmpty) return false;
    return true;
  }

  Future<bool> tryLogin({String? login, String? password, String? api}) async {
    if (_isAuthenticating) return authResolved;
    _isAuthenticating = true;

    if (_authSuccessful) return true;
    logger.debug('trying auth for $login');
    final resolvedLogin =
        login ?? await _storage.read(key: kAuthUsername) ?? '';
    final resolvedPassword =
        password ?? await _storage.read(key: kAuthPassword) ?? '';
    final resolvedApi = api ?? await _storage.read(key: kAuthMuckletApi) ?? '';

    if (resolvedLogin.isEmpty ||
        resolvedPassword.isEmpty ||
        resolvedApi.isEmpty) {
      logger.info('no stored credentials');
      _isAuthenticating = false;
      return false;
    }

    if (_apiEndpont != resolvedApi) {
      _apiEndpont = resolvedApi;
      if (_clientEvents != null) {
        _clientEvents!.cancel();
        _clientEvents = null;
      }
      await _client.reconnect(Uri.parse(_apiEndpont!));
    }

    if (!mounted) {
      _isAuthenticating = false;
      return false;
    }
    setState(() => _authError = null);

    try {
      await _client.auth('auth', 'login', params: {
        'name': resolvedLogin,
        'hash': saltPassword(resolvedPassword),
      });
    } catch (e) {
      if (!mounted) return false;
      setState(() => _authError = e is ResError ? e.message : e.toString());
      _isAuthenticating = false;
      return false;
    }

    if (resolvedLogin.isNotEmpty &&
        resolvedPassword.isNotEmpty &&
        resolvedApi.isNotEmpty) {
      logger.info('storing credentials for $login');
      await _storage.write(key: kAuthUsername, value: resolvedLogin);
      await _storage.write(key: kAuthPassword, value: resolvedPassword);
      await _storage.write(key: kAuthMuckletApi, value: resolvedApi);
    }
    if (!mounted) {
      _isAuthenticating = false;
      return false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _authSuccessful = true;
        _authResolved.complete(true);
      });
    });
    logger.info('authenticated successfully');
    _isAuthenticating = false;
    return true;
  }

  Future<void> _logout() async {
    await _storage.write(key: kAuthUsername, value: '');
    await _storage.write(key: kAuthPassword, value: '');
    await _storage.write(key: kAuthMuckletApi, value: '');
    _client.forceClose();

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return ClientProvider(
        client: _client,
        authSuccessful: _authSuccessful,
        authError: _authError,
        tryLogin: tryLogin,
        logout: _logout,
        hasStoredCredentials: hasStoredCredentials,
        child: widget.child);
  }
}

class ClientProvider extends InheritedWidget {
  final ResClient client;

  final bool authSuccessful;
  final String? authError;
  final Future<bool> Function({String? login, String? password, String? api})
      tryLogin;
  final Future<void> Function() logout;
  final Future<bool> Function() hasStoredCredentials;

  const ClientProvider({
    super.key,
    required super.child,
    required this.client,
    required this.authSuccessful,
    required this.authError,
    required this.tryLogin,
    required this.logout,
    required this.hasStoredCredentials,
  });

  @override
  bool updateShouldNotify(covariant ClientProvider oldWidget) {
    return client != oldWidget.client ||
        authSuccessful != oldWidget.authSuccessful ||
        authError != oldWidget.authError;
  }

  static ClientProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClientProvider>()!;
  }
}
