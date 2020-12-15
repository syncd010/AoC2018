import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

enum Opcode {
  addr,
  addi,
  mulr,
  muli,
  banr,
  bani,
  borr,
  bori,
  setr,
  seti,
  gtir,
  gtri,
  gtrr,
  eqir,
  eqri,
  eqrr
}

class Instruction {
  int opNum, srcA, srcB, dst;
  Instruction(this.opNum, this.srcA, this.srcB, this.dst);

  List<int> exec(Opcode opCode, List<int> inRegs) {
    List<int> regs = List<int>.from(inRegs);
    switch (opCode) {
      case Opcode.addr:
        regs[dst] = regs[srcA] + regs[srcB];
        break;
      case Opcode.addi:
        regs[dst] = regs[srcA] + srcB;
        break;
      case Opcode.mulr:
        regs[dst] = regs[srcA] * regs[srcB];
        break;
      case Opcode.muli:
        regs[dst] = regs[srcA] * srcB;
        break;
      case Opcode.banr:
        regs[dst] = regs[srcA] & regs[srcB];
        break;
      case Opcode.bani:
        regs[dst] = regs[srcA] & srcB;
        break;
      case Opcode.borr:
        regs[dst] = regs[srcA] | regs[srcB];
        break;
      case Opcode.bori:
        regs[dst] = regs[srcA] | srcB;
        break;
      case Opcode.setr:
        regs[dst] = regs[srcA];
        break;
      case Opcode.seti:
        regs[dst] = srcA;
        break;
      case Opcode.gtir:
        regs[dst] = (srcA > regs[srcB]) ? 1 : 0;
        break;
      case Opcode.gtri:
        regs[dst] = (regs[srcA] > srcB) ? 1 : 0;
        break;
      case Opcode.gtrr:
        regs[dst] = (regs[srcA] > regs[srcB]) ? 1 : 0;
        break;
      case Opcode.eqir:
        regs[dst] = (srcA == regs[srcB]) ? 1 : 0;
        break;
      case Opcode.eqri:
        regs[dst] = (regs[srcA] == srcB) ? 1 : 0;
        break;
      case Opcode.eqrr:
        regs[dst] = (regs[srcA] == regs[srcB]) ? 1 : 0;
        break;
    }
    return regs;
  }
}

class Example {
  List<int> regsBefore, regsAfter;
  Instruction instruction;
  Example(this.regsBefore, this.instruction, this.regsAfter);
}

List<Example> convertExamples(List<String> input) {
  List<Example> examples = <Example>[];

  for (var i = 0; i < input.length; i += 3) {
    if (!input[i].startsWith('Before')) break;

    var regsBefore =
        input[i].substring(9, 19).split(',').map(int.parse).toList();

    var aux = input[i + 1].split(' ').map(int.parse).toList();
    var instruction = Instruction(aux[0], aux[1], aux[2], aux[3]);

    var regsAfter =
        input[i + 2].substring(9, 19).split(',').map(int.parse).toList();
    examples.add(Example(regsBefore, instruction, regsAfter));
  }
  return examples;
}

List<Instruction> convertInstructions(List<String> input) {
  List<Instruction> instructions = <Instruction>[];

  int i = 0;
  while (input[i].startsWith('Before')) i += 3;

  for (; i < input.length; i++) {
    var aux = input[i].split(' ').map(int.parse).toList();
    instructions.add(Instruction(aux[0], aux[1], aux[2], aux[3]));
  }
  return instructions;
}

bool equalLists(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
  return true;
}

num solvePart1(List<Example> examples) {
  // All possible opcodes for each opnum
  var maps =
      List<List<Opcode>>.generate(Opcode.values.length, (_) => Opcode.values);

  var ans = 0;
  for (var ex in examples) {
    var count = maps[ex.instruction.opNum]
        .where((opCode) => equalLists(
            ex.regsAfter, ex.instruction.exec(opCode, ex.regsBefore)))
        .length;
    if (count >= 3) ans++;
  }
  return ans;
}

num solvePart2(List<Example> examples, List<Instruction> instructions) {
  // All possible opcodes for each opnum
  var maps =
      List<List<Opcode>>.generate(Opcode.values.length, (_) => Opcode.values);

  // Find the opcodes that work with the examples
  for (var ex in examples) {
    maps[ex.instruction.opNum] = maps[ex.instruction.opNum]
        .where((opCode) => equalLists(
            ex.regsAfter, ex.instruction.exec(opCode, ex.regsBefore)))
        .toList();
  }

  // Reduce the opcode list
  while (maps.any((e) => e.length > 1)) {
    for (var constraint in maps.where((e) => e.length == 1))
      for (var map in maps.where((a) => a.length > 1))
        map.remove(constraint[0]);
  }

  var regs = [0, 0, 0, 0];
  for (var inst in instructions) {
    regs = inst.exec(maps[inst.opNum][0], regs);
  }

  return regs[0];
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);

  var examples = convertExamples(input);
  var instructions = convertInstructions(input);

  print('First part is ${solvePart1(examples)}');
  print('Second part is ${solvePart2(examples, instructions)}');
}
