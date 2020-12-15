import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

const String empty = '.', wall = '#', water = '|', flood = '~';

List<List<String>> convert(List<String> input) {
  RegExp exp = RegExp(r"(x|y)=(\d+), (x|y)=(\d+)..(\d+)");
  var clayPos = <List<int>>[];
  for (var line in input) {
    var m = exp.firstMatch(line), aux = int.parse(m.group(2));
    for (int p = int.parse(m.group(4)); p <= int.parse(m.group(5)); p++) {
      clayPos.add(m.group(1) == 'x' ? [p, aux] : [aux, p]);
    }
  }

  int maxX = clayPos.fold(0, (int p, e) => max(p, e[1])) + 1,
      minX = clayPos.fold(maxX, (int p, e) => min(p, e[1])) - 1,
      maxY = clayPos.fold(0, (int p, e) => max(p, e[0]));

  var board = List<List<String>>.generate(
      maxY + 1, (_) => List<String>.generate(maxX - minX + 1, (_) => empty));
  clayPos.forEach((p) => board[p[0]][p[1] - minX] = wall);
  board[0][500 - minX] = '+';
  return board;
}

bool fillDown(List<List<String>> board, int y, int x) {
  var initialY = y;

  for (y = y + 1; (y < board.length) && (board[y][x] == empty); y++)
    board[y][x] = water;
  if ((y >= board.length) || (board[y][x] == water)) return true;

  for (y = y - 1; y > initialY; y--) {
    var fillLeft = fillSideways(board, y, x, -1);
    var fillRight = fillSideways(board, y, x, 1);
    if (fillLeft || fillRight) return true;
    // Flood
    for (var aux = x; board[y][aux] == water; aux--) board[y][aux] = flood;
    for (var aux = x + 1; board[y][aux] == water; aux++) board[y][aux] = flood;
  }
  return false;
}

bool fillSideways(List<List<String>> board, int y, int x, int dx) {
  for (x += dx; board[y][x] == empty; x += dx) {
    board[y][x] = water;
    if (board[y + 1][x] == empty) {
      if (fillDown(board, y, x)) return true;
    }
  }
  return false;
}

List<int> getCounts(List<List<String>> board) {
  fillDown(board, 0, board[0].indexOf('+'));

  var waterCount = 0, floodCount = 0;
  var countStarted = false;
  for (var line in board) {
    print(line.join());
    if (!countStarted && line.contains(wall)) countStarted = true;
    if (!countStarted) continue;

    for (var p in line) {
      waterCount += (p == water) ? 1 : 0;
      floodCount += (p == flood) ? 1 : 0;
    }
  }

  return [waterCount, floodCount];
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);
  var board = convert(input);
  var counts = getCounts(board);
  print('First part is ${counts[0] + counts[1]}');
  print('Second part is ${counts[1]}');
}
