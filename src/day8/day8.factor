USING: kernel assocs math sequences io io.files io.encodings.utf8 accessors regexp splitting
       arrays vectors prettyprint strings ;
IN: day8

: test-data-path ( -- path ) "/Users/komu/src/komu/advent-of-code-2023-polyglot/data/Day08_test2.txt" ;
: data-path ( -- path ) "/Users/komu/src/komu/advent-of-code-2023-polyglot/data/Day08.txt" ;

: filter-non-empty ( lines -- lines ) [ empty? not ] filter ;

: parse-line ( str -- key pair )
    " = " split1 rest but-last ", " split1 2array ;

: parse-data ( lines -- instructions assoc )
    [ first ]
    [ 2 tail filter-non-empty [ parse-line ] map>alist ]
    bi ;

TUPLE: state path assoc current ;

: <state> ( path assoc current -- state ) state boa ;

: extract-state ( state -- path assoc current ) [ path>> ] [ assoc>> ] [ current>> ] tri ;

: load-data ( path -- instructions assoc ) utf8 file-lines parse-data ;

: mod-index ( index str -- char ) dup length rot swap mod swap nth 1string ;

: take-step ( index path assoc current -- path assoc current )
    [ [ mod-index ] keep swap ] 2dip
    3dup swap at swap 1 head "L" = [ 0 ] [ 1 ] if swap nth swap drop rot drop ;

: take-state-step ( n state -- state )
    extract-state take-step <state> ;

: process ( state num -- seq ) <iota> swap [ swap take-state-step ] accumulate swap drop ;

: part1 ( -- ) data-path load-data "AAA" <state> 100_000 process [ current>> "ZZZ" = ] find drop . ;

