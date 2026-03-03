import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/local_call_log.dart';
import '../services/local_call_log_store.dart';

final localCallLogStoreProvider = Provider<LocalCallLogStore>((ref) {
  final store = LocalCallLogStore();
  return store;
});

final localCallLogsProvider = StreamProvider<List<LocalCallLog>>((ref) async* {
  final store = ref.read(localCallLogStoreProvider);
  await store.init();

  yield store.all();

  final controller = StreamController<List<LocalCallLog>>();
  final ValueListenable<dynamic> listenable = store.listenable();
  void listener() {
    controller.add(store.all());
  }

  listenable.addListener(listener);

  ref.onDispose(() {
    controller.close();
    listenable.removeListener(listener);
  });

  yield* controller.stream;
});
