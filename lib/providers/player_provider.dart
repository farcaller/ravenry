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
import 'package:glog/glog.dart';
import 'package:ravenry/components/res_client_widget.dart';
import 'package:res_client/client.dart';
import 'package:res_client/event.dart';
import 'package:res_client/model.dart';

const logger = GlogContext('player_provider');

typedef ClientConfiguredCallback = void Function(ResClient client);

class PlayerState extends StatefulWidget {
  final Widget child;

  const PlayerState({Key? key, required this.child}) : super(key: key);

  @override
  State<PlayerState> createState() => _PlayerStateState();
}

class _PlayerStateState extends ResClientEventTrackingState<PlayerState> {
  ResModel? _player;

  @override
  onResEvent(ResEvent event) {
    logger.debug('PP saw $event');
    switch (event.runtimeType) {
      case ClientForcedDisconnectedEvent:
        setState(() => _player = null);
        break;
      case ConnectedEvent:
        _getPlayer();
        break;
      case ModelChangedEvent:
        if ((event as ModelChangedEvent).rid == _player?.rid) {
          setState(() {});
        }
        break;
    }
  }

  _getPlayer() async {
    final player = await client.call('core', 'getPlayer');
    if (!mounted) return;
    setState(() => _player = player);
    logger.debug('resolved player: $_player');
  }

  @override
  Widget build(BuildContext context) {
    return PlayerProvider(player: _player, child: widget.child);
  }
}

class PlayerProvider extends InheritedWidget {
  final ResModel? player;

  const PlayerProvider({super.key, required super.child, required this.player});

  @override
  bool updateShouldNotify(covariant PlayerProvider oldWidget) {
    return player != oldWidget.player;
  }

  static PlayerProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlayerProvider>()!;
  }
}
