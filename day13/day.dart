import 'dart:io';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

List<List<String>> convert(List<String> input) {
  return input.map((l) => l.split('')).toList();
}

List<List<String>> removeCarts(List<List<String>> input) {
  var maze = List.generate(input.length, (i) => List<String>.from(input[i]));
  bool isCurve(String c) => c == '\\' || c == '/';

  for (var y = 0; y < maze.length; y++) {
    for (var x = 0; x < maze[y].length; x++) {
      if (maze[y][x] != '<' && maze[y][x] != '>' ||
          maze[y][x] != '^' && maze[y][x] != 'v') {
        continue;
      }

      // Instersections
      if (y > 0 && y < maze.length - 1 && x > 0 && x < maze[y].length - 1 &&
          (maze[y - 1][x] == '|' || isCurve(maze[y - 1][x])) &&
          (maze[y + 1][x] == '|' || isCurve(maze[y + 1][x])) &&
          (maze[y][x - 1] == '-' || isCurve(maze[y][x - 1])) &&
          (maze[y][x + 1] == '-' || isCurve(maze[y][x + 1]))) {
        maze[y][x] = '+';
        continue;
      }

      // This fails in some situations, where we have 2 carts one after the
      // other <v >> >^ that kind of stuff. Doesn't happen on the input, so
      // we'll ignore it.
      switch (maze[y][x]) {
        case '<':
        case '>':
          if (y < maze.length - 1 && maze[y + 1][x] == '|') {
            maze[y][x] = (maze[y][x] == '<') ? '\\' : '/';
          }
          else if (y > 0 && maze[y - 1][x] == '|')
            maze[y][x] = (maze[y][x] == '<') ? '/' : '\\';
          else
            maze[y][x] = '-';
          continue;
        case '^':
        case 'v':
          if (x < maze[y].length - 1 && maze[y][x + 1] == '-')
            maze[y][x] = (maze[y][x] == '^') ? '\\' : '/';
          else if (x > 0 && maze[y][x - 1] == '-')
            maze[y][x] = (maze[y][x] == '^') ? '/' : '\\';
          else
            maze[y][x] = '|';
          continue;
      }
    }
  }

  return maze;
}

class Cart {
  int x, y, id;
  String dir;
  int _count = 0;
  static int idCount = 1;

  Cart(this.x, this.y, this.dir) {
    id = idCount++;
  }

  void move(List<List<String>> maze) {
    if (dir == 'v') y += 1;
    if (dir == '^') y -= 1;
    if (dir == '>') x += 1;
    if (dir == '<') x -= 1;

    switch (maze[y][x]) {
      case '\\':
        if (dir == 'v') dir = '>';
        else if (dir == '^') dir = '<';
        else if (dir == '>') dir = 'v';
        else if (dir == '<') dir = '^';
        break;
      case '/':
        if (dir == 'v') dir = '<';
        else if (dir == '^') dir = '>';
        else if (dir == '>') dir = '^';
        else if (dir == '<') dir = 'v';
        break;
      case '+':
        if (_count == 0) {
          if (dir == 'v') dir = '>';
          else if (dir == '^') dir = '<';
          else if (dir == '>') dir = '^';
          else if (dir == '<') dir = 'v';
        }
        else if (_count == 2) {
          if (dir == 'v') dir = '<';
          else if (dir == '^') dir = '>';
          else if (dir == '>') dir = 'v';
          else if (dir == '<') dir = '^';
        }
        _count = (_count + 1) % 3;
        break;
    }
  }
}

List<Cart> getCarts(List<List<String>> maze) {
  var ans = <Cart>[];
  for (var y = 0; y < maze.length; y++) {
    for (var x = 0; x < maze[y].length; x++) {
      if (!(maze[y][x] == '<' || maze[y][x] == '>' ||
          maze[y][x] == '^' || maze[y][x] == 'v')) continue;
      ans.add(Cart(x, y, maze[y][x]));
    }
  }
  return ans;
}

void printMaze(List<List<String>> maze, List<Cart> carts) {
  var newMaze = List<List<String>>.generate(maze.length, (i) => List<String>.from(maze[i]));

  for (var cart in carts) newMaze[cart.y][cart.x] = cart.dir;
  for (var line in newMaze) print(line.join(''));
}

List<int> solvePart1(List<List<String>> maze, List<Cart> carts) {
  while (true) {
    carts.sort((a, b) => (a.y == b.y) ? a.x - b.x : a.y - b.y);

    for (var cart in carts) {
      cart.move(maze);

      for (var other in carts) {
        if (cart.id == other.id) continue;
        if (cart.x == other.x && cart.y == other.y) {
          print('Carts ${cart.id} and ${other.id} collided.');
          return [cart.x, cart.y];
        }
      }
    }
  }
}

List<int> solvePart2(List<List<String>> maze, List<Cart> carts) {
  while (true) {
    carts.sort((a, b) => (a.y == b.y) ? a.x - b.x : a.y - b.y);

    var collisions = Set<int>();
    for (var cart in carts) {
      if (collisions.contains(cart.id)) continue;
      cart.move(maze);

      for (var other in carts) {
        if (cart.id == other.id) continue;
        if (cart.x == other.x && cart.y == other.y) {
          print('Carts ${cart.id} and ${other.id} collided');
          collisions.addAll([cart.id, other.id]);
          break;
        }
      }
    }

    carts.removeWhere((c) => collisions.contains(c.id));
    if (carts.length == 1) return [carts[0].x, carts[0].y];
    if (carts.length == 0) return null;
  }
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = convert(readInput(arguments[0]));
  var maze = removeCarts(input);

  var carts = getCarts(input);
  print('First part is ${solvePart1(maze, carts)}\n');
  Cart.idCount = 1;
  carts = getCarts(input);
  print('Second part is ${solvePart2(maze, carts)}');
}
