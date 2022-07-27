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
import 'package:provider/provider.dart';
import 'package:ravenry/components/res_widget.dart';
import 'package:res_client/client.dart';
import 'package:res_client/model.dart';

import '../../stores/store.dart';

class CharacterView extends StatefulWidget {
  final ResModel player;
  final ResModel char;

  const CharacterView({Key? key, required this.player, required this.char})
      : super(key: key);

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView> {
  _selectChar() async {
    final client = context.read<RootStore>().client;

    final charId = widget.char['id'] as String;

    var ctrl = (widget.player['controlled'] as ResCollection)
        .items
        .firstWhere((c) => c['id'] == charId, orElse: () => null) as ResModel?;

    ctrl ??= await client
        .call(widget.player.rid, 'controlChar', params: {'charId': charId});

    if (ctrl == null) {
      throw 'failed to get ctrl';
    }
    if (ctrl['state'] != 'awake') {
      await client.call(ctrl.rid, 'wakeup');
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ResWidget(
        model: widget.char,
        builder: (context, data, _) {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
            child: InkWell(
              onTap: _selectChar,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161926),
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (data['image'] != null)
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 8, 0, 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: ResWidget(
                              model: data['image'],
                              builder: (context, imgData, _) => Image.network(
                                    imgData['href'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 8, 0, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['name']} ${data['surname']}',
                              style: const TextStyle(
                                color: Color(0xFFC1A657),
                              ),
                            ),
                            Text(
                              '${data['gender']} ${data['species']}',
                              style: const TextStyle(
                                color: Color(0xFFFFFCF2),
                              ),
                            ),
                            ResWidget(
                                model: data['inRoom'],
                                builder: (context, roomData, _) => Text(
                                      roomData['name'],
                                      style: const TextStyle(
                                        color: Color(0xFF93969F),
                                      ),
                                    )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
