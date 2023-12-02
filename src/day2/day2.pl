:- use_module(library(dcg/basics)).

% Grammar rules for parsing the input

game(GameID, Cubes) --> "Game ", integer(GameID), ": ", cubes(Cubes).

cubes([Cube|Cubes]) --> cube(Cube), separator, !, cubes(Cubes).
cubes([Cube]) --> cube(Cube).

cube(cube(Color, Number)) --> integer(Number), " ", color(Color).

color(Color) --> string(ColorAtom), { atom_codes(Color, ColorAtom) }.

separator --> (", "; "; ").

% Helpers to call DCG parser

parse_game(Line, game(GameID, Cubes)) :-
    string_codes(Line, Codes),
    phrase(game(GameID, Cubes), Codes).

parse_games([], []).
parse_games([L|Ls], [G|Gs]) :- parse_game(L,G), parse_games(Ls, Gs).

% Part 1

max_count(red, 12).
max_count(green, 13).
max_count(blue, 14).

satisfies_all_constraints([]).
satisfies_all_constraints([cube(Color,Count)|Cs]) :-
    max_count(Color, Max),
    Count =< Max,
    satisfies_all_constraints(Cs).

part1_solution([], 0).
part1_solution([game(Id, Constraints)|Gs], Sum) :-
    satisfies_all_constraints(Constraints), !,
    part1_solution(Gs, Sum1),
    Sum is Sum1 + Id.
part1_solution([_|Gs], Sum) :-
    part1_solution(Gs, Sum).

% Part 2

maximum_value([], _, 1).
maximum_value([cube(Color, Value)|Cs], Color, Max) :-
    maximum_value(Cs, Color, RestMax), !,
    Max is max(RestMax, Value).
maximum_value([_|Cs], Color, Max) :-
    maximum_value(Cs, Color, Max).

part2_solution([], 0).
part2_solution([game(_, Constraints)|Gs], Sum) :-
    maximum_value(Constraints, red, Red),
    maximum_value(Constraints, green, Green),
    maximum_value(Constraints, blue, Blue),
    Product is Red * Green * Blue,
    part2_solution(Gs, Sum1),
    Sum is Sum1 + Product.

% Main

solve(Part1, Part2) :-
    file_lines('../../data/Day02.txt', Lines),
    parse_games(Lines, Games),
    part1_solution(Games, Part1), !,
    part2_solution(Games, Part2), !.

file_lines(File, Lines) :-
    open(File, read, Stream),
    read_lines(Stream, Lines),
    close(Stream).

read_lines(Stream,[]) :- at_end_of_stream(Stream), !.
read_lines(Stream, [Line|Lines]) :- read_line_to_string(Stream, Line), read_lines(Stream, Lines).
