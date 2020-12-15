import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

class Instruction {
  int srcA, srcB, dst;
  String opCode;
  Instruction(this.opCode, this.srcA, this.srcB, this.dst);

  List<int> exec(List<int> inRegs) {
    List<int> regs = List<int>.from(inRegs);
    switch (opCode) {
      case 'addr':
        regs[dst] = regs[srcA] + regs[srcB];
        break;
      case 'addi':
        regs[dst] = regs[srcA] + srcB;
        break;
      case 'mulr':
        regs[dst] = regs[srcA] * regs[srcB];
        break;
      case 'muli':
        regs[dst] = regs[srcA] * srcB;
        break;
      case 'banr':
        regs[dst] = regs[srcA] & regs[srcB];
        break;
      case 'bani':
        regs[dst] = regs[srcA] & srcB;
        break;
      case 'borr':
        regs[dst] = regs[srcA] | regs[srcB];
        break;
      case 'bori':
        regs[dst] = regs[srcA] | srcB;
        break;
      case 'setr':
        regs[dst] = regs[srcA];
        break;
      case 'seti':
        regs[dst] = srcA;
        break;
      case 'gtir':
        regs[dst] = (srcA > regs[srcB]) ? 1 : 0;
        break;
      case 'gtri':
        regs[dst] = (regs[srcA] > srcB) ? 1 : 0;
        break;
      case 'gtrr':
        regs[dst] = (regs[srcA] > regs[srcB]) ? 1 : 0;
        break;
      case 'eqir':
        regs[dst] = (srcA == regs[srcB]) ? 1 : 0;
        break;
      case 'eqri':
        regs[dst] = (regs[srcA] == srcB) ? 1 : 0;
        break;
      case 'eqrr':
        regs[dst] = (regs[srcA] == regs[srcB]) ? 1 : 0;
        break;
    }
    return regs;
  }
}

List<Instruction> convertInstructions(List<String> input) {
  List<Instruction> instructions = <Instruction>[];

  int i = 0;
  while (input[i].startsWith('Before')) i += 3;

  for (; i < input.length; i++) {
    var aux = input[i].split(' ');
    instructions.add(Instruction(
        aux[0], int.parse(aux[1]), int.parse(aux[2]), int.parse(aux[3])));
  }
  return instructions;
}

num solvePart1(int ipReg, List<Instruction> instructions) {
  var regs = [0, 0, 0, 0, 0, 0];
  while (regs[ipReg] < instructions.length) {
    regs = instructions[regs[ipReg]].exec(regs);
    regs[ipReg]++;
  }
  regs[ipReg]--;
  return regs[0];
}

num solvePart2(List<String> input) {
  return 0;
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);
  var ip = int.parse(input[0].substring(4));
  var instructions = convertInstructions(input.skip(1).toList());

  print('First part is ${solvePart1(ip, instructions)}');

  // var r1 = 998; // First part
  var r1 = 10551398; // Second part
  var r0 = 0;
  for (var r4 = 1; r4 <= r1; r4++) {
    if (r1 % r4 == 0)  r0 += r4;
  }
  print('Second part is ${r0}');
}
