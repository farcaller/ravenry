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

import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:glog/glog.dart';
import 'package:ravenry/pages/terminal_page/terminal_page.dart';
import 'package:ravenry/providers/client_provider.dart';
import 'package:ravenry/pages/login_page/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'pages/characters_page/characters_page.dart';
import 'providers/player_provider.dart';
import 'theme.dart';

const logger = GlogContext('main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb || !Platform.isWindows) {
    logger.info('enabling firebase');
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClientState(
        child: PlayerState(
      child: MaterialApp(
        title: 'Ravenry',
        theme: theme,
        initialRoute: '/login',
        routes: {
          '/': (context) => Container(),
          '/terminal': (context) => const TerminalPage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                  fullscreenDialog: true);
            case '/selectChar':
              return MaterialPageRoute(
                  builder: (context) => const CharactersPage(),
                  fullscreenDialog: true);
            default:
              throw UnimplementedError('unknown route ${settings.name}');
          }
        },
      ),
    ));
  }
}
