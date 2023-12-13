type hand_type = FiveOfAKind | FourOfAKind | FullHouse | ThreeOfAKind | TwoPairs | OnePair | High
type card = int
let joker = 1

let parse_cards s jokers =
  let card_indices = "_023456789TJQKA" in
  let parse_card c = if jokers && c == 'J' then joker else String.index card_indices c
  in String.to_seq s |> Seq.map parse_card |> List.of_seq

let sorted_counts (cards: 'a list) =
  let rec loop cards counts = match (cards, counts) with
    | (x::xs, (y,n)::cs) when x == y -> loop xs ((x,n+1)::cs)
    | (x::xs, cs)                    -> loop xs ((x,1)::cs)
    | ([], cs)                       -> cs
  in loop (List.sort compare cards) [] |>
     List.map snd |>
     List.sort (fun x y -> compare y x)

let analyze_hand cards =
  let jokers = List.filter ((==) joker) cards |> List.length in
  let counts = match sorted_counts (List.filter ((!=) joker) cards) with
    | best::rest -> (best + jokers)::rest
    | x -> x
  in match counts with
  | []     -> FiveOfAKind
  | 5::_   -> FiveOfAKind
  | 4::_   -> FourOfAKind
  | [_; _] -> FullHouse
  | 3::_   -> ThreeOfAKind
  | [2; n; _] when n + jokers == 2 -> TwoPairs
  | 2::_   -> OnePair
  | _      -> High

let compare_hands (a: card list) (b: card list) =
  match compare (analyze_hand a) (analyze_hand b) with
  | 0 -> - compare a b
  | n -> n

let parse_hand_and_bid jokers s =
  let hand = parse_cards (String.sub s 0 5) jokers in
  let bid = int_of_string (String.sub s 6 (String.length s - 6)) in
  (hand, bid)

let read_file filename =
  let lines = ref [] in
  let chan = open_in filename in
  try
    while true; do
      lines := input_line chan :: !lines
    done;
    !lines
  with End_of_file ->
    close_in chan;
    List.rev !lines

let solve file jokers = read_file file |>
                        List.map (parse_hand_and_bid jokers) |>
                        List.sort (fun (x,_) (y,_) -> compare_hands y x) |>
                        List.mapi (fun i (_, bid) -> (i+1)*bid) |>
                        List.fold_left (+) 0

let () =
  let p1 = solve "Day07.txt" false in
  let p2 = solve "Day07.txt" true in
  Printf.printf "part1: %d\npart2: %d\n" p1 p2
