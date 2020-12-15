import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

List<List<int>> genCave(
    int depth, int targetY, int targetX, int maxY, int maxX) {
  var cave = List.generate(maxY + 1, (_) => List.generate(maxX + 1, (_) => 0));

  for (var y = 0; y <= maxY; y++) {
    for (var x = 0; x <= maxX; x++) {
      if ((y == 0 && x == 0) || (y == targetY && x == targetX)) {
        cave[y][x] = 0;
      } else if (y == 0) {
        cave[y][x] = x * 16807;
      } else if (x == 0) {
        cave[y][x] = y * 48271;
      } else {
        cave[y][x] = cave[y - 1][x] * cave[y][x - 1];
      }
      cave[y][x] = (cave[y][x] + depth) % 20183;
    }
  }
  for (var y = 0; y <= maxY; y++) {
    for (var x = 0; x <= maxX; x++) {
      cave[y][x] = cave[y][x] % 3;
    }
  }
  return cave;
}

num solvePart1(int depth, int targetY, int targetX) {
  var cave = genCave(depth, targetY, targetX, targetY, targetX);

  var riskLevel = 0;
  for (var y = 0; y <= targetY; y++) {
    for (var x = 0; x <= targetX; x++) {
      riskLevel += cave[y][x];
    }
  }

  return riskLevel;
}

class Node {
  int x, y, equiped, cost;

  Node(this.y, this.x, this.equiped, this.cost);

  @override
  bool operator ==(Object other) =>
      other is Node && other.x == x && other.y == y && other.equiped == equiped;

  @override
  int get hashCode => y * 1000000 * 3 + x * 3 + equiped;

  List<Node> getNeighboors(List<List<int>> cave) {
    bool compatible(int region, int equipment) =>
        (region == 0 && (equipment == 0 || equipment == 1)) ||
        (region == 1 && (equipment == 1 || equipment == 2)) ||
        (region == 2 && (equipment == 0 || equipment == 2));

    var neighboors = <Node>[];

    Node switchNode = Node(y, x, equiped, cost + 7);
    switch (cave[y][x]) {
      case 0: // Rocky
        switchNode.equiped = (equiped == 0) ? 1 : 0; // Climb : Torch
        break;
      case 1: // Wet
        switchNode.equiped = (equiped == 1) ? 2 : 1; // Neither : Climb
        break;
      case 2: // Narrow
        switchNode.equiped = (equiped == 0) ? 2 : 0; // Neither : Torch
        break;
    }
    neighboors.add(switchNode);

    if (y > 0 && compatible(cave[y - 1][x], equiped))
      neighboors.add(Node(y - 1, x, equiped, cost + 1));
    if (compatible(cave[y][x + 1], equiped))
      neighboors.add(Node(y, x + 1, equiped, cost + 1));
    if (compatible(cave[y + 1][x], equiped))
      neighboors.add(Node(y + 1, x, equiped, cost + 1));
    if (x > 0 && compatible(cave[y][x - 1], equiped))
      neighboors.add(Node(y, x - 1, equiped, cost + 1));

    return neighboors;
  }
}

num solvePart2(int depth, int targetY, int targetX) {
  int getNextIdx(List<Node> nodes, int targetY, int targetX) {
    // A* function to guide search
    var minIdx = 0;
    for (var i = 1; i < nodes.length; i++)
      if (nodes[i].cost +
              (targetX - nodes[i].x).abs() +
              (targetY - nodes[i].y).abs() <
          nodes[minIdx].cost +
              (targetX - nodes[minIdx].x).abs() +
              (targetY - nodes[minIdx].y).abs()) minIdx = i;
    return minIdx;
  }

  var maxY = targetY, maxX = targetX;
  var cave = genCave(depth, targetY, targetX, maxY, maxX);

  var visited = <Node>[], frontier = <Node>[Node(0, 0, 0, 0)];

  // Kind of A* search, extremely inneficient
  while (frontier.length > 0) {
    var nextIdx = getNextIdx(frontier, targetY, targetX),
        current = frontier.removeAt(nextIdx);
    print('Cost: ${current.cost} at (${current.y}, ${current.x}) \t'
        'Equiped: ${current.equiped}');
    if (current.y == targetY && current.x == targetX && current.equiped == 0) {
      return current.cost;
    }

    if (current.y == maxY - 1 || current.x == maxX - 1) {
      // Near the border, expand
      maxX *= 2;
      maxY *= 2;
      cave = genCave(depth, targetY, targetX, maxY, maxX);
    }

    for (var neighboor in current.getNeighboors(cave)) {
      var idx = visited.indexOf(neighboor);
      if (idx != -1) {
        // If we've visited this neighborr with a lower cost, ignore it
        if (visited.elementAt(idx).cost < neighboor.cost)
          continue;
        else
          // If we've found a way to him with lower cost, remove it
          visited.removeAt(idx);
      }

      idx = frontier.indexOf(neighboor);
      if (idx != -1) {
        frontier.elementAt(idx).cost =
            min(neighboor.cost, frontier.elementAt(idx).cost);
      } else {
        frontier.add(neighboor);
      }
    }
    visited.add(current);
  }

  return -1;
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);
  int depth = int.parse(input[0].substring(7));
  var coords = input[1].substring(8).split(',');
  int x = int.parse(coords[0]), y = int.parse(coords[1]);

  print('First part is ${solvePart1(depth, y, x)}');
  print('Second part is ${solvePart2(depth, y, x)}');
}
