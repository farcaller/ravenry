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
import 'base_event.dart';
import 'event_char.dart';
import 'format_text.dart';
import 'unsized_widget_span.dart';

part 'targeted_character_message_event.g.dart';

@JsonSerializable()
class TargetedCharacterMessageEvent extends BaseEvent {
  final EventChar char;
  final EventChar? puppeteer;
  final EventChar target;
  final String msg;
  final bool? pose;
  final bool? ooc;

  TargetedCharacterMessageEvent({
    required this.msg,
    required this.char,
    this.puppeteer,
    required this.target,
    this.pose,
    this.ooc,
    required super.id,
    required super.type,
    required super.time,
    required super.sig,
  });

  factory TargetedCharacterMessageEvent.fromJson(Map<String, dynamic> json) =>
      _$TargetedCharacterMessageEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TargetedCharacterMessageEventToJson(this);

  String _label(String? charId) {
    switch (type) {
      case 'whisper':
        if (char.id == charId) {
          return ooc == true
              ? 'Whisper ooc to ${target.name}'
              : 'Whisper to ${target.name}';
        } else {
          return ooc == true ? 'Whisper ooc' : 'Whisper';
        }
      case 'message':
        if (char.id == charId) {
          return ooc == true
              ? 'Message ooc to ${target.name}'
              : 'Message to ${target.name}';
        } else {
          return ooc == true ? 'Message ooc' : 'Message';
        }
      case 'warn':
        return char.id == charId ? 'Message to ${target.name}' : 'Message';
      case 'mail':
        if (char.id == charId) {
          return ooc == true
              ? 'Mail sent ooc to ${target.name}'
              : 'Mail sent to ${target.name}';
        } else {
          return ooc == true
              ? 'Mail received ooc from ${char.name}'
              : 'Mail received from ${char.name}';
        }
    }
    throw UnimplementedError();
  }

  List<InlineSpan> _content() {
    final charSpan = char.toTextSpan(
        style: _warning ? const TextStyle(color: Color(0xff7d818c)) : null);

    switch (type) {
      case 'whisper':
        if (pose == true) {
          return [
            charSpan,
            if (msg.isNotEmpty && msg[0] != "'" && msg[0] != ',')
              const TextSpan(text: ' '),
            formatText(msg),
          ];
        } else {
          return [
            charSpan,
            const TextSpan(text: ' whispers, "'),
            formatText(msg),
            const TextSpan(text: '"'),
          ];
        }
      case 'message':
        if (pose == true) {
          return [
            charSpan,
            if (msg.isNotEmpty && msg[0] != "'" && msg[0] != ',')
              const TextSpan(text: ' '),
            formatText(msg),
          ];
        } else {
          return [
            charSpan,
            const TextSpan(text: ' writes, "'),
            formatText(msg),
            const TextSpan(text: '"'),
          ];
        }
      case 'warn':
        if (pose == true) {
          return [
            charSpan,
            if (msg.isNotEmpty && msg[0] != "'" && msg[0] != ',')
              const TextSpan(text: ' '),
            formatText(msg),
          ];
        } else {
          return [
            charSpan,
            const TextSpan(text: ' warns, "'),
            formatText(msg),
            const TextSpan(text: '"'),
          ];
        }
      case 'mail':
        if (pose == true) {
          return [
            charSpan,
            if (msg.isNotEmpty && msg[0] != "'" && msg[0] != ',')
              const TextSpan(text: ' '),
            formatText(msg),
          ];
        } else {
          return [
            formatText(msg),
          ];
        }
    }
    return [];
  }

  String textContent() {
    return '$msg';
  }

  bool get _warning => type == 'warn';

  Widget _framedWidget({String? charId}) {
    List<InlineSpan> spans = [];
    spans.addAll(_content());
    final text = Text.rich(TextSpan(
        style: TextStyle(
            color: _warning
                ? const Color(0xff9a593e)
                : (ooc == true
                    ? const Color(0xff696d77)
                    : const Color(0xffbec0c5))),
        children: spans));

    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: _warning
                    ? const Color(0xff9a593e)
                    : const Color(0xff696d77),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              shape: BoxShape.rectangle,
            ),
            child: text,
          ),
          Positioned(
              top: -7,
              left: 16,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  color: const Color(0xff161926),
                  child: Text(
                    _label(charId),
                    textScaleFactor: 0.9,
                    style: TextStyle(
                        color: _warning
                            ? const Color(0xff9a593e)
                            : const Color(0xff93969f)),
                  )))
        ]));
  }

  Widget _addressWidget() {
    List<InlineSpan> spans = [
      char.toTextSpan(),
      ooc == true
          ? unsizedSpan('ooc to ${target.name}')
          : unsizedSpan('to ${target.name}'),
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
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text.rich(TextSpan(
          style: TextStyle(
              color: ooc == true
                  ? const Color(0xff696d77)
                  : const Color(0xffbec0c5)),
          children: spans)),
    );
  }

  @override
  Widget toWidget({String? charId}) {
    switch (type) {
      case 'whisper':
      case 'message':
      case 'warn':
      case 'mail':
        return _framedWidget(charId: charId);
      case 'address':
        return _addressWidget();
      case 'controlRequest':
        // TODO: find acci
        return Container();
      default:
        throw UnimplementedError();
    }
  }
}
