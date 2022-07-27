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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:res_client/client.dart';
import 'package:res_client/event.dart';
import 'package:res_client/model.dart';

import '../stores/store.dart';

typedef ResWidgetBuilder = Widget Function(
    BuildContext context, Map<String, dynamic> modelData, String rid);

class ResWidget extends StatefulWidget {
  final ResModel model;
  final ResWidgetBuilder builder;

  const ResWidget({Key? key, required this.model, required this.builder})
      : super(key: key);

  @override
  State<ResWidget> createState() => _ResWidgetState();
}

class _ResWidgetState extends State<ResWidget> {
  StreamSubscription? _clientEvents;

  ResClient get _client => context.watch<RootStore>().client;

  @override
  void dispose() {
    if (_clientEvents != null) {
      _clientEvents!.cancel();
    }
    super.dispose();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();

    if (_clientEvents != null) {
      _clientEvents!.cancel();
    }

    _clientEvents = _client.events
        .where((event) => event is ModelChangedEvent)
        .listen((event) {
      final evt = event as ModelChangedEvent;
      if (evt.rid != widget.model.rid) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.model.toJson(), widget.model.rid);
  }
}
