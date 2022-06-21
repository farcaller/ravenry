// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoEvent _$InfoEventFromJson(Map<String, dynamic> json) => InfoEvent(
      msg: json['msg'] as String,
      id: json['id'] as String,
      type: json['type'] as String,
      time: json['time'] as int,
      sig: json['sig'] as String,
    );

Map<String, dynamic> _$InfoEventToJson(InfoEvent instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'time': instance.time,
      'sig': instance.sig,
      'msg': instance.msg,
    };
