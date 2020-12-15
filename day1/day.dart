import 'dart:io';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

bool validate(List<String> input) {
  return true;
}

List<int> convert(List<String> input) {
  return input.map(int.parse).toList();
}

num solvePart1(List<int> input) {
  return input.reduce((a, b) => a + b);
}

num solvePart2(List<int> input) {
  int res = 0;
  Map seen = {res: true};

  while (true) {
    for (int num in input) {
      res += num;
      if (seen[res] != null) return res;
      seen[res] = true;
    }
  }
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
