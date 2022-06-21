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
import 'base_event.dart';
import 'event_char.dart';
import 'format_text.dart';
import 'unsized_widget_span.dart';

part 'character_poseable_message_event.g.dart';

@JsonSerializable()
class CharacterPoseableMessageEvent extends BaseEvent {
  final EventChar char;
  final EventChar? puppeteer;
  final String msg;
  final bool? pose;

  CharacterPoseableMessageEvent({
    required this.msg,
    required this.char,
    this.puppeteer,
    this.pose,
    required super.id,
    required super.type,
    required super.time,
    required super.sig,
  });

  factory CharacterPoseableMessageEvent.fromJson(Map<String, dynamic> json) =>
      _$CharacterPoseableMessageEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CharacterPoseableMessageEventToJson(this);

  @override
  Widget toWidget({String? charId}) {
    List<InlineSpan> spans = [
      char.toTextSpan(),
      unsizedSpan('ooc'),
    ];
    if (pose == true) {
      spans.addAll([
        if (msg.isNotEmpty && msg[0] != "'" && msg[0] != ',')
          const TextSpan(text: ' '),
        formatText(msg),
      ]);
    } else {
      spans.addAll([
        const TextSpan(text: ' says, "'),
        formatText(msg),
        const TextSpan(text: '"'),
      ]);
    }
    return Text.rich(TextSpan(
        style: const TextStyle(color: Color(0xff696d77)), children: spans));
  }
}
