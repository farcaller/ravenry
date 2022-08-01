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

import 'package:glog/glog.dart';

import 'helpers.dart';
import 'runner.dart';

const logger = GlogContext('runner:communication');

final communicationCommands = [
  Command(r(r'(say\s+|")\s*(.+)(?:"?)'), (m, r) {
    var msg = m.group(2)!;
    if (m.group(1) == '"') {
      if (msg.endsWith('"')) {
        msg = msg.substring(0, msg.length - 1);
      }
    }
    r.client.call(r.ctrl.rid, 'say', params: {
      'msg': msg,
    });
  }),
  Command(r(r'(?:pose\s+|:|/me\s+)\s*(.+)'), (m, r) {
    r.client.call(r.ctrl.rid, 'pose', params: {
      'msg': m.group(1),
    });
  }),
  Command(r(r'(?:ooc\s+|>)\s*(?<pose>:?)\s*(?<msg>.+)'), (m, r) {
    r.client.call(r.ctrl.rid, 'ooc', params: {
      'msg': m.namedGroup('msg'),
      'pose': m.namedGroup('pose') == ':',
    });
  }),
  Command(
      r(r'(?:whisper|w|wh)\s+(?<target>[^=]+)\s*=\s*(?<ooc>>?)\s*(?<pose>:?)\s*(?<msg>.+)'),
      (m, r) {
    final target = m.namedGroup('target')!.toLowerCase().trim();
    final chars = r.ctrl['inRoom']['chars'].items as List;

    final targetId = _getTarget(chars, target);
    if (targetId == null) {
      return false;
    }
    r.client.call(r.ctrl.rid, 'whisper', params: {
      'charId': targetId,
      'msg': m.namedGroup('msg'),
      'ooc': m.namedGroup('ooc') == '>',
      'pose': m.namedGroup('pose') == ':',
    });
  }),
  Command(
      r(r'(?:message|m|msg|p|page)\s+(?<target>[^=]+)\s*=\s*(?<ooc>>?)\s*(?<pose>:?)\s*(?<msg>.+)'),
      (m, r) {
    final target = m.namedGroup('target')!.toLowerCase().trim();
    final chars = r.store.awakeChars;

    final targetId = _getTarget(chars, target);
    if (targetId == null) {
      return false;
    }
    r.client.call(r.ctrl.rid, 'message', params: {
      'charId': targetId,
      'msg': m.namedGroup('msg'),
      'ooc': m.namedGroup('ooc') == '>',
      'pose': m.namedGroup('pose') == ':',
    });
  }),
  Command(
      r(r'(?:address\s+|@|to\s+)\s*(?<target>[^=]+)\s*=\s*(?<ooc>>?)\s*(?<pose>:?)\s*(?<msg>.+)'),
      (m, r) {
    final target = m.namedGroup('target')!.toLowerCase().trim();
    final chars = r.ctrl['inRoom']['chars'].items as List;

    final targetId = _getTarget(chars, target);
    if (targetId == null) {
      return false;
    }
    r.client.call(r.ctrl.rid, 'address', params: {
      'charId': targetId,
      'msg': m.namedGroup('msg'),
      'ooc': m.namedGroup('ooc') == '>',
      'pose': m.namedGroup('pose') == ':',
    });
  }),
  Command(r(r'(?:describe|desc|spoof)\s+(?<msg>.+)'), (m, r) {
    r.client.call(r.ctrl.rid, 'describe', params: {
      'msg': m.namedGroup('msg'),
    });
  }),
  Command(
      r(r'(?:mail)\s+(?<target>[^=]+)\s*=\s*(?<ooc>>?)\s*(?<pose>:?)\s*(?<msg>.+)'),
      (m, r) {
    final target = m.namedGroup('target')!.toLowerCase().trim();
    final chars = r.store.awakeChars;

    final targetId = _getTarget(chars, target);
    if (targetId == null) {
      return false;
    }
    // TODO: do:
    //    call.core.player.$PID.getChar(charName: target) -> ResModel for character
    //    call.mail.player.$PID.inbox.send(fromCharId: ctrl.id, ooc: ooc, text: msg, toCharId: id)

    // r.client.call(r.ctrl.rid, 'message', params: {
    //   'charId': targetId,
    //   'msg': m.namedGroup('msg'),
    //   'ooc': m.namedGroup('ooc') == '>',
    //   'pose': m.namedGroup('pose') == ':',
    // });
  }),
];

String? _getTarget(List chars, String target) {
  final byName = chars
      .where((c) => (c['name'] as String).toLowerCase() == target)
      .toList();
  if (byName.length == 1) {
    return byName[0]['id'];
  }
  if (byName.length > 1) {
    // TODO: report to user
    logger.warning('matched more than 1 character for `$target`');
    return null;
  }
  final byFull = chars
      .where((c) => '${c['name']} ${c['surname']}'.toLowerCase() == target)
      .toList();
  if (byName.length == 1) {
    return byFull[0]['id'];
  }
  logger.warning("can't find $target");
  return null;
}
