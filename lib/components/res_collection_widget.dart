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
import 'package:ravenry/providers/client_provider.dart';
import 'package:res_client/event.dart';
import 'package:res_client/model.dart';

typedef ResCollectionWidgetBuilder = Widget Function(
    BuildContext context, ResCollection collection);

class ResCollectionWidget extends StatefulWidget {
  final ResCollection collection;
  final ResCollectionWidgetBuilder builder;

  const ResCollectionWidget(
      {Key? key, required this.collection, required this.builder})
      : super(key: key);

  @override
  State<ResCollectionWidget> createState() => _ResCollectionWidgetState();
}

class _ResCollectionWidgetState extends State<ResCollectionWidget> {
  StreamSubscription? _clientEvents;

  @override
  void dispose() {
    if (_clientEvents != null) {
      _clientEvents!.cancel();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ResCollectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_clientEvents != null) {
      _clientEvents!.cancel();
    }

    _clientEvents = ClientProvider.of(context)
        .client
        .events
        .where((event) => event is CollectionEvent)
        .listen((event) {
      final evt = event as CollectionEvent;
      if (evt.rid != widget.collection.rid) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.collection);
  }
}
