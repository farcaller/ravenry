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

import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ravenry/pages/session_view/events/format_text.dart';
import 'base_event.dart';
import 'event_char.dart';

part 'character_message_event.g.dart';

@JsonSerializable()
class CharacterMessageEvent extends BaseEvent {
  final EventChar char;
  final EventChar? puppeteer;
  final String msg;

  CharacterMessageEvent({
    required this.msg,
    required this.char,
    this.puppeteer,
    required super.id,
    required super.type,
    required super.time,
    required super.sig,
  });

  factory CharacterMessageEvent.fromJson(Map<String, dynamic> json) =>
      _$CharacterMessageEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CharacterMessageEventToJson(this);

  TextStyle get _baseStyle {
    switch (type) {
      case 'say':
      case 'pose':
        return const TextStyle(color: Color(0xffbec0c5));
      case 'wakeup':
      case 'sleep':
      case 'leave':
      case 'arrive':
      case 'action':
        return const TextStyle(
            color: Color(0xff93969f), fontStyle: FontStyle.italic);
      case 'describe':
        // TODO: smaller font, too (14px)
        return const TextStyle(color: Color(0xff93969f));
      default:
        throw UnimplementedError();
    }
  }

  @override
  Widget toWidget({String? charId}) {
    List<TextSpan> spans;
    switch (type) {
      case 'say':
        spans = [
          char.toTextSpan(),
          const TextSpan(text: ' says, "'),
          formatText(msg),
          const TextSpan(text: '"'),
        ];
        break;
      case 'describe':
        spans = [
          const TextSpan(text: '⌈'),
          formatText(msg),
          const TextSpan(text: '⌋'),
        ];
        break;
      default:
        spans = [
          char.toTextSpan(),
          if (msg.isNotEmpty && msg[0] != "'" && msg[0] != ',')
            const TextSpan(text: ' '),
          formatText(msg),
        ];
        break;
    }
    return Text.rich(TextSpan(style: _baseStyle, children: spans));
  }
}
