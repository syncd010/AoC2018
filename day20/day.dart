import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

enum Dir { North, South, East, West }

class Room {
  List<Room> doors;
  int visitStatus;
  int x, y;

  static final dirMap = {
    'N': Dir.North.index,
    'S': Dir.South.index,
    'E': Dir.East.index,
    'W': Dir.West.index
  };

  static final oppositeDirMap = {
    Dir.North.index: Dir.South.index,
    Dir.South.index: Dir.North.index,
    Dir.East.index: Dir.West.index,
    Dir.West.index: Dir.East.index
  };

  static final dirMoveMap = {
    Dir.North.index: [-1, 0],
    Dir.South.index: [1, 0],
    Dir.East.index: [0, -1],
    Dir.West.index: [0, 1]
  };

  Room(this.y, this.x) {
    visitStatus = 0;
    doors = List<Room>.generate(Dir.values.length, (_) => null);
  }

  @override
  bool operator ==(Object other) =>
      other is Room && other.x == x && other.y == y;

  @override
  int get hashCode => y * 1000000 + x;
}

Room createMaze(String regex) {
  var start = Room(0, 0);
  var current = Set.of([start]);

  var branchOrigin = <Set<Room>>[], branchDestin = <Set<Room>>[];
  branchOrigin.add(current);

  for (var i = 0; i < regex.length; i++) {
    var newCurrent = Set<Room>();
    switch (regex[i]) {
      case 'N':
      case 'S':
      case 'E':
      case 'W':
        for (var room in current) {
          var dirIdx = Room.dirMap[regex[i]],
              oppositeIdx = Room.oppositeDirMap[dirIdx],
              moves = Room.dirMoveMap[dirIdx];
          if (room.doors[dirIdx] == null) {
            room.doors[dirIdx] = Room(room.y + moves[0], room.x + moves[1]);
            room.doors[dirIdx].doors[oppositeIdx] = room;
          }
          newCurrent.add(room.doors[dirIdx]);
        }
        current = newCurrent;
        break;
      case '(':
        branchOrigin.add(current);
        branchDestin.add(Set<Room>());
        break;
      case ')':
        branchOrigin.removeLast();
        branchDestin.last.addAll(current);
        current = branchDestin.removeLast();
        break;
      case '|':
        branchDestin.last.addAll(current);
        current = branchOrigin.last;
        break;
    }
  }

  return start;
}

num solvePart1(Room maze) {
  return 0;
}

num solvePart2(List<String> input) {
  return 0;
}

void printMaze(Room room, int visitStatus) {
  if (room == null || room.visitStatus == visitStatus) return;
  room.visitStatus = visitStatus;
  print('Room at ${room.y}, ${room.x} \t Doors: '
      '${room.doors[0] != null ? "N" : " "}'
      '${room.doors[1] != null ? "S" : " "}'
      '${room.doors[2] != null ? "E" : " "}'
      '${room.doors[3] != null ? "W" : " "}');
  for (var dir in Dir.values) printMaze(room.doors[dir.index], visitStatus);
}

int countFarthest(Room room, int visitStatus) {
  if (room == null || room.visitStatus == visitStatus) return 0;

  room.visitStatus = visitStatus;

  int doorCount = 0;
  for (var dir in Dir.values)
    doorCount =
        max(doorCount, countFarthest(room.doors[dir.index], visitStatus));
  return 1 + doorCount;
}

int countThousandDoors(Room room, int doorsPassed, int visitStatus) {
  if (room == null || room.visitStatus == visitStatus) return 0;

  room.visitStatus = visitStatus;

  var count = (doorsPassed >= 1000) ? 1 : 0;
  for (var dir in Dir.values)
    count +=
        countThousandDoors(room.doors[dir.index], doorsPassed + 1, visitStatus);

  return count;
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);
  var maze = createMaze(input[0].substring(1, input[0].length - 1));
  // printMaze(maze, 10);
  var doorCount = countFarthest(maze, 1);
  var roomCount = countThousandDoors(maze, 0, 2);

  print('First part is ${doorCount - 1}');
  print('Second part is ${roomCount}');
}
