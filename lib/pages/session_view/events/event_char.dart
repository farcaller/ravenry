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

part 'event_char.g.dart';

@JsonSerializable()
class EventChar {
  final String id;
  final String name;
  final String surname;

  EventChar({required this.id, required this.name, required this.surname});

  factory EventChar.fromJson(Map<String, dynamic> json) =>
      _$EventCharFromJson(json);

  Map<String, dynamic> toJson() => _$EventCharToJson(this);

  TextSpan toTextSpan({TextStyle? style}) => TextSpan(
        style: style ?? const TextStyle(color: Color(0xff6e9ab1)),
        text: name,
      );
}
