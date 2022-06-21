// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_message_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterMessageEvent _$CharacterMessageEventFromJson(
        Map<String, dynamic> json) =>
    CharacterMessageEvent(
      msg: json['msg'] as String,
      char: EventChar.fromJson(json['char'] as Map<String, dynamic>),
      puppeteer: json['puppeteer'] == null
          ? null
          : EventChar.fromJson(json['puppeteer'] as Map<String, dynamic>),
      id: json['id'] as String,
      type: json['type'] as String,
      time: json['time'] as int,
      sig: json['sig'] as String,
    );

Map<String, dynamic> _$CharacterMessageEventToJson(
        CharacterMessageEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'time': instance.time,
      'sig': instance.sig,
      'char': instance.char,
      'puppeteer': instance.puppeteer,
      'msg': instance.msg,
    };
