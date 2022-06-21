// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_room_message_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetRoomMessageEvent _$TargetRoomMessageEventFromJson(
        Map<String, dynamic> json) =>
    TargetRoomMessageEvent(
      msg: json['msg'] as String,
      char: EventChar.fromJson(json['char'] as Map<String, dynamic>),
      puppeteer: json['puppeteer'] == null
          ? null
          : EventChar.fromJson(json['puppeteer'] as Map<String, dynamic>),
      targetRoom:
          EventRoom.fromJson(json['targetRoom'] as Map<String, dynamic>),
      id: json['id'] as String,
      type: json['type'] as String,
      time: json['time'] as int,
      sig: json['sig'] as String,
    );

Map<String, dynamic> _$TargetRoomMessageEventToJson(
        TargetRoomMessageEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'time': instance.time,
      'sig': instance.sig,
      'char': instance.char,
      'puppeteer': instance.puppeteer,
      'targetRoom': instance.targetRoom,
      'msg': instance.msg,
    };
