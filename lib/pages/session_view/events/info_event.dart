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

part 'info_event.g.dart';

@JsonSerializable()
class InfoEvent extends BaseEvent {
  final String msg;

  InfoEvent({
    required this.msg,
    required super.id,
    required super.type,
    required super.time,
    required super.sig,
  });

  factory InfoEvent.fromJson(Map<String, dynamic> json) =>
      _$InfoEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$InfoEventToJson(this);

  TextStyle get _eventStyle =>
      const TextStyle(color: Color(0xff696d77), fontStyle: FontStyle.italic);

  @override
  Widget toWidget({String? charId}) => Text.rich(TextSpan(
        style: _eventStyle,
        text: msg,
      ));
}
