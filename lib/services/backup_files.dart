import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Where backup files go and come from. Swapped for a fake in tests.
abstract interface class BackupFiles {
  /// Saves [content] as [fileName]; false if the user cancelled.
  Future<bool> save(String fileName, String content);

  /// The text of a chosen backup file, or null if the user cancelled.
  Future<String?> open();
}

/// Share sheet on phones (DAT-2: "system share sheet"), save dialog on
/// desktop; the file picker to restore.
class SystemBackupFiles implements BackupFiles {
  const SystemBackupFiles();

  @override
  Future<bool> save(String fileName, String content) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content, encoding: utf8);
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          fileNameOverrides: [fileName],
        ),
      );
      return result.status != ShareResultStatus.dismissed;
    }
    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (location == null) return false;
    await File(location.path).writeAsString(content, encoding: utf8);
    return true;
  }

  @override
  Future<String?> open() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    return utf8.decode(await file.readAsBytes(), allowMalformed: true);
  }
}
