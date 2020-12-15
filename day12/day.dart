import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

class Rule {
  String pattern, change;
  Rule(this.pattern, this.change);
}

List<Rule> parseRule(List<String> input) {
  return input.map((l) => Rule(l.substring(0, 5), l.substring(9, 10))).toList();
}

num evolve(String initialState, List<Rule> rules, int generations) {
  var res = initialState.split('').toList();
  var potNumber = 0;
  String state, newState;

  for (int gen = 0; gen < generations; gen++) {
    potNumber += (res.indexOf('#') - 4);
    res = res.sublist(res.indexOf('#'), res.lastIndexOf('#') + 1)
      ..insertAll(0, ['.', '.', '.', '.'])
      ..addAll(['.', '.', '.', '.']);

    newState = res.join('');
    if (state == newState) {
      // Stable state, bail out
      potNumber += generations - gen;
      break;
    }
    state = newState;
    for (int pot = 0; pot < res.length - 5; pot++) {
      for (var rule in rules) {
        if (rule.pattern == state.substring(pot, pot + 5)) {
          res[pot + 2] = rule.change;
          continue;
        }
      }
    }
  }

  var sum = 0;
  for (int i = 0; i < res.length; i++) {
    if (res[i] == '#') sum += i + potNumber;
  }
  return sum;
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);

  var initialState = input[0].substring(15);
  var rules = parseRule(input.sublist(1));

  print('First part is ${evolve(initialState, rules, 20)}\n');
  print('Second part is ${evolve(initialState, rules, 50000000000)}\n');
}
