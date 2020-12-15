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

Map<T, int> makeCounter<T>(Iterable iter) {
  var counter = Map<T, int>();

  for (var elem in iter) {
    counter[elem] = (counter[elem] ?? 0) + 1;
  }
  return counter;
}

num solvePart1(List<String> input) {
  var letterCounts = List<int>();
  for (var line in input) {
    letterCounts.addAll(Set.from(makeCounter(line.runes).values));
  }

  return makeCounter(letterCounts.where((v) => v > 1))
      .values
      .reduce((a, b) => a * b);
}

String commonChars(String a, String b) {
  var common = List<String>();
  for (var i = 0; i < min(a.length, b.length); i++) {
    if (a[i] == b[i]) {
      common.add(a[i]);
    }
  }
  return common.join();
}

String solvePart2(List<String> input) {
  for (int i = 0; i < input.length; i++) {
    for (int j = i + 1; j < input.length; j++) {
      var common = commonChars(input[i], input[j]);
      if ((input[i].length == input[j].length) &&
          (common.length == input[i].length - 1)) {
        return common;
      }
    }
  }

  return null;
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
