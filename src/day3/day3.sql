create table aoc_files
(
    name    varchar primary key,
    content varchar not null
);

insert into aoc_files (name, content) values ('day3.txt', '<your data>');

with split_lines AS (SELECT unnest(string_to_array(content, E'\n'))                              AS line,
                            generate_series(1, array_length(string_to_array(content, E'\n'), 1)) AS y
                     FROM aoc_files
                     where name = 'day3.txt'),
     schematic AS (SELECT y,
                          generate_series(1, char_length(line))                            AS x,
                          substring(line from generate_series(1, char_length(line)) for 1) AS character
                   FROM split_lines),
     number_regexp_matches AS (SELECT sl.y,
                                      regexp_matches(sl.line, '\d+', 'g') as match,
                                      gs.x_start,
                                      sl.line
                               FROM split_lines sl
                                        CROSS JOIN LATERAL
                                   generate_series(1, length(sl.line)) AS gs(x_start)),
     numbers AS (SELECT y,
                        x_start,
                        x_start + char_length(match[1]) - 1                                 as x_end,
                        cast(substring(line from x_start for char_length(match[1])) as int) as value
                 FROM number_regexp_matches
                 WHERE substring(line from x_start for char_length(match[1])) = match[1]),
     part1 as (select sum(value) as part1
               from numbers n
               where exists (select *
                             from schematic s
                             where s.y between n.y - 1 and n.y + 1
                               and s.x between n.x_start - 1 and n.x_end + 1
                               and s.character != '.'
                               and s.character !~ '^[0-9]$')),
     gear_positions as (select s.x, s.y
                        from schematic s
                                 inner join numbers n on s.y between n.y - 1 and n.y + 1 and
                                                         s.x between n.x_start - 1 and n.x_end + 1
                        where s.character = '*'
                        group by s.x, s.y
                        having count(n.*) = 2),
     gear_ratios as (select g.x, g.y, n1.*, n2.*, n1.value * n2.value as gear_ratio
                     from gear_positions g
                              inner join numbers n1 on g.y between n1.y - 1 and n1.y + 1 and
                                                       g.x between n1.x_start - 1 and n1.x_end + 1
                              inner join numbers n2 on g.y between n2.y - 1 and n2.y + 1 and
                                                       g.x between n2.x_start - 1 and n2.x_end + 1
                     where n1.x_start != n2.x_start
                        or n1.y != n2.y),
     part2 as (select sum(gear_ratio) / 2 as part2 from gear_ratios)
select *
from part1,
     part2;
