import 'dart:io';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

bool validate(List<String> input) {
  return true;
}

class Claim {
  int id, left, top, width, height;

  Claim(this.id, this.left, this.top, this.width, this.height);
}

List<Claim> convert(List<String> input) {
  RegExp exp = new RegExp(r"#(\d+)\s@\s(\d+),(\d+):\s(\d+)x(\d+)");
  return input.map((l) {
    Match match = exp.firstMatch(l);
    return Claim(
        int.parse(match.group(1)),
        int.parse(match.group(2)),
        int.parse(match.group(3)),
        int.parse(match.group(4)),
        int.parse(match.group(5)));
  }).toList();
}

const dim = 1000;
List<List<int>> makeBoardClaims(List<Claim> claims) {
  var board = List.generate(dim, (_) => new List<int>(dim));

  for (var c in claims) {
    for (var i = 0; i < c.height; i++) {
      for (var j = 0; j < c.width; j++) {
        board[c.top + i][c.left + j] =
            (board[c.top + i][c.left + j] == null) ? c.id : -1;
      }
    }
  }
  return board;
}

num solvePart1(List<Claim> input) {
  var board = makeBoardClaims(input);

  var count = 0;
  for (var i = 0; i < dim; i++) {
    for (var j = 0; j < dim; j++) {
      if (board[i][j] == -1) count++;
    }
  }
  return count;
}

num solvePart2(List<Claim> input) {
  var board = List.generate(dim, (_) => List<int>(dim));
  var overlaps = List<bool>(input.length + 1);
  overlaps[0] = true; // Ignore first element

  for (var c in input) {
    overlaps[c.id] = false;
    for (var i = 0; i < c.height; i++) {
      for (var j = 0; j < c.width; j++) {
        if (board[c.top + i][c.left + j] != null) {
          overlaps[c.id] = true;
          if (board[c.top + i][c.left + j] != -1) overlaps[board[c.top + i][c.left + j]] = true;
        }
        board[c.top + i][c.left + j] =
            (board[c.top + i][c.left + j] == null) ? c.id : -1;
      }
    }
  }

  return overlaps.indexOf(false);
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
