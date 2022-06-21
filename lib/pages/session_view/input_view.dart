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
import 'package:ravenry/components/res_client_widget.dart';
import 'package:res_client/model.dart';

import '../../theme.dart';

class InputView extends ResClientWidget {
  final ResModel ctrl;

  const InputView({Key? key, required this.ctrl}) : super(key: key);

  @override
  State<InputView> createState() => InputViewState();
}

class InputViewState extends ResClientState<InputView> {
  final TextEditingController _textController = TextEditingController();

  String _inputMode = 'say';

  _toggleInputMode() {
    setState(() {
      switch (_inputMode) {
        case 'say':
          _inputMode = 'pose';
          break;
        case 'pose':
          _inputMode = 'ooc';
          break;
        case 'ooc':
          _inputMode = 'cmd';
          break;
        case 'cmd':
          _inputMode = 'say';
          break;
      }
    });
  }

  _send() {
    final text = _textController.text;
    if (text.isEmpty) return;

    _textController.text = '';
    switch (_inputMode) {
      case 'say':
        client.call(widget.ctrl.rid, 'say', params: {
          'msg': text,
        });
        break;
      case 'pose':
        client.call(widget.ctrl.rid, 'pose', params: {
          'msg': text,
        });
        break;
      case 'ooc':
        client.call(widget.ctrl.rid, 'ooc', params: {
          'msg': text,
        });
        break;
    }
  }

  void setCommand(String cmd) {
    if (_textController.text.isNotEmpty) return;

    setState(() {
      _inputMode = 'cmd';
      _textController.text = cmd;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.only(right: 4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1.0, color: kBlue4),
              backgroundColor: kBlue3,
              minimumSize: Size.zero,
              padding: const EdgeInsets.all(7.5),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _toggleInputMode,
            child: Text(_inputMode, style: kYellowText),
          ),
        ),
        Expanded(
          child: TextField(
            style: kPlainText,
            minLines: 1,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
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
              contentPadding: EdgeInsets.zero,
              isDense: true,
              fillColor: kBlue2,
              filled: true,
              suffix: Padding(
                padding:
                    const EdgeInsets.only(top: 2, left: 4, right: 4, bottom: 6),
                child: IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 8,
                    minHeight: 8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
