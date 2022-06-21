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
import 'dart:convert';

import 'package:glog/glog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../providers/client_provider.dart';

const logger = GlogContext('login_page');

typedef LoginCallback = void Function();

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  String? _muckletName;
  String? _muckletApi;

  Timer? _domainDebounce;

  final TextEditingController _domainController =
      TextEditingController(text: '');
  final TextEditingController _usernameController =
      TextEditingController(text: '');
  final TextEditingController _passwordController =
      TextEditingController(text: '');

  bool _resolvingMucklet = false;
  String? _resolvingMuckletError;
  bool _loggingIn = false;
  String _version = '';

  bool _resolvingSavedAuth = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _domainController.dispose();
    _domainDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _domainController.addListener(() {
      final String domain = _domainController.text.toLowerCase();
      _onLookupMucklets(domain);
    });

    _finalizeInit();
  }

  _finalizeInit() async {
    _domainController.text = await _storage.read(key: kAuthDomain) ?? '';
    _usernameController.text = await _storage.read(key: kAuthUsername) ?? '';
    _passwordController.text = await _storage.read(key: kAuthPassword) ?? '';
    final muckletName = await _storage.read(key: kAuthMuckletName);
    final muckletApi = await _storage.read(key: kAuthMuckletApi);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = '${packageInfo.version} (${packageInfo.buildNumber})';

    if (!mounted) return;
    setState(() {
      _muckletName = muckletName;
      _muckletApi = muckletApi;
    });
  }

  _onLookupMucklets(String domain) {
    if (_domainDebounce?.isActive ?? false) _domainDebounce?.cancel();
    _domainDebounce = Timer(const Duration(seconds: 1), () async {
      if (!mounted) return;
      setState(() {
        _muckletName = null;
        _muckletApi = null;
        _resolvingMucklet = true;
        _resolvingMuckletError = null;
      });

      try {
        final response = await http.get(Uri.parse(
            'https://$domain/.well-known/mucklet-configuration.json'));
        if (response.statusCode != 200) {
          throw 'status code ${response.statusCode}';
        }
        final config = jsonDecode(response.body);
        final name = config['mucklets'][0]['name'];
        final api = config['mucklets'][0]['api'];
        if (!mounted) return;
        setState(() {
          _muckletName = name;
          _muckletApi = api;
        });
      } catch (e) {
        setState(() => _resolvingMuckletError = e.toString());
        logger.error('failed fetching mucklet-configuration from $domain: $e');
      } finally {
        setState(() => _resolvingMucklet = false);
      }
    });
  }

  _onLogin() async {
    if (_loggingIn) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      await _storage.write(key: kAuthUsername, value: _usernameController.text);
      await _storage.write(key: kAuthPassword, value: _passwordController.text);
      await _storage.write(key: kAuthMuckletApi, value: _muckletApi);
    }
    try {
      if (!mounted) return;
      setState(() => _loggingIn = true);

      final ok = await ClientProvider.of(context).tryLogin(
          login: _usernameController.text,
          password: _passwordController.text,
          api: _muckletApi);
      if (!ok) return;

      _usernameController.text = '';
      _passwordController.text = '';
    } finally {
      setState(() => _loggingIn = false);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/terminal');
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();

    logger.debug('_resolvingSavedAuth = $_resolvingSavedAuth');

    if (_resolvingSavedAuth) {
      final clientProvider = ClientProvider.of(context);
      final hasStored = await clientProvider.hasStoredCredentials();

      logger.debug('hasStored = $hasStored');

      if (hasStored) {
        final ok = await clientProvider.tryLogin();
        if (ok && mounted) {
          Navigator.of(context).pushReplacementNamed('/terminal');
        }
      }

      if (!mounted) return;
      setState(() {
        _resolvingSavedAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvingSavedAuth || _loggingIn) {
      return SpinKitRipple(
        color: Theme.of(context).primaryColor,
        size: 50.0,
      );
    }

    return Scaffold(
        appBar: AppBar(
          title:
              Text(_muckletName != null ? 'Login to $_muckletName' : 'Login'),
          leading: Container(),
        ),
        body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: TextFormField(
                      enabled: !_loggingIn,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Server',
                          errorText: _resolvingMuckletError,
                          suffix: _resolvingMucklet
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator())
                              : null),
                      controller: _domainController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Required field';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.url,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: TextFormField(
                      enabled: !_loggingIn,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Username'),
                      controller: _usernameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Required field';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: TextFormField(
                      enabled: !_loggingIn,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Password',
                          errorText: ClientProvider.of(context).authError),
                      controller: _passwordController,
                      enableSuggestions: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: _muckletApi != null ? _onLogin : null,
                        child: const Text(
                          'Login',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text('build version: $_version'),
                  ),
                  if (_loggingIn)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: SpinKitRipple(
                        color: Theme.of(context).primaryColor,
                        size: 50.0,
                      ),
                    ),
                ]),
              )),
        ));
  }
}
