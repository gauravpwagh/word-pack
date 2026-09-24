import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'import_service.dart';

/// A file chosen for import.
class PickedFile {
  const PickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Opens the system file picker. Swapped for a fake in tests (I-1).
abstract interface class ImportFilePicker {
  /// The chosen file, or null if the user cancelled. Throws
  /// [ImportException] (too large) before reading an oversized file.
  Future<PickedFile?> pick();
}

class SystemImportFilePicker implements ImportFilePicker {
  const SystemImportFilePicker();

  @override
  Future<PickedFile?> pick() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
    );
    if (file == null) return null;
    final length = await file.length();
    if (length != null) ImportService.checkSize(length);
    return PickedFile(name: file.name, bytes: await file.readAsBytes());
  }
}
