// Configuration for which flutter version to use.
// Run this script to create `_flutter_version.sh'

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart' as path;

// ignore_for_file: avoid_print

// const FLUTTER_VERSION = '1.22.0-1.0.pre';
// const FLUTTER_VERSION = '1.23.0-18.0.pre';
// const FLUTTER_VERSION = '2.1.0-12.1.pre';
const FLUTTER_VERSION = '2.6.0-0.0.pre';
const FLUTTER_URL =
    'https://storage.googleapis.com/flutter_infra_release/releases/';
const OUTPUT_FILE = '_flutter_version.sh';

Future<void> main() async {
  final dir = File(Platform.script.toFilePath()).parent;
  final targetPath = path.join(dir.path, OUTPUT_FILE);
  print('Updating $targetPath..');
  final platforms = ['windows', 'linux', 'macos'];
  final output = <String, String?>{
    'FLUTTER_URL': FLUTTER_URL,
  };
  for (final platform in platforms) {
    // final url = 'https://storage.googleapis.com/flutter_infra/'
    //     'releases/releases_$platform.json';
    final url = 'https://storage.googleapis.com/flutter_infra_release/'
        'releases/releases_$platform.json';
    final response = await get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw StateError(
          'Unsuccessful fetching release json. ${response.statusCode} - ${response.body}');
    }
    final releases = parseReleases(response.body);
    final release = releases.firstWhere(
        (release) => release.version == FLUTTER_VERSION,
        orElse: (() => throw StateError(
            'No such version found $FLUTTER_VERSION at $url')));
    output['FLUTTER_${platform.toUpperCase()}_VERSION'] = FLUTTER_VERSION;
    output['FLUTTER_${platform.toUpperCase()}_ARCHIVE'] = release.archive;
    output['FLUTTER_${platform.toUpperCase()}_SHA256'] = release.sha256;
  }
  await File(targetPath).writeAsString('''
# Autogenerated at ${DateTime.now().toIso8601String()}
# Run ${path.basename(Platform.script.toFilePath())} to update.

${output.entries.map((e) => '${e.key}=\'${e.value}\'').join('\n')}
''');
}

Iterable<Release> parseReleases(String body) {
  final platformConfig = json.decode(body) as Map<String, dynamic>;

  return (platformConfig['releases'] as List).map(
      (dynamic release) => Release.fromJson(release as Map<String, dynamic>));
}

class Release {
  Release({
    this.hash,
    this.channel,
    this.version,
    this.archive,
    this.sha256,
  });

  factory Release.fromJson(Map<String, dynamic> map) => Release(
        hash: map['hash'] as String?,
        channel: map['channel'] as String?,
        version: map['version'] as String?,
        archive: map['archive'] as String?,
        sha256: map['sha256'] as String?,
      );

  final String? hash;
  final String? channel;
  final String? version;
  final String? archive;
  final String? sha256;
}
