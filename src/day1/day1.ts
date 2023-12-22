import type {Add, Multiply} from "ts-arithmetic";

type Digit = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9;

type ReverseString<S> = S extends `${infer X}${infer Xs}` ? `${ReverseString<Xs>}${X}` : '';
type FirstDigit1<S> = S extends `${infer X}${infer Xs}` ? X extends `${infer D extends Digit}` ? D : FirstDigit1<Xs> : never;

type CalibrationValue1<S> = Add<Multiply<10, FirstDigit1<S>>, FirstDigit1<ReverseString<S>>>;
type Part1<S, Acc extends number = 0> = S extends `${infer L}\n${infer Ls}` ? Part1<Ls, Add<Acc, CalibrationValue1<L>>> : Add<Acc, CalibrationValue1<S>>;

// @formatter:off
type FirstDigit2<S> =
    S extends `${infer D extends Digit}${string}` ? D
    : S extends `one${string}` ? 1
    : S extends `two${string}` ? 2
    : S extends `three${string}` ? 3
    : S extends `four${string}` ? 4
    : S extends `five${string}` ? 5
    : S extends `six${string}` ? 6
    : S extends `seven${string}` ? 7
    : S extends `eight${string}` ? 8
    : S extends `nine${string}` ? 9
    : S extends `${string}${infer Tail}` ? FirstDigit2<Tail>
    : never;

type LastDigit2<S> =
    S extends `${infer D extends Digit}${string}` ? D
    : S extends `eno${string}` ? 1
    : S extends `owt${string}` ? 2
    : S extends `eerht${string}` ? 3
    : S extends `ruof${string}` ? 4
    : S extends `evif${string}` ? 5
    : S extends `xis${string}` ? 6
    : S extends `enves${string}` ? 7
    : S extends `thgie${string}` ? 8
    : S extends `enin${string}` ? 9
    : S extends `${string}${infer Tail}` ? LastDigit2<Tail>
    : never;

// @formatter:on

type CalibrationValue2<S> = Add<Multiply<10, FirstDigit2<S>>, LastDigit2<ReverseString<S>>>;
type Part2<S, Acc extends number = 0> = S extends `${infer L}\n${infer Ls}` ? Part2<Ls, Add<Acc, CalibrationValue2<L>>> : Add<Acc, CalibrationValue2<S>>;

type Example1 = `1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet`;

type Example2 = `two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen`;

type Data = `your data here`;

const testExample1: Part1<Example1> = 142;
const testExample2: Part2<Example2> = 281;
const part1: Part1<Data> = undefined;
const part2: Part2<Data> = undefined;
