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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glog/glog.dart';
import 'package:ravenry/pages/session_view/session_view.dart';
import 'package:ravenry/providers/player_provider.dart';
import 'package:res_client/event.dart';
import 'package:res_client/model.dart';

import '../../components/res_client_widget.dart';
import '../../theme.dart';

const logger = GlogContext('terminal_page');

const _kSelectChar = 'SELECT_CHAR';

class TerminalPage extends StatefulWidget {
  const TerminalPage({Key? key}) : super(key: key);

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends ResClientEventTrackingState<TerminalPage> {
  ResCollection? _ctrls;
  ResModel? _activeCtrl;
  final Map<String, SessionView> _sessions = {};

  ResModel? get _player => PlayerProvider.of(context).player;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _ctrls = _player?['controlled'];
    _activeCtrl = _ctrls?.items.firstWhere((_) => true, orElse: () => null);
    for (final ctrl in _ctrls?.items ?? []) {
      _sessions[ctrl['id']] = SessionView(key: Key(ctrl['id']), ctrl: ctrl);
    }

    _checkChars();
  }

  _checkChars() {
    if (_player == null) return;
    if ((_player!['controlled'] as ResCollection).items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Navigator.pushNamed(context, '/selectChar'));
    }
  }

  @override
  onResEvent(ResEvent event) {
    if (event is CollectionEvent && event.rid == _ctrls?.rid) {
      if (event is CollectionAddEvent) {
        final ctrl = event.value as ResModel;
        _sessions[ctrl['id']] = SessionView(key: Key(ctrl['id']), ctrl: ctrl);
      } else {
        final ctrl = event.value as ResModel;
        _sessions.remove(ctrl['id']);
      }
      didUpdateWidget(widget);
      setState(() {});
    } else if (event is ModelChangedEvent && event.rid == _activeCtrl?.rid) {
      didUpdateWidget(widget);
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant TerminalPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final ctrls = _ctrls;

    if (ctrls == null) {
      _activeCtrl = null;
      return;
    }

    if (_activeCtrl != null) {
      _activeCtrl = ctrls.items.firstWhere(
          (c) => (c as ResModel).rid == _activeCtrl?.rid,
          orElse: () => null);
    }

    _activeCtrl ??= ctrls.items.firstWhere((_) => true, orElse: () => null);

    if (_activeCtrl == null) {
      Navigator.pushNamed(context, '/selectChar');
      return;
    }
  }

  _switchCtrl(dynamic value) {
    if (value == _kSelectChar) {
      Navigator.pushNamed(context, '/selectChar');
    } else {
      assert(value is ResModel);
      setState(() {
        _activeCtrl = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrls == null || _activeCtrl == null) {
      return SpinKitRipple(
        color: Theme.of(context).primaryColor,
        size: 50.0,
      );
    }

    final session = _sessions[_activeCtrl!['id']]!;
    logger.debug('picked session $session for ${_activeCtrl?['name']}');

    return Scaffold(
      appBar: AppBar(
        title: Text(_activeCtrl!['name'] ?? ''),
        leading: Container(),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: _switchCtrl,
            itemBuilder: (BuildContext context) {
              final activeCtrls = _ctrls!.items.map((item) {
                final ctrl = item as ResModel;
                return PopupMenuItem(
                  value: ctrl,
                  child: Text(ctrl['name']),
                );
              }).toList();

              return [
                ...activeCtrls,
                const PopupMenuItem(
                  value: _kSelectChar,
                  child: Text('Pick Other', style: kYellowText),
                )
              ];
            },
          ),
        ],
      ),
      body: SafeArea(child: session),
    );
  }
}
