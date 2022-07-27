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

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:ravenry/components/res_collection_widget.dart';
import 'package:ravenry/theme.dart';
import 'package:res_client/model.dart';

import '../../stores/store.dart';
import 'character_view.dart';

class CharactersPage extends StatelessWidget {
  const CharactersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = context.read<RootStore>();

    return Observer(builder: (_) {
      final player = store.player;
      if (player == null) {
        return Container();
      }
      return _buildContents(store, player);
    });
  }

  Widget _buildContents(RootStore store, ResModel player) {
    final chars = player['chars'];
    final ctrls = player['controlled'] as ResCollection;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Character'),
          leading: ctrls.items.isEmpty ? Container() : null,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ResCollectionWidget(
              collection: chars,
              builder: (context, collection) => ListView.builder(
                  itemCount: collection.items.length + 1,
                  itemBuilder: ((context, index) {
                    return index == collection.items.length
                        ? Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8, 24, 8, 4),
                            child: InkWell(
                              onTap: () => store.logout(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF161926),
                                  borderRadius: BorderRadius.circular(10),
                                  shape: BoxShape.rectangle,
                                ),
                                child:
                                    const Text('Log Out', style: kYellowText),
                              ),
                            ),
                          )
                        : CharacterView(
                            key: Key((collection.items[index] as ResModel).rid),
                            player: player,
                            char: collection.items[index]);
                  }))),
        ));
  }
}
