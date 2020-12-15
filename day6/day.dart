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
  int x, y;
  Point(this.x, this.y);

  int distanceTo(int x, int y) {
    return (this.x - x).abs() + (this.y - y).abs();
  }
}

List<Point> convert(List<String> input) {
  List<Point> points = List<Point>();
  for (var line in input) {
    var coords = line.split(',');
    points.add(Point(int.parse(coords[0]), int.parse(coords[1])));
  }
  return points;
}

// Returns the index of the nearest points
List<int> nearestPointsIdx(int x, int y, List<Point> points) {
  int minDistance = points.map((p) => p.distanceTo(x, y)).reduce(min);
  var indexes = List<int>();
  for (var i = 0; i < points.length; i++) {
    if (points[i].distanceTo(x, y) == minDistance) indexes.add(i);
  }
  return indexes;
}

num solvePart1(List<Point> points) {
  var maxX = points.fold(0, (int prev, e) => max(prev, e.x)),
      maxY = points.fold(0, (int prev, e) => max(prev, e.y));

  var nearestCount = List<int>.generate(points.length, (_) => 0);
  var borderPointsIdx = Set<int>();

  // Sizes of neighborhoods of each point
  for (var y = 0; y <= maxY; y++) {
    for (var x = 0; x <= maxX; x++) {
      var nearest = nearestPointsIdx(x, y, points);
      if (nearest.length > 1) continue;
      for (var idx in nearest) nearestCount[idx]++;
      if (x == 0 || y == 0 || x == maxX || y == maxY)
        borderPointsIdx.addAll(nearest);
    }
  }

  // Remove borders
  for (var idx in borderPointsIdx) nearestCount[idx] = 0;

  return nearestCount.reduce(max);
}

num solvePart2(List<Point> points) {
  var maxX = points.fold(0, (int prev, e) => max(prev, e.x)),
      maxY = points.fold(0, (int prev, e) => max(prev, e.y));

  var count = 0;
  // Sizes of neighborhoods of each point
  for (var y = 0; y <= maxY; y++) {
    for (var x = 0; x <= maxX; x++) {
      var distance =
          points.map((p) => p.distanceTo(x, y)).reduce((a, b) => a + b);
      if (distance < 10000) count++;
    }
  }

  return count;
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
