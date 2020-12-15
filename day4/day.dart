import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

bool validate(List<String> input) {
  return true;
}

class Shift {
  String date;
  List<int> sleepTimes = List<int>(), wakeTimes = List<int>();
  List<int> _sleepMinutes;

  Shift() {}

  List<int> get sleepMinutes {
    if (_sleepMinutes == null) {
      _sleepMinutes = List<int>.generate(60, (_) => 0);
      for (var i = 0; i < sleepTimes.length; i++) {
        for (var m = sleepTimes[i]; m < wakeTimes[i]; m++) {
          _sleepMinutes[m] = 1;
        }
      }
    }

    return _sleepMinutes;
  }

  int totalSleepTime() {
    return sleepMinutes.reduce((a, b) => a + b);
  }
}

class Guard {
  String guardId;
  List<Shift> shifts = List<Shift>();

  Guard(this.guardId);

  int totalSleepTime() {
    return shifts.fold(0, (prev, e) => prev + e.totalSleepTime());
  }

  List<int> _sleepMinutes;
  List<int> get sleepMinutes {
    if (_sleepMinutes == null) {
      _sleepMinutes = shifts.fold(List<int>.generate(60, (_) => 0), (prev, e) {
        for (int i = 0; i < prev.length; i++) {
          prev[i] += e.sleepMinutes[i];
        }
        return prev;
      });
    }
    return _sleepMinutes;
  }
}

Map<String, Guard> convert(List<String> input) {
  RegExp exp = RegExp(r"\[(\d+-\d+-\d+ \d+:\d+)].*");
  input.sort((a, b) {
    var aDate = exp.firstMatch(a).group(1);
    var bDate = exp.firstMatch(b).group(1);

    return aDate.compareTo(bDate);
  });

  var guards = Map<String, Guard>();

  var guardExp = RegExp(r"\[.*] Guard #(\d+)"),
      sleepsExp = RegExp(r"\[(\S+) \d+:(\d+)] falls"),
      wakesExp = RegExp(r"\[(\S+) \d+:(\d+)] wakes");

  Shift currShift;
  String currGuardId;
  for (var line in input) {
    var guardMatch = guardExp.firstMatch(line);
    if (guardMatch != null) {
      if (currShift != null) guards[currGuardId].shifts.add(currShift);
      currGuardId = guardMatch.group(1);
      guards[currGuardId] ??= Guard(currGuardId);
      currShift = Shift();
      continue;
    }

    var sleepsMatch = sleepsExp.firstMatch(line);
    if (sleepsMatch != null) {
      currShift.date = sleepsMatch.group(1);
      currShift.sleepTimes.add(int.parse(sleepsMatch.group(2)));
      continue;
    }

    var wakesMatch = wakesExp.firstMatch(line);
    if (wakesMatch != null) {
      currShift.wakeTimes.add(int.parse(wakesMatch.group(2)));
    }
  }

  return guards;
}

num solvePart1(Map<String, Guard> guards) {
  // Get the guard that slept the most
  var sleepyGuard = guards.values
      .reduce((a, b) => a.totalSleepTime() > b.totalSleepTime() ? a : b);

  return int.parse(sleepyGuard.guardId) *
      sleepyGuard.sleepMinutes.indexOf(sleepyGuard.sleepMinutes.reduce(max));
}

num solvePart2(Map<String, Guard> guards) {
  // Get the guard with the most slept minute
  var sleepyGuard = guards.values
      .reduce((a, b) => a.sleepMinutes.reduce(max) > b.sleepMinutes.reduce(max) ? a : b);

  return int.parse(sleepyGuard.guardId) *
      sleepyGuard.sleepMinutes.indexOf(sleepyGuard.sleepMinutes.reduce(max));
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
