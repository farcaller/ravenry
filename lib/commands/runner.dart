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

import 'package:glog/glog.dart';
import 'package:res_client/client.dart';
import 'package:res_client/model.dart';

import '../stores/store.dart';
import 'communication.dart';
import 'transport.dart';

const logger = GlogContext('runner');

class CommandRunner {
  final ResClient client;
  final ResModel ctrl;
  final RootStore store;

  CommandRunner(this.client, this.ctrl, this.store);

  Future<bool> run(String input) async {
    for (final command in commands) {
      final match = command.regex.firstMatch(input);
      if (match != null) {
        var ret = command.action(match, this);
        if (ret is Future) {
          ret = await ret;
        }
        if (ret == false) {
          return false;
        }
        return true;
      }
    }
    return false;
  }
}

class Command {
  final RegExp regex;
  final dynamic Function(RegExpMatch match, CommandRunner runner) action;

  const Command(this.regex, this.action);
}

final commands = [...communicationCommands, ...transportCommands];
