import 'dart:io';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsStringSync().split('\n');
  return lines.where((l) => (l != null) && (l.length > 0)).toList();
}

const String ImmuneType = "Immune System";
const String InfectedType = "Infection";

class Group {
  String unitType, attackType;
  int id, unitCount, hp, ap, initiative;
  List<String> weak = <String>[], imune = <String>[];

  num get effectivePower => unitCount * ap;
  Group target;
  bool isBeingAttacked;

  Group(this.unitType, this.id, this.unitCount, this.hp, this.ap,
      this.attackType, this.initiative);

  bool isImuneTo(String power) => imune.contains(power);
  bool isWeakTo(String power) => weak.contains(power);

  num calcDamageTo(Group other) =>
      (other == null || other.isImuneTo(attackType))
          ? 0
          : (other.isWeakTo(attackType)) ? effectivePower * 2 : effectivePower;
}

List<Group> convert(List<String> input) {
  var groups = <Group>[];
  String type;
  int imuneId = 1, infectionId = 1, currId;

  for (var line in input) {
    if (line.endsWith(":")) {
      type = line.substring(0, line.length - 1);
      continue;
    }
    if (type == InfectedType) currId = infectionId++;
    if (type == ImmuneType) currId = imuneId++;

    RegExp exp = RegExp(
        r"(\d+) units each with (\d+) hit points ?(\(.*\))? with an attack that does (\d+) (\S+) damage at initiative (\d+)");
    var m = exp.firstMatch(line);

    Group group = Group(
        type,
        currId,
        int.parse(m.group(1)),
        int.parse(m.group(2)),
        int.parse(m.group(4)),
        m.group(5),
        int.parse(m.group(6)));

    if (m.group(3) != null) {
      var aux = m.group(3).substring(1, m.group(3).length - 1);
      for (var desc in aux.split("; ")) {
        if (desc.startsWith("weak"))
          group.weak = desc.replaceAll("weak to ", "").split(", ");
        if (desc.startsWith("immune"))
          group.imune = desc.replaceAll("immune to ", "").split(", ");
      }
    }
    groups.add(group);
  }
  return groups;
}

num countLiveUnits(List<Group> groups, String type) => groups.fold(
    0, (p, g) => g.unitCount > 0 && g.unitType == type ? p + g.unitCount : p);

List<Group> simulateFight(List<Group> groups, {bool verbose = false}) {
  while (countLiveUnits(groups, InfectedType) > 0 &&
      countLiveUnits(groups, ImmuneType) > 0) {
    if (verbose) print("\nRound start");
    // Initialize
    for (var g in groups) {
      g.isBeingAttacked = false;
      g.target = null;
      if (verbose && g.unitCount > 0)
        print("${g.unitType} group ${g.id} contains ${g.unitCount} units");
    }
    groups.sort((g1, g2) => g1.effectivePower == g2.effectivePower
        ? g2.initiative - g1.initiative
        : g2.effectivePower - g1.effectivePower);
    for (var g in groups) {
      if (g.unitCount <= 0) continue;
      var maxDamage = 0;

      for (var other in groups) {
        // If not an enemy, is dead or is already attacked skip
        if (other.unitType == g.unitType ||
            other.unitCount <= 0 ||
            other.isBeingAttacked) continue;

        var damage = g.calcDamageTo(other);
        if (damage > maxDamage) {
          maxDamage = damage;
          g.target = other;
        }
      }
      g.target?.isBeingAttacked = true;
      if (verbose && g.target != null)
        print("${g.unitType} group ${g.id} will attack defending group "
            "${g.target?.id} with ${g.calcDamageTo(g.target)} damage");
    }
    groups.sort((g1, g2) => g2.initiative - g1.initiative);
    var totalKills = 0;
    for (var g in groups) {
      if (g.unitCount <= 0 || g.target == null) continue;
      if (verbose)
        print("${g.unitType} group ${g.id} attacks defending group "
            "${g.target?.id}, killing ${min(g.target.unitCount, (g.calcDamageTo(g.target) ~/ g.target.hp))} units");
      var kills =
          min(g.target.unitCount, (g.calcDamageTo(g.target) ~/ g.target.hp));
      g.target.unitCount -= kills;
      totalKills += kills;
    }
    if (totalKills == 0) return groups;
  }
  return groups;
}

List<Group> clone(List<Group> input, {num imuneAttackBoost = 0}) {
  var cloned = <Group>[];
  for (var g in input) {
    var aux = Group(
        g.unitType, g.id, g.unitCount, g.hp, g.ap, g.attackType, g.initiative);
    if (aux.unitType == ImmuneType) aux.ap += imuneAttackBoost;
    aux.imune = List<String>.of(g.imune);
    aux.weak = List<String>.of(g.weak);
    cloned.add(aux);
  }
  return cloned;
}

num solvePart1(List<Group> input) {
  var res = simulateFight(clone(input, imuneAttackBoost: 0), verbose: false);
  return countLiveUnits(res, InfectedType) + countLiveUnits(res, ImmuneType);
}

num solvePart2(List<Group> input) {
  var attackBoost = 0, boostStep = 2048;

  do {
    attackBoost += boostStep;
    var res = simulateFight(clone(input, imuneAttackBoost: attackBoost),
        verbose: false);
    var immuneCount = countLiveUnits(res, ImmuneType),
        infectedCount = countLiveUnits(res, InfectedType);
    print(
        "With boost ${attackBoost}, survive immune: $immuneCount, infected: $infectedCount");
    if (immuneCount > 0 && infectedCount == 0) {
      attackBoost -= boostStep;
      boostStep ~/= 2;
    }
  } while (boostStep > 0);
  attackBoost++;
  var res = simulateFight(clone(input, imuneAttackBoost: attackBoost));
  return countLiveUnits(res, ImmuneType);
}

void main(List<String> arguments) {
  if (arguments.length < 1) {
    print('Please provide an input file\n');
    exit(1);
  }

  var input = readInput(arguments[0]);
  var groups = convert(input);

  print('First part is ${solvePart1(groups)}');
  print('Second part is ${solvePart2(groups)}');
}
