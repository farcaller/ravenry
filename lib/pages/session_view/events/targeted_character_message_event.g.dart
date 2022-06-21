// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'targeted_character_message_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetedCharacterMessageEvent _$TargetedCharacterMessageEventFromJson(
        Map<String, dynamic> json) =>
    TargetedCharacterMessageEvent(
      msg: json['msg'] as String,
      char: EventChar.fromJson(json['char'] as Map<String, dynamic>),
      puppeteer: json['puppeteer'] == null
          ? null
          : EventChar.fromJson(json['puppeteer'] as Map<String, dynamic>),
      target: EventChar.fromJson(json['target'] as Map<String, dynamic>),
      pose: json['pose'] as bool?,
      ooc: json['ooc'] as bool?,
      id: json['id'] as String,
      type: json['type'] as String,
      time: json['time'] as int,
      sig: json['sig'] as String,
    );

Map<String, dynamic> _$TargetedCharacterMessageEventToJson(
        TargetedCharacterMessageEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'time': instance.time,
      'sig': instance.sig,
      'char': instance.char,
      'puppeteer': instance.puppeteer,
      'target': instance.target,
      'msg': instance.msg,
      'pose': instance.pose,
      'ooc': instance.ooc,
    };
