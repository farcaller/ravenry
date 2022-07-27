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
import 'package:glog/glog.dart';
import 'package:ravenry/components/res_client_widget.dart';
import 'package:ravenry/pages/session_view/events/base_event.dart';
import 'package:res_client/event.dart';
import 'package:res_client/model.dart';

import '../../theme.dart';
import 'events/client_event.dart';

const logger = GlogContext('session_log');

class SessionLog extends ResClientWidget {
  final ResModel ctrl;

  const SessionLog({Key? key, required this.ctrl}) : super(key: key);

  @override
  State<SessionLog> createState() => _SessionLogState();
}

class _SessionLogState extends ResClientEventTrackingState<SessionLog> {
  bool _shouldShowToBottom = false;
  final ScrollController _controller = ScrollController();
  final List<BaseEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _getReplaybuffer();
  }

  @override
  void dispose() {
    logger.debug(
        'disposing the log for ${widget.ctrl.rid} with ${_events.length} events');
    super.dispose();
  }

  _getReplaybuffer() async {
    final ctrl = widget.ctrl;
    final lastTime = _events.isEmpty
        ? 0
        : _events.lastWhere((element) => element is! ClientEvent).time + 1;

    logger.debug(
        'getting backlog for ${ctrl.rid} from $lastTime, had ${_events.length} events so far');
    final backlog = await client.call('log', 'events.get', params: {
      'charId': ctrl['id'],
      'startTime': lastTime,
    });
    final from = DateTime.fromMillisecondsSinceEpoch(backlog['startTime']);
    final to = DateTime.fromMillisecondsSinceEpoch(backlog['endTime']);
    final events = backlog['events'] as List;
    logger.debug(
        'got replaybuffer from $from to $to, ${_events.length} current events, '
        '${events.length} new events');
    setState(() {
      _events.addAll(events.map((e) => BaseEvent.fromJson(e)));
      _scrollDown();
    });
  }

  @override
  onResEvent(ResEvent event) {
    if (!mounted) return;

    switch (event.runtimeType) {
      case ConnectedEvent:
        setState(() {
          _events.add(ClientEvent('Connected to server'));
        });
        _getReplaybuffer();
        break;
      case DisconnectedEvent:
        setState(() {
          _events.add(ClientEvent('Disconnected from server'));
        });
        break;
      case GenericEvent:
        final e = event as GenericEvent;
        if (e.rid != widget.ctrl.rid) return;
        if (e.name != 'out') return;
        setState(() {
          _events.add(BaseEvent.fromJson(e.payload));
          logger.debug(
              'now have ${_events.length} events for ${widget.ctrl['name']}');
        });
        break;
    }
    // TODO: this is still janky because the scrolling isn't preserved on adding.
    if (!_shouldShowToBottom) _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        _controller.animateTo(
          _controller.position.minScrollExtent,
          duration: const Duration(milliseconds: 20),
          curve: Curves.fastOutSlowIn,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is! ScrollUpdateNotification) return false;
          if (notification.metrics.pixels >
              notification.metrics.minScrollExtent + 200) {
            if (_shouldShowToBottom == false) {
              setState(() => _shouldShowToBottom = true);
            }
          } else {
            if (_shouldShowToBottom == true) {
              setState(() => _shouldShowToBottom = false);
            }
          }
          return false;
        },
        child:
            Stack(alignment: Alignment.center, fit: StackFit.expand, children: [
          DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 18),
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                controller: _controller,
                itemCount: _events.length,
                reverse: true,
                itemBuilder: (BuildContext context, int index) {
                  final event = _events[_events.length - index - 1];
                  return Container(
                      key: Key(event.id),
                      child: event.toWidget(charId: widget.ctrl['id']));
                }),
          ),
          AnimatedPositioned(
            bottom: _shouldShowToBottom ? 0 : -50,
            duration: const Duration(milliseconds: 200),
            child: OutlinedButton(
                onPressed: _scrollDown,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(8),
                  backgroundColor: kBlue2,
                  side: const BorderSide(width: 2, color: Color(0xffc1a657)),
                ),
                child: const Text(
                  'to bottom',
                  style: TextStyle(color: Color(0xffc1a657), fontSize: 12),
                )),
          )
        ]));
  }
}
