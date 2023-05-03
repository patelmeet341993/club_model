import 'package:flutter/material.dart';

mixin MySafeState<T extends StatefulWidget> on State<T> {
  bool _pageMounted = false, _disposed = false;

  bool get pageMounted => _pageMounted;

  /// Call this method in the build of State
  @protected
  void pageBuild() {
    _pageMounted = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _pageMounted = true;
    });
  }

  /// Call this method in the build of State
  @protected
  void pageDispose() {
    _disposed = true;
    _pageMounted = false;
  }

  @override
  void dispose() {
    pageDispose();
    super.dispose();
  }

  /// Call this method to safely update the state
  @protected
  void mySetState() {
    try {
      if(_disposed || !mounted) {
        return;
      }
    }
    catch(e) {
      return;
    }

    if(_pageMounted) {
      setState(() {});
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    }
  }
}