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
import 'package:json_annotation/json_annotation.dart';
import '../session_view.dart';
import 'base_event.dart';
import 'event_char.dart';

part 'targeted_character_event.g.dart';

@JsonSerializable()
class TargetedCharacterEvent extends BaseEvent {
  final EventChar char;
  final EventChar? puppeteer;
  final EventChar target;

  TargetedCharacterEvent({
    required this.char,
    this.puppeteer,
    required this.target,
    required super.id,
    required super.type,
    required super.time,
    required super.sig,
  });

  factory TargetedCharacterEvent.fromJson(Map<String, dynamic> json) =>
      _$TargetedCharacterEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TargetedCharacterEventToJson(this);

  String _label() {
    const text = {
      'summon': 'Summon',
      'join': 'Join',
      'leadRequest': 'Lead request',
      'followRequest': 'Follow request',
      'follow': 'Follow',
      'stopFollow': 'Stop follow',
      'stopLead': 'Stop lead',
    };
    assert(text.containsKey(type));
    return text[type]!;
  }

  String _action() {
    const text = {
      'summon': ' tries to summon ',
      'join': ' wants to join ',
      'leadRequest': ' wants to lead ',
      'followRequest': ' wants to follow ',
      'follow': ' starts to follow ',
      'stopFollow': ' stops following ',
      'stopLead': ' stops leading ',
    };
    assert(text.containsKey(type));
    return text[type]!;
  }

  String _prompt(String? charId) {
    final text = {
      'summon': '. To accept the summons, type:',
      'join': '. To summon, type:',
      'leadRequest': '. To follow, type:',
      'followRequest': '. To take the lead, type:',
      'follow': char.id == charId
          ? '. To stop following, type:'
          : '. To stop leading, type:',
    };
    assert(text.containsKey(type));
    return text[type]!;
  }

  String _command(String? charId) {
    final text = {
      'summon': 'join ${char.name} ${char.surname}',
      'join': 'summon ${char.name} ${char.surname}',
      'leadRequest': 'follow ${char.name} ${char.surname}',
      'followRequest': 'lead ${char.name} ${char.surname}',
      'follow': char.id == charId ? 'stop follow' : 'stop lead',
    };
    assert(text.containsKey(type));
    return text[type]!;
  }

  List<InlineSpan> _content(BuildContext context, String? charId) {
    return [
      char.toTextSpan(),
      TextSpan(text: _action()),
      target.toTextSpan(),
      charId == char.id && type != 'follow' ||
              (type == 'stopFollow' || type == 'stopLead')
          ? const TextSpan(text: '.')
          : TextSpan(children: [
              TextSpan(text: _prompt(charId)),
              const TextSpan(text: '\n'),
              WidgetSpan(
                  child: Container(
                      padding: const EdgeInsets.only(top: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xff0f1119),
                          side: const BorderSide(
                              width: 1, color: Color(0xffc1a657)),
                        ),
                        onPressed: () {
                          InputProvider.of(context)
                              .setCommand(_command(charId));
                        },
                        child: Text(
                          _command(charId),
                          style: const TextStyle(color: Color(0xffc1a657)),
                        ),
                      )))
            ])
    ];
  }

  String textContent() {
    return '';
  }

  @override
  Widget toWidget({String? charId}) {
    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xff696d77),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              shape: BoxShape.rectangle,
            ),
            child: Builder(builder: (context) {
              List<InlineSpan> spans = [];
              spans.addAll(_content(context, charId));
              return Text.rich(TextSpan(
                  style: const TextStyle(
                      color: Color(0xff93969f), fontStyle: FontStyle.italic),
                  children: spans));
            }),
          ),
          Positioned(
              top: -7,
              left: 16,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  color: const Color(0xff161926),
                  child: Text(
                    _label(),
                    textScaleFactor: 0.9,
                    style: const TextStyle(color: Color(0xff93969f)),
                  )))
        ]));
  }
}
