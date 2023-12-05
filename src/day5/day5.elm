import Html exposing (text)
import Debug exposing (todo)
import List exposing (sortBy, reverse, map, filterMap, head, drop, minimum, foldr, foldl)
import String exposing (words, dropLeft, join, split, lines)
import Maybe exposing (withDefault)

type alias Num = Int
type alias Range = { start: Num, end: Num }
type alias RangeMapping = { destination: Num, source: Range }
type alias Move = { source: Range, destination: Range }
type alias MappingSet = List RangeMapping

range : Num -> Num -> Range
range start end = { start = start, end = end }

rangeIsEmpty : Range -> Bool
rangeIsEmpty r = r.end < r.start

rangeWithStartAndLength : Num -> Num -> Range
rangeWithStartAndLength start length = range start (start + length - 1)

rangeLength : Range -> Num
rangeLength r = r.end - r.start + 1

-- If ranges overlap, returns the overlapping part, otherwise None
rangeOverlap : Range -> Range -> Maybe Range
rangeOverlap a b =
    if a.start <= b.end && b.start <= a.end then
        Just { start = max a.start b.start, end = min a.end b.end }
    else
        Nothing

-- Merge adjacent and overlapping ranges to minimize the number of total ranges
mergeRanges : List Range -> List Range
mergeRanges rngs = case sortBy .start rngs of
    []    -> []
    first::rest -> 
        let recurse current acc ranges = case ranges of 
                []    -> reverse (current::acc)
                r::rs -> if current.end + 1 >= r.start
                    then recurse (range current.start (max current.end r.end)) acc rs
                    else recurse r (current::acc) rs
        in recurse first [] rest

-- If given range is within the mapping, return the Move to new range
applyRangeMapping : RangeMapping -> Range -> Maybe Move
applyRangeMapping m = 
    let process overlap = 
          let offset = overlap.start - m.source.start
          in { 
            source = m.source, 
            destination = rangeWithStartAndLength (m.destination + offset) (rangeLength overlap)
          }
    in rangeOverlap m.source >> Maybe.map process

-- Apply all mappings in the set to all given ranges
applyMappingSetToRanges : MappingSet -> List Range -> List Range
applyMappingSetToRanges ms = 
   let apply : Range -> List Range
       apply r = 
          let moves = filterMap (\rm -> applyRangeMapping rm r) ms
              movedRegions = map .source moves
              moved = map .destination moves
              nonMoved = nonOverlappingSubRanges r movedRegions
          in moved ++ nonMoved
   in List.concatMap apply >> mergeRanges

-- Returns sub-ranges of r range that don't overlap with any of the ranges in rs.
nonOverlappingSubRanges : Range -> List Range -> List Range
nonOverlappingSubRanges initial others =
  let loop : Range -> List Range -> List Range -> List Range
      loop current result ranges = case ranges of
         []    -> if List.isEmpty others then current::result else result
         r::rs -> if current.start < r.start 
                         then let newResult = (range current.start (r.start - 1))::result
                                  newCurrent = range (r.end + 1) current.end
                              in if rangeIsEmpty newCurrent
                                  then newResult else loop newCurrent newResult rs
                         else loop current result rs
  in reverse (loop initial [] (mergeRanges others))

parse : String -> (List Num, List MappingSet)
parse input = 
   let parseRangeMapping : String -> RangeMapping
       parseRangeMapping s = case words s of
           [dst, src, len] -> { 
                 destination = parseNum dst,
                 source = rangeWithStartAndLength (parseNum src) (parseNum len)
            }
           xs -> todo (String.concat ["invalid range mapping: ", (Debug.toString xs)])
       parseMappingSet : String -> MappingSet
       parseMappingSet s = lines s |> drop 1 |> map parseRangeMapping
       seeds = lines input |> head |> withDefault "" |> dropLeft 7 |> words |> map parseNum
       mappings = lines input |> drop 2 |> join "\n" |> split "\n\n" |> map parseMappingSet
  in (seeds, mappings)

parseNum : String -> Num
parseNum = Maybe.withDefault -1 << String.toInt

lowest : List MappingSet -> List Range -> Int
lowest ms rs = foldl applyMappingSetToRanges rs ms |> map .start |> minimum |> withDefault -1

pairs : List a -> List (a, a)
pairs list = case list of
   x::y::xs -> (x,y)::(pairs xs)
   _        -> []

part1 : String -> Num
part1 input =
   let (seeds, mappings) = parse input
       seedRanges = map (\r -> rangeWithStartAndLength r 1) seeds
   in lowest mappings seedRanges

part2 : String -> Num
part2 input =
   let (seeds, mappings) = parse input
       seedRanges = map (\(s,l) -> rangeWithStartAndLength s l) (pairs seeds)
   in lowest mappings seedRanges

main =
    let results = { test1 = part1 testData, test2 = part2 testData, real1 = part1 realData, real2 = part2 realData }
    in text (Debug.toString results)

testData = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"""
 
realData = """<your data>"""

