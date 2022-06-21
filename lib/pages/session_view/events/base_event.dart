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

import 'character_poseable_message_event.dart';
import 'target_room_message_event.dart';
import 'targeted_character_event.dart';
import 'targeted_character_message_event.dart';
import 'character_message_event.dart';
import 'info_event.dart';

abstract class BaseEvent {
  final String id;
  final String type;
  final int time;
  final String sig;

  BaseEvent({
    required this.id,
    required this.type,
    required this.time,
    required this.sig,
  });

  factory BaseEvent.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'info':
        return InfoEvent.fromJson(json);
      case 'say':
      case 'pose':
      case 'wakeup':
      case 'sleep':
      case 'leave':
      case 'arrive':
      case 'describe':
      case 'action':
        return CharacterMessageEvent.fromJson(json);
      case 'ooc':
        return CharacterPoseableMessageEvent.fromJson(json);
      case 'whisper':
      case 'message':
      case 'warn':
      case 'mail':
      case 'address':
      case 'controlRequest':
        return TargetedCharacterMessageEvent.fromJson(json);
      case 'travel':
        return TargetRoomMessageEvent.fromJson(json);
      case 'summon':
      case 'join':
      case 'leadRequest':
      case 'followRequest':
      case 'follow':
      case 'stopFollow':
      case 'stopLead':
        return TargetedCharacterEvent.fromJson(json);
      default:
        throw UnimplementedError();
    }
  }

  Map<String, dynamic> toJson();

  Widget toWidget({String? charId});
}
