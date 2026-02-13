import 'package:flutter/material.dart';

import '../../features/search/controller/search_store.dart';

class StoreProvider extends InheritedWidget {
  const StoreProvider({
    super.key,
    required this.searchStore,
    required super.child,
  });

  final SearchStore searchStore;

  static SearchStore search(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<StoreProvider>();
    assert(provider != null, 'StoreProvider not found');
    return provider!.searchStore;
  }

  @override
  bool updateShouldNotify(StoreProvider oldWidget) =>
      searchStore != oldWidget.searchStore;
}
