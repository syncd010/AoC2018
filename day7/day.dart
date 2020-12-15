import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

bool validate(List<String> input) {
  return true;
}

Map<String, List<String>> convert(List<String> input) {
  Map<String, List<String>> dependencies = Map<String, List<String>>();

  for (var line in input) {
    var prev = line[5], next = line[36];

    dependencies[prev] ??= List<String>();
    dependencies[next] ??= List<String>();
    dependencies[next].add(prev);
  }
  return dependencies;
}

Map<String, List<String>> cloneInput(Map<String, List<String>> input) {
  var res = Map<String, List<String>>();
  for (var key in input.keys) res[key] = List<String>.from(input[key]);
  return res;
}

String solvePart1(Map<String, List<String>> input) {
  var dependencies = cloneInput(input);

  var steps = List<String>();
  while (dependencies.keys.length > 0) {
    var currSteps = dependencies.keys
        .where((key) => dependencies[key].length == 0)
        .toList()
          ..sort((a, b) => a.compareTo(b));

    // Remove last key from map and from values
    dependencies.remove(currSteps[0]);
    dependencies.forEach((_, v) => v.remove(currSteps[0]));
    steps.add(currSteps[0]);
  }
  return steps.join('');
}

class Worker {
  String step;
  int time;
  Worker(this.step, this.time);
}

num solvePart2(Map<String, List<String>> input) {
  var dependencies = cloneInput(input);
  // for (var key in dependencies.keys) {
  //   print('$key - ${dependencies[key]}');
  // }
  const maxWorkers = 5, stepTime = 60;

  var steps = List<String>();
  var workers = List<Worker>();
  var base = 'A'.codeUnitAt(0);
  var totalTime = 0;

  while (dependencies.keys.length > 0) {
    var currSteps = dependencies.keys
        .where((key) => dependencies[key].length == 0)
        .toList()
          ..sort((a, b) => a.compareTo(b));

    var iter = min(currSteps.length, maxWorkers - workers.length);
    for (var i = 0; i < iter; i++) {
      var step = currSteps[i];
      workers.add(Worker(step, stepTime + 1 + (step.codeUnitAt(0) - base)));
      dependencies.remove(step);
    }

    // Remove ready steps
    var minTime = workers.fold(200, (int p, e) => min(p, e.time));
    totalTime += minTime;
    workers.forEach((w) => w.time -= minTime);

    for (var w in workers.where((w) => w.time == 0)) {
      dependencies.forEach((_, v) => v.remove(w.step));
      steps.add(w.step);
    }
    workers.removeWhere((w) => w.time == 0);
  }

  // print(steps.join(''));
  return totalTime;
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);
  if (!validate(input)) {
    exit(2);
  }

  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}\n');
  print('Second part is ${solvePart2(convertedInput)}\n');
}
