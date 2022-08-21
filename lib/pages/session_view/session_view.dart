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

import 'package:flutter/material.dart';
import 'package:glog/glog.dart';
import 'package:ravenry/components/res_client_widget.dart';
import 'package:ravenry/pages/session_view/session_log.dart';
import 'package:res_client/model.dart';

import '../../theme.dart';
import 'input_view.dart';

const logger = GlogContext('session_view');

class SessionView extends ResClientWidget {
  final ResModel ctrl;

  const SessionView({Key? key, required this.ctrl}) : super(key: key);

  @override
  State<SessionView> createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  final GlobalKey<InputViewState> _inputViewKey = GlobalKey<InputViewState>();

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: kBlue1,
      child: Column(
        children: [
          Expanded(
              child: InputProvider(
                  setCommand: (cmd) {
                    if (_inputViewKey.currentState != null) {
                      _inputViewKey.currentState!.setCommand(cmd);
                    } else {
                      logger.warning(
                          'no state for _inputViewKey, dropping $cmd: ${_inputViewKey.currentState == null}');
                    }
                  },
                  child: SessionLog(ctrl: ctrl))),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: InputView(key: _inputViewKey, ctrl: ctrl),
          ),
        ],
      ),
    );
  }
}

typedef SetCommandCallback = void Function(String cmd);

class InputProvider extends InheritedWidget {
  final SetCommandCallback setCommand;

  const InputProvider(
      {super.key, required super.child, required this.setCommand});

  @override
  bool updateShouldNotify(covariant InputProvider oldWidget) {
    return setCommand != oldWidget.setCommand;
  }

  static InputProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InputProvider>()!;
  }
}
