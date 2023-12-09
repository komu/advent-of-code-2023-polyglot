extrapolate <- \(r) if (all(r == 0)) { 0 } else { tail(r, n = 1) + extrapolate(diff(r)) }

m <- read.table("Day09.txt") |> as.matrix()
m |> apply(1, extrapolate) |> sum()
m |> apply(1, \(x) extrapolate(rev(x))) |> sum()
