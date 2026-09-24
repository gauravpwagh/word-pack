import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // Uncaught errors are logged on the device only; there is no telemetry
  // (docs/ARCHITECTURE.md §6).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      details.exceptionAsString(),
      name: 'wordpack',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log('$error', name: 'wordpack', error: error, stackTrace: stack);
    return true;
  };
  runApp(const ProviderScope(child: WordPackApp()));
}
