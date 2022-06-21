// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'targeted_character_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetedCharacterEvent _$TargetedCharacterEventFromJson(
        Map<String, dynamic> json) =>
    TargetedCharacterEvent(
      char: EventChar.fromJson(json['char'] as Map<String, dynamic>),
      puppeteer: json['puppeteer'] == null
          ? null
          : EventChar.fromJson(json['puppeteer'] as Map<String, dynamic>),
      target: EventChar.fromJson(json['target'] as Map<String, dynamic>),
      id: json['id'] as String,
      type: json['type'] as String,
      time: json['time'] as int,
      sig: json['sig'] as String,
    );

Map<String, dynamic> _$TargetedCharacterEventToJson(
        TargetedCharacterEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'time': instance.time,
      'sig': instance.sig,
      'char': instance.char,
      'puppeteer': instance.puppeteer,
      'target': instance.target,
    };
