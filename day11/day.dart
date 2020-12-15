import 'dart:io';
import 'dart:math';

const gridSz = 300;

List<List<int>> genGrid(int serialNumber) {
  var grid = List.generate(gridSz, (_) => List.generate(gridSz, (_) => 0));
  for (int x = 0; x < gridSz; x++) {
    for (int y = 0; y < gridSz; y++) {
      int rackId = (x + 1) + 10;
      int powerLevel = (rackId * (y + 1) + serialNumber) * rackId;
      grid[x][y] = (powerLevel ~/ 100) % 10 - 5;
    }
  }
  return grid;
}

List<int> getMaxSquare(List<List<int>> grid, int squareSz) {
  var gridSquareSum = List.generate(grid.length, (_) => List.generate(grid[0].length, (_) => 0));
  int maxX = 0, maxY = 0, maxSum = -1000;

  for (int x = 0; x < gridSz - squareSz; x++) {
    for (int y = 0; y < gridSz - squareSz; y++) {
      for (int sqx = 0; sqx < squareSz; sqx++) {
        for (int sqy = 0; sqy < squareSz; sqy++) {
          gridSquareSum[x][y] += grid[x + sqx][y + sqy];
        }
      }

      if (gridSquareSum[x][y] > maxSum) {
        maxX = x;
        maxY = y;
        maxSum = gridSquareSum[x][y];
      }
    }
  }
  return [maxX + 1, maxY + 1, maxSum];
}

List<int> solvePart1(int serialNumber) {
  return getMaxSquare(genGrid(serialNumber), 3);
}

List<int> solvePart2(int serialNumber) {
  var squareSum, maxSquareSum = 0, maxSz = 0;
  var grid = genGrid(serialNumber);

  for (var i = 1; i < 301; i++) {
    squareSum = getMaxSquare(grid, i)[2];
    print('Size $i | Max ${squareSum}');
    if (squareSum <= 0) break;
    if (squareSum > maxSquareSum) {
      maxSquareSum = squareSum;
      maxSz = i;
    }
  }
  return getMaxSquare(grid, maxSz)..add(maxSz);
}

void main(List<String> arguments) {
  int serialNumber = 9306;

  print('First part is ${solvePart1(serialNumber)}\n');
  print('Second part is ${solvePart2(serialNumber)}\n');
}
