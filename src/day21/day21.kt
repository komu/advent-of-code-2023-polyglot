import CardinalDirection.*
import kotlin.math.abs
import kotlin.math.absoluteValue
import kotlin.math.sign
import kotlin.io.path.Path
import kotlin.io.path.readLines

private enum class CardinalDirection(val dx: Int, val dy: Int) {
    N(0, -1), W(-1, 0), S(0, 1), E(1, 0);

    companion object {
        fun between(a: Point, b: Point): CardinalDirection? {
            val dx = (b.x - a.x).sign
            val dy = (b.y - a.y).sign

            require(dx == 0 || dy == 0)

            return when {
                dx == 1 -> E
                dx == -1 -> W
                dy == -1 -> N
                dy == 1 -> S
                else -> null
            }
        }
    }
}

private data class Point(val x: Int, val y: Int) {

    operator fun plus(d: CardinalDirection) = Point(x + d.dx, y + d.dy)

    val cardinalNeighbors: List<Point>
        get() = CardinalDirection.entries.map { this + it }

    companion object {
        val ORIGIN = Point(0, 0)
    }
}

private class ElfMap(private val map: List<String>) {
    val size = map.size
    val points = (0..<size).flatMap { y -> (0..<size).map { x -> Point(x, y) } }
    val candidatePoints = points.filter { this[it] != '#' }

    operator fun get(p: Point) = map[p.y.mod(size)][p.x.mod(size)]

    fun inBounds(p: Point) = p.x in 0..<size && p.y in 0..<size

    fun nextState(neighborhood: Neighborhood): Set<Point> =
        candidatePoints.filterTo(mutableSetOf()) { candidate ->
            candidate !in neighborhood.points && hasNeighbor(candidate, neighborhood)
        }

    private fun hasNeighbor(p: Point, neighborhood: Neighborhood) =
        p.cardinalNeighbors.any { n ->
            val normalizedPoint = Point(n.x.mod(size), n.y.mod(size))
            val direction = CardinalDirection.between(Point.ORIGIN, Point(n.x.floorDiv(size), n.y.floorDiv(size)))

            normalizedPoint in neighborhood[direction]
        }
}

private data class Neighborhood(
    val points: Set<Point>,
    val north: Set<Point>,
    val west: Set<Point>,
    val south: Set<Point>,
    val east: Set<Point>
) {

    operator fun get(d: CardinalDirection?) = when (d) {
        N -> north
        W -> west
        S -> south
        E -> east
        null -> points
    }

    companion object {
        operator fun invoke(index: Point, subMaps: Map<Point, SubMap>, gen: Int) = Neighborhood(
            points = subMaps[index]?.activePoints(gen - 1).orEmpty(),
            north = subMaps[index + N]?.activePoints(gen - 1).orEmpty(),
            west = subMaps[index + W]?.activePoints(gen - 1).orEmpty(),
            south = subMaps[index + S]?.activePoints(gen - 1).orEmpty(),
            east = subMaps[index + E]?.activePoints(gen - 1).orEmpty(),
        )
    }
}

private class SubMap private constructor(val birth: Int, val gens: MutableList<Set<Point>>) {

    constructor(birth: Int) : this(birth, mutableListOf())

    val age: Int
        get() = gens.size

    val isFull: Boolean
        get() {
            val tail = gens.asReversed()
            return tail.size > 4 && tail[0].size == tail[2].size && tail[1].size == tail[3].size
        }

    fun activePoints(gen: Int, birth: Int = this.birth): Set<Point> {
        val i = gen - birth
        return when {
            i < 0 -> emptySet()
            i < gens.size -> gens[i]
            else -> gens[gens.size - 2 + (i - gens.size) % 2]
        }
    }

    fun addGeneration(ps: Set<Point>) {
        assert(!isFull)
        gens.add(ps)
    }

    fun countPoints(gen: Int, birth: Int = this.birth): Int =
        activePoints(gen, birth).size

}

private fun mapBirth(x: Int, y: Int) = when {
    x == 0 && y == 0 -> 0
    x == 0 || y == 0 -> 66 + 131 * (abs(x + y) - 1)
    else -> (abs(x) + abs(y)) * 131 - 130
}

private fun computeSubMaps(map: ElfMap, steps: Int, fullMap: Boolean): Map<Point, SubMap> {
    val startPoint = map.points.find { map[it] == 'S' }!!

    val startMap = SubMap(birth = 0)
    startMap.addGeneration(setOf(startPoint))

    val activeSubMaps = mutableMapOf(Point.ORIGIN to startMap)
    val allSubMaps = activeSubMaps.toMutableMap()
    val retiredSubMaps = mutableMapOf<Point, SubMap>()
    val ages = mutableMapOf<Int, Int>()

    val cache = mutableMapOf<Neighborhood, Set<Point>>()

    fun nextState(index: Point, gen: Int): Set<Point> {
        val neighborhood = Neighborhood(index, allSubMaps, gen)
        return cache.getOrPut(neighborhood) { map.nextState(neighborhood) }
    }

    for (gen in 1..steps) {
        // On the big map, once we have 9 distinct maps, we know we don't need any more
        if (fullMap && retiredSubMaps.size == 9)
            break

        val sms = activeSubMaps.entries.filter { !it.value.isFull }

        for ((index, subMap) in sms) {
            val state = nextState(index, gen)
            subMap.addGeneration(state)
        }

        val boundary = activeSubMaps.keys.flatMap { it.cardinalNeighbors }
            .filter { it !in activeSubMaps && it !in retiredSubMaps }.toSet()
        for (index in boundary) {
            if (fullMap && maxOf(index.x.absoluteValue, index.y.absoluteValue) > 1) continue

            val pointsInMap = nextState(index, gen)

            if (pointsInMap.isNotEmpty()) {
                val sm = SubMap(birth = gen)
                sm.addGeneration(pointsInMap)
                allSubMaps[index] = sm
                activeSubMaps[index] = sm
            }
        }

        for ((k, sm) in activeSubMaps)
            if (sm.isFull && k !in retiredSubMaps) {
                retiredSubMaps[k] = sm

                ages[sm.age] = (ages[sm.age] ?: 0) + 1
            }

        activeSubMaps.values.removeIf { it.isFull }
    }

    return allSubMaps
}

fun main() {

    fun part1(input: List<String>, steps: Int): Int {
        val map = ElfMap(input)

        val start = map.points.find { map[it] == 'S' }!!

        var points = setOf(start)
        repeat(steps) {
            points = points.flatMap { p -> p.cardinalNeighbors.filter { map.inBounds(it) && map[it] != '#' } }.toSet()
        }

        return points.size
    }

    fun part2(input: List<String>, steps: Int): Long {
        val fullMap = steps > 10000
        val allSubMaps = computeSubMaps(ElfMap(input), steps, fullMap = fullMap)

        if (!fullMap)
            return allSubMaps.values.sumOf { it.countPoints(steps) }.toLong()

        // By analyzing the input, it can be seen that the birth times of different sub-maps follow the
        // pattern on the left, while their types follow the pattern on the right. Therefore, we only
        // need to calculate the origin and the 8 sub-maps around it to get enough information to
        // calculate the final result.
        //
        // -------------------    -------------------
        // ---------b---------    ---------b---------
        // --------cbc--------    --------fbg--------
        // -------ccbcc-------    -------ffbgg-------
        // ------cccbccc------    ------fffbggg------
        // -----ccccbcccc-----    -----ffffbgggg-----
        // ----cccccbccccc----    ----fffffbggggg----
        // ---bbbbbbabbbbbb---    ---ccccccaeeeeee---
        // ----cccccbccccc----    ----hhhhhdiiiii----
        // -----ccccbcccc-----    -----hhhhdiiii-----
        // ------cccbccc------    ------hhhdiii------
        // -------ccbcc-------    -------hhdii-------
        // --------cbc--------    --------hdi--------
        // ---------b---------    ---------d---------
        // -------------------    -------------------

        fun countPoints(x: Int, y: Int) =
            allSubMaps[Point(x.sign, y.sign)]!!.countPoints(steps, birth = mapBirth(x, y)).toLong()

        // detect the maximum value
        var max = 0
        for (y in 1..Int.MAX_VALUE) {
            val points = countPoints(0, y)
            if (points == 0L) {
                max = y - 1
                break
            }
        }

        fun sumOfCountInQuarters(x: Int, y: Int) =
            countPoints(x, y) + countPoints(-x, y) + countPoints(-x, -y) + countPoints(x, -y)

        // Each quarter has full sub-maps except or the last two. Calculate the values for the last two,
        // but for others just count the number of occurring maps
        val quarters = (1..max).sumOf { y ->
            val rowLen = max - y + 1

            var rowPoints = sumOfCountInQuarters(1 + rowLen - 1, y)

            if (rowLen >= 2)
                rowPoints += sumOfCountInQuarters(1 + rowLen - 2, y)

            if (rowLen >= 3)
                rowPoints += ((rowLen - 2) / 2 + rowLen % 2) * sumOfCountInQuarters(1, y)

            if (rowLen >= 4)
                rowPoints += ((rowLen - 2) / 2) * sumOfCountInQuarters(2, y)

            rowPoints
        }

        val axes = (-max..max).sumOf { if (it != 0) countPoints(it, 0) + countPoints(0, it) else 0 }

        return countPoints(0, 0) + axes + quarters
    }


    val input = Path("data/Day21.txt").readLines()

    println(part1(input, steps = 64))
    println(part2(input, steps = 26501365))
}
