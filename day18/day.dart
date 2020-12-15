import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

num evolve(List<String> input, int time) {
  int countAdjacent(List<List<String>> board, int y, int x, String e) {
    var count = 0, maxY = board.length - 1, maxX = board[y].length - 1;
    count += (y > 0 && x > 0 && board[y - 1][x - 1] == e) ? 1 : 0;
    count += (y > 0 && board[y - 1][x] == e) ? 1 : 0;
    count += (y > 0 && x < maxX && board[y - 1][x + 1] == e) ? 1 : 0;
    count += (x > 0 && board[y][x - 1] == e) ? 1 : 0;
    count += (x < maxX && board[y][x + 1] == e) ? 1 : 0;
    count += (y < maxY && x > 0 && board[y + 1][x - 1] == e) ? 1 : 0;
    count += (y < maxY && board[y + 1][x] == e) ? 1 : 0;
    count += (y < maxY && x < maxX && board[y + 1][x + 1] == e) ? 1 : 0;
    return count;
  }

  var board = input.map((l) => l.split('')).toList();
  var newBoard = input.map((l) => l.split('')).toList();
  var seen = <String>[];
  var idxSeen = -1;
  String resBoard;
  for (var min = 0; min < time; min++) {
    for (var y = 0; y < board.length; y++) {
      for (var x = 0; x < board[y].length; x++) {
        switch (board[y][x]) {
          case '.':
            if (countAdjacent(board, y, x, '|') >= 3) newBoard[y][x] = '|';
            break;
          case '|':
            if (countAdjacent(board, y, x, '#') >= 3) newBoard[y][x] = '#';
            break;
          case '#':
            if (countAdjacent(board, y, x, '|') == 0 ||
                countAdjacent(board, y, x, '#') == 0) newBoard[y][x] = '.';
            break;
        }
      }
    }
    for (var y = 0; y < board.length; y++)
      for (var x = 0; x < board[y].length; x++)
        board[y][x] = newBoard[y][x];

    // print('Min: $min');
    // board.forEach((l) => print(l.join()));

    resBoard = board.map((l) => l.join()).join();
    idxSeen = seen.indexOf(resBoard);
    if (idxSeen != -1) {
      // print('Found at $idxSeen');
      var period = min - idxSeen;
      resBoard = seen[idxSeen + (time - min - 1) % period];
      break;
    }
    seen.add(resBoard);

  }
  var woodCount = 0, lumbCount = 0;
  for (var i = 0; i < resBoard.length; i++) {
    woodCount += (resBoard[i] == '|') ? 1 : 0;
    lumbCount += (resBoard[i] == '#') ? 1 : 0;
  }
  return woodCount * lumbCount;
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);

  print('First part is ${evolve(input, 10)}');
  print('Second part is ${evolve(input, 1000000000)}');
}
