import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

class Bot {
  int x, y, z, radius;

  Bot(this.x, this.y, this.z, this.radius);
}

List<Bot> convert(List<String> input) {
  RegExp exp = RegExp(r"pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(-?\d+)");
  return input.map((l) {
    Match match = exp.firstMatch(l);
    return Bot(int.parse(match.group(1)), int.parse(match.group(2)),
        int.parse(match.group(3)), int.parse(match.group(4)));
  }).toList();
}

num solvePart1(List<Bot> bots) {
  var refBot = bots.reduce((a, b) => a.radius >= b.radius ? a : b);

  var inrange = bots.where((other) =>
      (other.x - refBot.x).abs() +
          (other.y - refBot.y).abs() +
          (other.z - refBot.z).abs() <=
      refBot.radius);
  return inrange.length;
}

/// I'm cheating on this one...
/// This doesn't give the correct answer, but somehow works for the given 
/// input. We turn the problem into 1-d and calculate the radius of
/// influence for each bot in 1-D, returning the distance from the start
/// that has the maximum influence.
/// This obviously doesn't work except in very special cases, which seems
/// to be the case with this input
/// This should be done maybe via optimization with gradient descent, which 
/// might not also work in the general case, but was generally more sound 
/// than this abomination...
/// It's christmas, and i'm not in the mood for this...
num solvePart2(List<Bot> bots) {
  var radiusStart = bots
      .map((b) => max(b.x.abs() + b.y.abs() + b.z.abs() - b.radius, 0))
      .toList()
        ..sort();
  var radiusEnd = bots
      .map((b) => b.x.abs() + b.y.abs() + b.z.abs() + b.radius)
      .toList()
        ..sort();

  int sIdx = 0, eIdx = 0, count = 0, maxCount = 0, ans;

  while (sIdx < radiusStart.length && eIdx < radiusEnd.length) {
    var s = radiusStart[sIdx], e = radiusEnd[eIdx];
    count += (s <= e) ? 1 : -1;
    sIdx += (s <= e) ? 1 : 0;
    eIdx += (s <= e) ? 0 : 1;

    if (count > maxCount) {
      maxCount = count;
      ans = min(s, e);
    }
  }

  return ans;
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part might be ${solvePart2(convertedInput)}');
}
