import 'dart:math';


// Doubly linked chain, cyclical
class ChainMarble {
  int value;
  ChainMarble next, prev;

  ChainMarble(int value) {
    this.value = value;
    this.next = this;
    this.prev = this;
  }

  ChainMarble insertAfter(ChainMarble m) {
    m.next = this.next;
    m.prev = this;
    this.next.prev = m;
    this.next = m;
    return m;
  }

  // Removes this node and returns it
  ChainMarble remove() {
    prev.next = next;
    next.prev = prev;
    return this;
  }
}

num solve(int nPlayers, int nMarbles) {
  List<int> scores = List<int>.generate(nPlayers, (_) => 0);

  var currMarble = ChainMarble(0);
  var chainStart = currMarble;

  for (var i = 1; i <= nMarbles; i++) {
    if (i % 23 == 0) {
      for (var j = 0; j < 7; j++) currMarble = currMarble.prev;
      scores[(i - 1) % nPlayers] += (i + currMarble.value);
      currMarble = currMarble.remove().next;
    } else {
      currMarble = currMarble.next.insertAfter(ChainMarble(i));
    }

    // var m = chainStart;
    // for (var j = 1; j <= i + 1; j++) {
    //   var msg = (m == currMarble) ? '(${m.value}) ' : '${m.value} ';
    //   stdout.write(msg);
    //   m = m.next;
    // }
    // print('');
  }

  return scores.reduce(max);
}

void main(List<String> arguments) {
  // int nPlayers = 30, nMarbles = 5807;
  // int nPlayers = 428, nMarbles = 72061;
  int nPlayers = 426, nMarbles = 72058;

  print('First part is ${solve(nPlayers, nMarbles)}\n');
  print('Second part is ${solve(nPlayers, nMarbles * 100)}\n');
}
