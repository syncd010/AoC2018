# Advent of Code 2018 in Dart

My solutions for the [Advent of Code 2018](https://adventofcode.com/2018) in [Dart](https://dart.dev/).

Each day's puzzle is in a separate directory, with the solution, the AoC description and inputs.

To run:
```
cd day{n}
dart run day.dart FILE
```
for `FILE`, the files `input`, `input2` or `inputTest` located in the corresponding directory can be used. If no file is present, the parameters are probably hard coded in the program, so check it.

## Some random notes:
- For days 9, 11 and 14 the input is hardcoded in the source file, in `main`.
- For day 19 Part 2 the input program is "decoded" and implemented directly, which means that with some other input file it won't give the right answer.
- Day 21 takes some time to run. The implemented solution interprets the input program, which takes some time. Alternatively the input program could/should be "decoded" and implemented directly.