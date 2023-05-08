import 'package:flutter/material.dart';

import 'my_safe_state.dart';

abstract class MyState<T extends StatefulWidget> extends State<T> with MySafeState {
  late ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    super.pageBuild();

    return const SizedBox();
  }
}