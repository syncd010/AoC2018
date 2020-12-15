import 'dart:io';

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
  int x, y, regionType, equiped, cost;

  Node(this.y, this.x, this.regionType, this.equiped, this.cost);

  @override
  bool operator ==(Object other) =>
      other is Node && other.x == x && other.y == y && other.equiped == equiped;

  @override
  int get hashCode => y * 1000000 * 3 + x * 3 + equiped;
}

List<List<List<Node>>> genNodeCave(List<List<int>> cave,
    {List<List<List<Node>>> copyFrom = null}) {
  var nodeCave = List.generate(
      cave.length,
      (y) => List.generate(
          cave[y].length,
          (x) => List.generate(3, (equiped) {
                return Node(y, x, cave[y][x], equiped, -1);
              })));

  if (copyFrom != null) {
    for (var y = 0; y < copyFrom.length; y++) {
      for (var x = 0; x < copyFrom[y].length; x++) {
        for (var z = 0; z < copyFrom[y][x].length; z++) {
          nodeCave[y][x][z].cost = copyFrom[y][x][z].cost;
        }
      }
    }
  }
  return nodeCave;
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

  var cave = genCave(depth, targetY, targetX, targetY, targetX);
  var nodeCave = genNodeCave(cave);

  nodeCave[0][0][0].cost = 0;
  var frontier = <Node>[nodeCave[0][0][0]];

  // Kind of A* search
  while (frontier.length > 0) {
    var nextIdx = getNextIdx(frontier, targetY, targetX),
        current = frontier.removeAt(nextIdx);
    // print('Cost: ${current.cost} at (${current.y}, ${current.x}) \t'
    // 'Equiped: ${current.equiped}');
    if (current.y == targetY && current.x == targetX && current.equiped == 0) {
      return current.cost;
    }

    if (current.y == nodeCave.length - 1 ||
        current.x == nodeCave[0].length - 1) {
      // Near the border, expand
      cave =
          genCave(depth, targetY, targetX, cave.length * 2, cave[0].length * 2);
      nodeCave = genNodeCave(cave, copyFrom: nodeCave);
    }

    bool compatible(int region, int equipment) =>
        (region == 0 && (equipment == 0 || equipment == 1)) ||
        (region == 1 && (equipment == 1 || equipment == 2)) ||
        (region == 2 && (equipment == 0 || equipment == 2));

    void addIfCompatibleAndCheaper(
        List<Node> frontier, Node other, int pathCost) {
      if (compatible(other.regionType, other.equiped) &&
          (other.cost == -1 || other.cost > pathCost)) {
        other.cost = pathCost;
        if (frontier.indexOf(other) == -1) {
          frontier.add(other);
        }
      }
    }

    if (current.y > 0)
      addIfCompatibleAndCheaper(
          frontier,
          nodeCave[current.y - 1][current.x][current.equiped],
          current.cost + 1);
    addIfCompatibleAndCheaper(frontier,
        nodeCave[current.y][current.x + 1][current.equiped], current.cost + 1);
    addIfCompatibleAndCheaper(frontier,
        nodeCave[current.y + 1][current.x][current.equiped], current.cost + 1);
    if (current.x > 0)
      addIfCompatibleAndCheaper(
          frontier,
          nodeCave[current.y][current.x - 1][current.equiped],
          current.cost + 1);

    int switchEquip;
    if (cave[current.y][current.x] == 0) // Rock
      switchEquip = (current.equiped == 0) ? 1 : 0; // Climb : Torch
    else if (cave[current.y][current.x] == 1) // Wet
      switchEquip = (current.equiped == 1) ? 2 : 1; // Neither : Climb
    else // Narrow
      switchEquip = (current.equiped == 0) ? 2 : 0; // Neither : Torch
    addIfCompatibleAndCheaper(frontier,
        nodeCave[current.y][current.x][switchEquip], current.cost + 7);
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
