import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

bool validate(List<String> input) {
  return true;
}

List<String> convert(List<String> input) {
  return input;
}

String reducePolymer(String input) {
  var polymer = List<String>.from(input.split('')),
      polymerLCase = List<String>.from(input.toLowerCase().split(''));

  List<int> idxToRemove = List<int>();
  do {
    idxToRemove.clear();
    for (var i = 0; i < polymer.length - 1; i++) {
      if ((polymer[i] != polymer[i + 1]) &&
          (polymerLCase[i] == polymerLCase[i + 1])) {
        idxToRemove.add(i);
        i += 2;
      }
    }

    if (idxToRemove.length > 0) {
      List<String> reduced = polymer.sublist(0, idxToRemove[0]);
      List<String> reducedLCase = polymerLCase.sublist(0, idxToRemove[0]);
      idxToRemove.add(polymer.length);
      for (var i = 1; i < idxToRemove.length; i++) {
        reduced.addAll(polymer.sublist(idxToRemove[i - 1] + 2, idxToRemove[i]));
        reducedLCase.addAll(polymerLCase.sublist(idxToRemove[i - 1] + 2, idxToRemove[i]));
      }

      polymer = reduced;
      polymerLCase = reducedLCase;
    }
  } while (idxToRemove.length > 0);

  return polymer.join('');
}

num solvePart1(List<String> input) {
  return reducePolymer(input[0]).length;
}

num solvePart2(List<String> input) {
  var chars = Set<String>.from(input[0].toLowerCase().split(''));

  String minPolymer = input[0];
  int minLen = minPolymer.length;
  for (var char in chars) {
    print('Testing removing $char');
    var polymer =
        input[0].replaceAll(char, '').replaceAll(char.toUpperCase(), '');
    var newPolymer = reducePolymer(polymer);
    if (newPolymer.length < minLen) {
      minLen = newPolymer.length;
      minPolymer = polymer;
    }
  }
  return minLen;
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file');
    exit(1);
  }

  print('This will take a couple of minutes...');
  var input = readInput(arguments[0]);
  if (!validate(input)) {
    exit(2);
  }

  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}\n');
  print('Second part is ${solvePart2(convertedInput)}\n');
}
