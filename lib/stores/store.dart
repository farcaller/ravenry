import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glog/glog.dart';
import 'package:mobx/mobx.dart';
import 'package:res_client/client.dart';
import 'package:res_client/error.dart';
import 'package:res_client/event.dart';
import 'package:res_client/model.dart';
import 'package:res_client/password.dart';

part 'store.g.dart';

// ignore: library_private_types_in_public_api
class RootStore = _RootStore with _$RootStore;

const kAuthUsername = 'AUTH_USERNAME';
const kAuthPassword = 'AUTH_PASSWORD';
const kAuthDomain = 'AUTH_DOMAIN';
const kAuthMuckletName = 'AUTH_MUCKLET_NAME';
const kAuthMuckletApi = 'AUTH_MUCKLET_API';

const logger = GlogContext('store');

enum LoginEvent {
  loggedIn,
  loggedOut,
}

abstract class _RootStore with Store {
  final _storage = const FlutterSecureStorage();
  late final ResClient _client;
  Completer<void> _authResolved = Completer();
  final Completer<bool> _credentialsResolved = Completer();
  final StreamController<LoginEvent> _loginStreamController =
      StreamController();
  late final StreamSubscription _clientEvents;

  Stream<LoginEvent> get loginEvents => _loginStreamController.stream;
  Future<bool> get credentialsResolved => _credentialsResolved.future;
  ResClient get client => _client;

  _RootStore() {
    _client = ResClient(authCallback: _resAuth);
    _clientEvents = _client.events.listen(_onResEvent);

    _fetchStoredCredentials();
  }

  Future<void> _resAuth() async {
    if (_authResolved.isCompleted) return;
    await _authResolved.future;
  }

  _onResEvent(ResEvent event) {
    switch (event.runtimeType) {
      case DisconnectedEvent:
        if (!_authResolved.isCompleted) {
          _authResolved.completeError(event);
        }
        _authResolved = Completer();
        loggingIn = false;
        authenticated = false;

        _tryReconnect();
        break;
      case ConnectedEvent:
        logger.info('need a player');
        _getPlayer();
        break;
      case ModelChangedEvent:
        if ((event as ModelChangedEvent).rid == player?.rid) {
          player = player;
        }
        break;
    }
  }

  _tryReconnect() async {
    await Future.delayed(const Duration(seconds: 2));
    var has = await _hasStoredCredentials();
    while (!loggingIn && !authenticated && has) {
      logger.debug('trying to relogin');
      await login(reconnecting: true);
      if (authenticated) return;
      await Future.delayed(const Duration(seconds: 2));
      has = await _hasStoredCredentials();
    }
  }

  _fetchStoredCredentials() async {
    final has = await _hasStoredCredentials();
    _credentialsResolved.complete(has);
  }

  Future<bool> _hasStoredCredentials() async {
    if ((await _storage.read(key: kAuthUsername) ?? '').isEmpty) return false;
    if ((await _storage.read(key: kAuthPassword) ?? '').isEmpty) return false;
    if ((await _storage.read(key: kAuthMuckletApi) ?? '').isEmpty) return false;

    return true;
  }

  @action
  Future<void> login(
      {String? username,
      String? password,
      String? api,
      bool reconnecting = false}) async {
    if (loggingIn) return;
    if (authenticated) return;

    try {
      loggingIn = true;

      username ??= await _storage.read(key: kAuthUsername) ?? '';
      password ??= await _storage.read(key: kAuthPassword) ?? '';
      api ??= await _storage.read(key: kAuthMuckletApi) ?? '';

      if (username.isEmpty || password.isEmpty || api.isEmpty) {
        authError = 'login credentials are missing';
      }

      if (_currentApi != api) {
        _currentApi = api;
      }

      try {
        // TODO: this throws on web but not on mobile. ffs?..
        _client.forceClose();
        await _client.reconnect(Uri.parse(_currentApi!));
      } catch (e) {
        logger.error('reconnect error: $e');
        authError = e.toString();
        return;
      }

      try {
        await _client.auth('auth', 'login', params: {
          'name': username,
          'hash': saltPassword(password),
        });
      } catch (e) {
        authError = e is ResError ? e.message : e.toString();
        return;
      }

      await _storage.write(key: kAuthUsername, value: username);
      await _storage.write(key: kAuthPassword, value: password);
      await _storage.write(key: kAuthMuckletApi, value: api);

      _authResolved.complete();

      authenticated = true;
      if (!reconnecting) {
        _loginStreamController.sink.add(LoginEvent.loggedIn);
      }
    } finally {
      loggingIn = false;
    }
  }

  @action
  logout() async {
    await _storage.write(key: kAuthUsername, value: '');
    await _storage.write(key: kAuthPassword, value: '');
    await _storage.write(key: kAuthMuckletApi, value: '');
    _client.forceClose();
    authenticated = false;
    _loginStreamController.sink.add(LoginEvent.loggedOut);
  }

  @observable
  String? authError;

  @observable
  bool loggingIn = false;

  @observable
  bool authenticated = false;

  String? _currentApi;

  @observable
  ResModel? player;

  @action
  _getPlayer() async {
    final newPlayer = await client.call('core', 'getPlayer');
    logger.info('got player $newPlayer');
    player = newPlayer;
  }
}
