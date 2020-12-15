import 'dart:io';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

List<int> solvePart1(int input) {
  var board = List<int>.from([3, 7]);
  var idx0 = 0, idx1 = 1;

  while (board.length < input + 10) {
    var next = board[idx0] + board[idx1];
    if (next >= 10) board.add(next ~/ 10);
    board.add(next % 10);

    idx0 = (idx0 + board[idx0] + 1) % board.length;
    idx1 = (idx1 + board[idx1] + 1) % board.length;
  }

  return board.sublist(input, input + 10);
}

num solvePart2(int input) {
  bool endsWith(List<int> list, List<int> suffix) {
    if (list.length < suffix.length) return false;

    for (int i = 0; i < suffix.length; i++) {
      if (list[list.length - suffix.length + i] != suffix[i]) return false;
    }
    return true;
  }

  var listInput = input.toString().split('').map(int.parse).toList();
  var board = List<int>.from([3, 7]);
  var idx0 = 0, idx1 = 1;

  while (true) {
    var next = board[idx0] + board[idx1];
    if (next >= 10) {
      board.add(next ~/ 10);
      if (endsWith(board, listInput)) return board.length - listInput.length;
    }

    board.add(next % 10);
      if (endsWith(board, listInput)) return board.length - listInput.length;

    idx0 = (idx0 + board[idx0] + 1) % board.length;
    idx1 = (idx1 + board[idx1] + 1) % board.length;
  }
}

void main(List<String> arguments) {
  var input = 260321;
  print('First part is ${solvePart1(input).join()}');
  print('Second part is ${solvePart2(input)}');
}
