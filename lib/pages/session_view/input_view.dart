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
import 'package:provider/provider.dart';
import 'package:ravenry/commands/runner.dart';
import 'package:ravenry/components/res_client_widget.dart';
import 'package:res_client/model.dart';

import '../../stores/store.dart';
import '../../theme.dart';

class InputView extends ResClientWidget {
  final ResModel ctrl;

  const InputView({Key? key, required this.ctrl}) : super(key: key);

  @override
  State<InputView> createState() => InputViewState();
}

class InputViewState extends ResClientState<InputView> {
  final TextEditingController _textController = TextEditingController();

  _send(String text) async {
    if (text.isEmpty) return;

    final store = context.read<RootStore>();
    final runner = CommandRunner(client, widget.ctrl, store);
    if (await runner.run(text.trim())) {
      _textController.text = '';
    }
  }

  void setCommand(String cmd) {
    if (_textController.text.isNotEmpty) return;

    setState(() {
      _textController.text = cmd;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: _send,
      onEditingComplete: () {}, // to keep the focus
      style: kPlainText,
      minLines: 1,
      maxLines: 5,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      controller: _textController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        contentPadding: const EdgeInsets.all(4),
        isDense: true,
        fillColor: kBlue2,
        filled: true,
      ),
    );
  }
}
