import 'dart:io';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

bool validate(List<String> input) {
  return true;
}

List<int> convert(List<String> input) {
  return input[0].split(' ').map((v) => int.parse(v)).toList();
}

class Node {
  int consumed = 0;
  List<Node> children = new List<Node>();
  List<int> metadata;
}

Node buildNode(List<int> input) {
  var countChildren = input[0], countMetadata = input[1];

  Node node = Node()..consumed += 2;
  for (int i = 0; i < countChildren; i++) {
    var child = buildNode(input.sublist(node.consumed));
    node
      ..children.add(child)
      ..consumed += child.consumed;
  }
  node
    ..metadata = List<int>.from(
        input.sublist(node.consumed, node.consumed + countMetadata))
    ..consumed += countMetadata;
  return node;
}

void printNode(Node node) {
  print('Children: ${node.children.length} Metadata: ${node.metadata}');
  for (var n in node.children) printNode(n);
}

int sumMetadata(Node node) {
  var total = node.metadata.reduce((a, b) => a + b);
  return node.children.fold(total, (p, n) => p + sumMetadata(n));
}

num solvePart1(List<int> input) {
  return sumMetadata(buildNode(input));
}

int sumNodeValue(Node node) {
  if (node.children.length == 0) return node.metadata.reduce((a, b) => a + b);

  var nodeValues = node.children.map(sumNodeValue);
  return node.metadata
      .where((idx) => idx > 0 && idx <= nodeValues.length)
      .fold(0, (p, idx) => p + nodeValues.elementAt(idx - 1));
}

num solvePart2(List<int> input) {
  return sumNodeValue(buildNode(input));
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
