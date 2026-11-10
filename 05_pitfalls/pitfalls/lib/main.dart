// The five things that trip people up, one demo each:
//
//     flutter run -t lib/steps.dart         1. the world updates in fixed steps
//     flutter run -t lib/axes.dart          2. +Y is down
//     flutter run -t lib/turret.dart        3. TransformComponent is the world transform
//     flutter run -t lib/priority.dart      4. systems run by priority, highest first
//     flutter run -t lib/one_of_each.dart   5. one component of each type per entity
//
// A plain `flutter run` starts the first.
import 'steps.dart' as steps;

Future<void> main() => steps.main();
