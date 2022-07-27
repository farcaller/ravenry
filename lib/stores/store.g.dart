// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RootStore on _RootStore, Store {
  late final _$authErrorAtom =
      Atom(name: '_RootStore.authError', context: context);

  @override
  String? get authError {
    _$authErrorAtom.reportRead();
    return super.authError;
  }

  @override
  set authError(String? value) {
    _$authErrorAtom.reportWrite(value, super.authError, () {
      super.authError = value;
    });
  }

  late final _$loggingInAtom =
      Atom(name: '_RootStore.loggingIn', context: context);

  @override
  bool get loggingIn {
    _$loggingInAtom.reportRead();
    return super.loggingIn;
  }

  @override
  set loggingIn(bool value) {
    _$loggingInAtom.reportWrite(value, super.loggingIn, () {
      super.loggingIn = value;
    });
  }

  late final _$authenticatedAtom =
      Atom(name: '_RootStore.authenticated', context: context);

  @override
  bool get authenticated {
    _$authenticatedAtom.reportRead();
    return super.authenticated;
  }

  @override
  set authenticated(bool value) {
    _$authenticatedAtom.reportWrite(value, super.authenticated, () {
      super.authenticated = value;
    });
  }

  late final _$playerAtom = Atom(name: '_RootStore.player', context: context);

  @override
  ResModel? get player {
    _$playerAtom.reportRead();
    return super.player;
  }

  @override
  set player(ResModel? value) {
    _$playerAtom.reportWrite(value, super.player, () {
      super.player = value;
    });
  }

  late final _$loginAsyncAction =
      AsyncAction('_RootStore.login', context: context);

  @override
  Future<void> login(
      {String? username,
      String? password,
      String? api,
      bool reconnecting = false}) {
    return _$loginAsyncAction.run(() => super.login(
        username: username,
        password: password,
        api: api,
        reconnecting: reconnecting));
  }

  late final _$logoutAsyncAction =
      AsyncAction('_RootStore.logout', context: context);

  @override
  Future logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  late final _$_getPlayerAsyncAction =
      AsyncAction('_RootStore._getPlayer', context: context);

  @override
  Future _getPlayer() {
    return _$_getPlayerAsyncAction.run(() => super._getPlayer());
  }

  @override
  String toString() {
    return '''
authError: ${authError},
loggingIn: ${loggingIn},
authenticated: ${authenticated},
player: ${player}
    ''';
  }
}
