import 'dart:io';
import 'dart:collection';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

class Unit {
  String type;
  int x, y, hp, ap;

  Unit(this.type, this.y, this.x, this.ap) {
    hp = 200;
  }

  bool isAlive() => hp >= 0;

  bool inRange(Unit u) =>
      (u.y == y && (u.x - x).abs() == 1) || (u.x == x && (u.y - y).abs() == 1);

  bool attack(List<Unit> units, List<List<String>> maze) {
    var targets = units
        .where((u) => u.isAlive() && u.type != this.type && inRange(u))
        .toList()
          ..sort((a, b) => (a.hp == b.hp)
              ? (a.y == b.y) ? a.x - b.x : a.y - b.y
              : a.hp - b.hp);
    if (targets.isNotEmpty) {
      targets[0].hp -= this.ap;
      if (!targets[0].isAlive()) maze[targets[0].y][targets[0].x] = '.';
    }
    return targets.isNotEmpty;
  }

  // BFS search through maze
  Iterable<int> _getTargetPath(List<Unit> units, List<List<String>> maze) {
    int mazeWidth = maze[0].length;

    List<int> getReachable(List<List<String>> maze, int posY, int posX) {
      bool empty(String pos) => pos == '.';
      var succ = <int>[];
      if (empty(maze[posY - 1][posX])) succ.add((posY - 1) * mazeWidth + posX);
      if (empty(maze[posY][posX - 1])) succ.add(posY * mazeWidth + posX - 1);
      if (empty(maze[posY][posX + 1])) succ.add(posY * mazeWidth + posX + 1);
      if (empty(maze[posY + 1][posX])) succ.add((posY + 1) * mazeWidth + posX);
      return succ;
    }

    List<int> getTargets(List<Unit> units, List<List<String>> maze) {
      var targets = <int>[];
      for (var u in units.where((u) => u.isAlive() && u.type != this.type))
        targets.addAll(getReachable(maze, u.y, u.x));
      return targets;
    }

    var frontier = Queue<int>.from([y * mazeWidth + x]);
    var visited = Set<int>();
    var allPaths = Map<int, int>();
    var targets = getTargets(units, maze);
    var reachableTargets = <int>[];
    var foundDepth = -1;
    var depths = <int, int>{y * mazeWidth + x: 0};

    while (!frontier.isEmpty) {
      var elem = frontier.removeFirst();
      // If we've found a path and finished exploring this depth
      if (foundDepth != -1 && depths[elem] > foundDepth) break;

      var elemY = elem ~/ mazeWidth, elemX = elem % mazeWidth;
      if (targets.contains(elem)) {
        foundDepth = depths[elem];
        reachableTargets.add(elem);
        continue;
      }

      for (var succ in getReachable(maze, elemY, elemX)) {
        if (visited.contains(succ) || frontier.contains(succ)) continue;
        frontier.add(succ);
        allPaths[succ] = elem;
        depths[succ] = depths[elem] + 1;
      }
      visited.add(elem);
    }

    if (reachableTargets.isEmpty) return <int>[];

    reachableTargets.sort();
    var path = <int>[reachableTargets[0]];
    while (allPaths.containsKey(path.last)) path.add(allPaths[path.last]);
    return path.reversed.skip(1);
  }

  bool move(List<Unit> units, List<List<String>> maze) {
    var path = _getTargetPath(units, maze);
    int mazeWidth = maze[0].length;

    if (path.isNotEmpty) {
      var newY = path.first ~/ mazeWidth, newX = path.first % mazeWidth;
      maze[this.y][this.x] = '.';
      maze[newY][newX] = this.type;
      this.y = newY;
      this.x = newX;
      return true;
    }
    return false;
  }
}

List<Unit> getUnits(List<List<String>> maze, int elfAP, int gobAP) {
  var units = List<Unit>();
  for (int i = 0; i < maze.length; i++) {
    for (int j = 0; j < maze.length; j++) {
      if (maze[i][j] == 'G')
        units.add(Unit(maze[i][j], i, j, gobAP));
      else if (maze[i][j] == 'E') units.add(Unit(maze[i][j], i, j, elfAP));
    }
  }
  return units;
}

void printMaze(List<List<String>> maze, List<Unit> units) {
  for (int y = 0; y < maze.length; y++) {
    stdout.write(maze[y].join(''));
    stdout.write('     ');
    units
        .where((u) => u.y == y)
        .forEach((u) => stdout.write(u.hp.toString() + ' '));
    print('');
  }
}

class Score {
  int rounds;
  List<Unit> surviving;
  Score(this.rounds, this.surviving);
}

Score simulate(List<List<String>> maze, List<Unit> units) {
  int rounds = 0;
  bool finished = false;
  while (!finished) {
    rounds++;
    units
      ..removeWhere((u) => !u.isAlive())
      ..sort((a, b) => (a.y == b.y) ? a.x - b.x : a.y - b.y);

    for (var u in units) {
      if (!u.isAlive()) continue;

      if (!units.any((other) => other.isAlive() && other.type != u.type)) {
        finished = true;
        break;
      }

      if (u.attack(units, maze)) continue;
      if (u.move(units, maze)) u.attack(units, maze);
    }

    // print('Ending round $rounds');
    // printMaze(maze, units);
  }
  return Score(rounds - 1, units);
}

num solvePart1(List<String> input) {
  var maze = input.map((l) => l.split('')).toList();
  List<Unit> units = getUnits(maze, 3, 3);
  var score = simulate(maze, units);

  var totalPoints = units.fold(0, (p, e) => (e.hp >= 0) ? p + e.hp : p);
  print('Finished, rounds / points: ${score.rounds} / $totalPoints');
  return score.rounds * totalPoints;
}

num solvePart2(List<String> input) {
  var elfAP = 3;
  while (true) {
    // print('Trying elf power $elfPower');
    var maze = input.map((l) => l.split('')).toList();
    List<Unit> units = getUnits(maze, elfAP, 3);
    var initialElfs = units.fold(0, (p, u) => u.type == 'E' ? p + 1 : p);

    var score = simulate(maze, units);

    var remainingElfs =
        units.fold(0, (p, u) => u.type == 'E' && u.isAlive() ? p + 1 : p);
    if (initialElfs == remainingElfs) {
      var totalPoints = units.fold(0, (p, e) => (e.hp >= 0) ? p + e.hp : p);
      print('Finished, rounds / points: ${score.rounds} / $totalPoints.'
          ' Elf attack: $elfAP');
      return score.rounds * totalPoints;
    }
    elfAP++;
  }
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);

  print('First part is ${solvePart1(input)}');
  print('Second part is ${solvePart2(input)}');
}
