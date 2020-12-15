import 'dart:io';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

class Point {
  static int idCount = 0;
  int x, y, z, w, id;
  Point(this.x, this.y, this.z, this.w) {
    id = idCount++;
  }

  @override
  bool operator ==(Object other) => other is Point && other.id == id;

  @override
  int get hashCode => id;

  int distanceTo(Point other) {
    return (other.x - x).abs() +
        (other.y - y).abs() +
        (other.z - z).abs() +
        (other.w - w).abs();
  }

  List<Point> connectionsOn(List<Point> points) {
    var connections = <Point>[];
    for (var other in points) {
      if (other == this) continue;
      if (distanceTo(other) <= 3) connections.add(other);
    }
    return connections;
  }
}

List<Point> convert(List<String> input) {
  var points = <Point>[];
  for (var line in input) {
    var coords = line.split(",").map(int.parse).toList();
    points.add(Point(coords[0], coords[1], coords[2], coords[3]));
  }
  return points;
}

num solvePart1(List<Point> points) {
  var allGraphs = <Set<Point>>[];
  var nodes = Set<Point>.of(points);

  while (nodes.isNotEmpty) {
    var frontier = <Point>[nodes.first];
    var graph = Set<Point>.of(frontier);

    while (frontier.isNotEmpty) {
      var connections = frontier.removeLast().connectionsOn(points);
      for (var c in connections) if (!graph.contains(c)) frontier.add(c);
      graph.addAll(connections);
    }
    nodes = nodes.difference(graph);
    allGraphs.add(graph);
  }

  return allGraphs.length;
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
}
