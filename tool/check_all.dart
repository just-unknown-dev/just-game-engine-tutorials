// Runs `flutter pub get`, `flutter analyze` and `flutter test` in every project in this repo.
//
//   dart tool/check_all.dart                  every step, in every project
//   dart tool/check_all.dart test             only the tests
//   dart tool/check_all.dart analyze 04 13    these steps, in these episodes
//
// A step's output is printed only when it fails, and the project's later steps are skipped.
// Exits with 1 if any step failed.
import 'dart:io';

const steps = {
  'get': ['pub', 'get'],
  'analyze': ['analyze'],
  'test': ['test'],
};
final episodeArg = RegExp(r'^\d\d$');

Future<void> main(List<String> args) async {
  final unknown = args.where((a) => !steps.containsKey(a) && !episodeArg.hasMatch(a));
  if (unknown.isNotEmpty) {
    stderr.writeln('Unknown: ${unknown.join(' ')}. Steps: ${steps.keys.join(', ')}. '
        'Episodes are two digits, such as 04.');
    exit(2);
  }
  final chosen = args.where(steps.containsKey).toList();
  if (chosen.isEmpty) chosen.addAll(steps.keys);
  final episodes = args.where(episodeArg.hasMatch).toSet();

  final root = File.fromUri(Platform.script).parent.parent;
  final projects = <Directory>[];
  for (final episode in _dirs(root).where((d) => RegExp(r'^\d\d_').hasMatch(_name(d)))) {
    if (episodes.isNotEmpty && !episodes.contains(_name(episode).substring(0, 2))) continue;
    projects.addAll(_dirs(episode).where((d) => File('${d.path}/pubspec.yaml').existsSync()));
  }
  if (projects.isEmpty) {
    stderr.writeln('No projects found.');
    exit(2);
  }

  final failed = <String>[];
  for (final project in projects) {
    final label = '${_name(project.parent)}/${_name(project)}';
    for (final step in chosen) {
      final watch = Stopwatch()..start();
      final result = await Process.run('flutter', steps[step]!,
          workingDirectory: project.path, runInShell: true);
      final took = '${(watch.elapsedMilliseconds / 1000).round()} s';
      if (result.exitCode == 0) {
        stdout.writeln('ok    $label: $step ($took)');
        continue;
      }
      failed.add('$label: $step');
      stdout
        ..writeln('FAIL  $label: $step ($took)')
        ..writeln(result.stdout)
        ..writeln(result.stderr);
      break;
    }
  }

  stdout.writeln(failed.isEmpty
      ? '\nEvery step passed in ${projects.length} projects.'
      : '\n${failed.length} failed:\n  ${failed.join('\n  ')}');
  exitCode = failed.isEmpty ? 0 : 1;
}

List<Directory> _dirs(Directory parent) =>
    parent.listSync().whereType<Directory>().toList()..sort((a, b) => _name(a).compareTo(_name(b)));

String _name(FileSystemEntity e) => e.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
