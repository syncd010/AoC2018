import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

bool validate(List<String> input) {
  return true;
}

class Point {
  int x, y, vx, vy;

  Point(this.x, this.y, this.vx, this.vy);

  void tick() {
    this.x += this.vx;
    this.y += this.vy;
  }

  void tock() {
    this.x -= this.vx;
    this.y -= this.vy;
  }
}

List<Point> convert(List<String> input) {
  RegExp exp = RegExp(
      r"position=<\s*(-?\d+),\s*(-?\d+)>\s*velocity=<\s*(-?\d+),\s*(-?\d+)>");
  return input.map((l) {
    Match match = exp.firstMatch(l);
    return Point(int.parse(match.group(1)), int.parse(match.group(2)),
        int.parse(match.group(3)), int.parse(match.group(4)));
  }).toList();
}

void display(List<Point> points) {
  List<int> limits = skyLimits(points);
  int minY = limits[0], maxY = limits[1], minX = limits[2], maxX = limits[3];

  var sky = List.generate(
      maxY - minY + 1, (_) => List.generate(maxX - minX + 1, (_) => ' '));

  for (var p in points) {
    sky[p.y - minY][p.x - minX] = '#';
  }

  for (int y = 0; y < sky.length; y++) {
    for (int x = 0; x < sky[y].length; x++) {
      stdout.write(sky[y][x]);
    }
    print('');
  }
}

List<int> skyLimits(List<Point> points) {
  int minY = 1000, maxY = -1000, minX = 1000, maxX = -1000;

  for (var p in points) {
    minY = min(minY, p.y);
    maxY = max(maxY, p.y);
    minX = min(minX, p.x);
    maxX = max(maxX, p.x);
  }

  return [minY, maxY, minX, maxX];
}

void solve(List<Point> points) {
  points.sort(
      (p1, p2) => (p1.y == p2.y) ? p1.x.compareTo(p2.x) : p1.y.compareTo(p2.y));

  List<int> prevLimits = skyLimits(points);
  int seconds = 0;
  while (true) {
    points.forEach((p) => p.tick());

    var limits = skyLimits(points);
    if ((limits[1] - limits[0] > prevLimits[1] - prevLimits[0]) &&
        (limits[3] - limits[2] > prevLimits[3] - prevLimits[2])) {
      points.forEach((p) => p.tock());
      display(points);
      print('Reached after $seconds iterations');
      break;
    }
    prevLimits = limits;
    seconds++;
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

  solve(convert(input));
}
