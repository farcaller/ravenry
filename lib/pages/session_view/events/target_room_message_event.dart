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
import 'package:ravenry/pages/session_view/events/format_text.dart';
import 'event_room.dart';
import 'base_event.dart';
import 'event_char.dart';

part 'target_room_message_event.g.dart';

@JsonSerializable()
class TargetRoomMessageEvent extends BaseEvent {
  final EventChar char;
  final EventChar? puppeteer;
  final EventRoom targetRoom;
  final String msg;

  TargetRoomMessageEvent({
    required this.msg,
    required this.char,
    this.puppeteer,
    required this.targetRoom,
    required super.id,
    required super.type,
    required super.time,
    required super.sig,
  });

  factory TargetRoomMessageEvent.fromJson(Map<String, dynamic> json) =>
      _$TargetRoomMessageEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TargetRoomMessageEventToJson(this);

  TextStyle get _eventStyle =>
      const TextStyle(color: Color(0xff93969f), fontStyle: FontStyle.italic);

  @override
  Widget toWidget({String? charId}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(
            style: _eventStyle,
            children: [
              char.toTextSpan(),
              const TextSpan(text: ' '),
              formatText(msg),
            ],
          )),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                        color: Color(0xffc1a657), fontStyle: FontStyle.italic),
                    text: targetRoom.name,
                  ),
                  textScaleFactor: 1.1)),
        ],
      );
}
