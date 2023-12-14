function read_platform(filename)
    open(filename) do file
        lines = collect.(collect(eachline(file)))
        permutedims(hcat(lines...))
    end
end

function Base.getindex(m::Matrix{Char}, p::Vector{Int64})
    (x,y) = p
    m[y, x]
end

function Base.setindex!(m::Matrix{Char}, value::Char, p::Vector{Int64})
    (x,y) = p
    m[y, x] = value
end

function in_bounds(pl, p)
    (x,y) = p
    checkbounds(Bool, pl, y, x)
end

function tilt!(platform, v)
    (height, width) = size(platform)
    (dx, dy) = v
    xs = (dx < 0) ? (2:width) : (dx > 0) ? (width - 1:-1:1) : (1:width)
    ys = (dy < 0) ? (2:height) : (dy > 0) ? (height - 1:-1:1) : (1:height)

    for y in ys
        for x in xs
            p = [x, y]
            if platform[p] == 'O'
                pp = p + v

                while in_bounds(platform, pp) && platform[pp] == '.'
                    pp += v
                end

                platform[p] = '.'
                platform[pp - v] = 'O'
            end
        end
    end
end

function cycle(platform)
    copy = deepcopy(platform)
    tilt!.((copy,), [[0, -1], [-1, 0], [0, 1], [1, 0]])
    copy
end

function load(platform)
    sum = 0
    (height, _) = size(platform)
    for (index, row) in enumerate(eachrow(platform))
        c = count(x -> x == 'O', row)
        multiplier = height - (index - 1)
        sum += c * multiplier
    end
    sum
end

function part1(file)
    platform = read_platform(file)
    tilt!(platform, [0, -1])
    load(platform)
end

function part2(file)
    platform = read_platform(file)

    seen_indices = Dict()
    seen = []
    current = platform
    i = 0
    while true
        prefix = get(seen_indices, current, -1)

        if prefix != -1
            period = i - prefix
            index = ((1_000_000_000 - prefix) % period) + prefix
            return load(seen[index + 1])
        else
            push!(seen, current)
            seen_indices[current] = i
        end

        current = cycle(current)
        i += 1
    end
end

@assert part1("Day14_test.txt") == 136
@assert part2("Day14_test.txt") == 64

println("part1 ", part1("Day14.txt"))
println("part2 ", part2("Day14.txt"))
