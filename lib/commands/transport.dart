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
import 'package:res_client/error.dart';

import 'helpers.dart';
import 'runner.dart';

const logger = GlogContext('runner:transport');

final transportCommands = [
  Command(r(r'(?:go)\s+(?<keyword>.+)'), (m, r) async {
    try {
      await r.client.call(r.ctrl.rid, 'useExit', params: {
        'exitKey': m.namedGroup('keyword'),
      });
    } on ResError catch (e) {
      // TODO: handle substs: {"code":"core.exitKeyNotFound","message":"There is no exit \"{key}\".","data":{"key":"bad"}}
      logger.error(e.message);
    }
  }),
  Command(r(r'(?:follow|hopon)\s+(?<target>.+)'), (m, r) {
    final target = m.namedGroup('target')!.toLowerCase().trim();
    final chars = r.ctrl['inRoom']['chars'].items as List;

    final targetId = getTarget(chars, target);
    if (targetId == null) {
      return false;
    }
    r.client.call(r.ctrl.rid, 'follow', params: {
      'charId': targetId,
    });
  }),
  Command(r(r'(?:lead|carry)\s+(?<target>.+)'), (m, r) {
    final target = m.namedGroup('target')!.toLowerCase().trim();
    final chars = r.ctrl['inRoom']['chars'].items as List;

    final targetId = getTarget(chars, target);
    if (targetId == null) {
      return false;
    }
    r.client.call(r.ctrl.rid, 'lead', params: {
      'charId': targetId,
    });
  }),
  Command(r(r'(?:stop\s+follow|hopoff)'), (m, r) {
    r.client.call(r.ctrl.rid, 'stopFollow');
  }),
  Command(r(r'(?:stop\s+lead|dropoff)'), (m, r) {
    r.client.call(r.ctrl.rid, 'stopLead');
  }),
  Command(r(r'(?:join|mjoin)\s+(?<target>.+)'), (m, r) {
    final target = m.namedGroup('target')!.toLowerCase().trim();
    final chars = r.store.awakeChars;

    final targetId = getTarget(chars, target);
    if (targetId == null) {
      return false;
    }
    r.client.call(r.ctrl.rid, 'follow', params: {
      'charId': targetId,
    });
  }),
  Command(r(r'(?:summon|msummon)\s+(?<target>.+)'), (m, r) {
    final target = m.namedGroup('target')!.toLowerCase().trim();
    final chars = r.store.awakeChars;

    final targetId = getTarget(chars, target);
    if (targetId == null) {
      return false;
    }
    r.client.call(r.ctrl.rid, 'summon', params: {
      'charId': targetId,
    });
  }),
  Command(r(r'(?:home|gohome)'), (m, r) {
    r.client.call(r.ctrl.rid, 'teleportHome');
  }),
];
