// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_poseable_message_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterPoseableMessageEvent _$CharacterPoseableMessageEventFromJson(
        Map<String, dynamic> json) =>
    CharacterPoseableMessageEvent(
      msg: json['msg'] as String,
      char: EventChar.fromJson(json['char'] as Map<String, dynamic>),
      puppeteer: json['puppeteer'] == null
          ? null
          : EventChar.fromJson(json['puppeteer'] as Map<String, dynamic>),
      pose: json['pose'] as bool?,
      id: json['id'] as String,
      type: json['type'] as String,
      time: json['time'] as int,
      sig: json['sig'] as String,
    );

Map<String, dynamic> _$CharacterPoseableMessageEventToJson(
        CharacterPoseableMessageEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'time': instance.time,
      'sig': instance.sig,
      'char': instance.char,
      'puppeteer': instance.puppeteer,
      'msg': instance.msg,
      'pose': instance.pose,
    };
