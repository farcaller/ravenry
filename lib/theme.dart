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

const kBlue1 = Color(0xff161926);
const kBlue2 = Color(0xff1d2233);
const kBlue3 = Color(0xff252a40);
const kBlue4 = Color(0xff303753);

const kYellowText = TextStyle(color: Color(0xffc1a657));

const kPlainText = TextStyle(color: Color(0xffbec0c5));
const kOocText = TextStyle(color: Color(0xff696d77));
const kNameText = TextStyle(color: Color(0xff6e9ab1));
const kContextText = TextStyle(color: Color(0xff93969f));
const kEventText =
    TextStyle(color: Color(0xff93969f), fontStyle: FontStyle.italic);

final theme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xff1d2233),
    onPrimary: Color(0xffbec0c5),
    background: Color(0xff161926),
    onBackground: Colors.grey,
    surface: Color(0xff1d2233),
    onSurface: Color(0xffbec0c5),
    error: Colors.red,
    onError: Colors.red,
    secondary: Color(0xff1d2233),
    onSecondary: Colors.red,
  ),
  backgroundColor: const Color(0xff161926),
);
