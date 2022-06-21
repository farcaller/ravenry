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
import 'dart:ui';

class _UnsizedWidgetSpan extends WidgetSpan {
  const _UnsizedWidgetSpan({required super.child});

  @override
  void build(ParagraphBuilder builder,
      {double textScaleFactor = 1.0, List<PlaceholderDimensions>? dimensions}) {
    assert(debugAssertIsValid());
    assert(dimensions != null);
    final bool hasStyle = style != null;
    if (hasStyle) {
      builder.pushStyle(style!.getTextStyle(textScaleFactor: textScaleFactor));
    }
    assert(builder.placeholderCount < dimensions!.length);
    final PlaceholderDimensions currentDimensions =
        dimensions![builder.placeholderCount];
    builder.addPlaceholder(
      0,
      currentDimensions.size.height,
      alignment,
      scale: textScaleFactor,
      baseline: currentDimensions.baseline,
      baselineOffset: currentDimensions.baselineOffset,
    );
    if (hasStyle) {
      builder.pop();
    }
  }
}

WidgetSpan unsizedSpan(String text) {
  return _UnsizedWidgetSpan(
    child: Transform.translate(
      offset: const Offset(-5, -11),
      child: Text(
        text,
        textScaleFactor: 0.7,
        style: const TextStyle(color: Color(0xff93969f)),
      ),
    ),
  );
}
