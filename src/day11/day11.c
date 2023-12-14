#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

typedef struct {
    unsigned width;
    unsigned height;
    char* data;
    unsigned galaxy_count;
    unsigned* galaxies;
    unsigned empty_row_count;
    unsigned* empty_rows;
    unsigned empty_col_count;
    unsigned* empty_cols;
} universe;

void* malloc_or_die(unsigned long size) {
    void* ptr = malloc(size);
    if (!ptr) {
        fprintf(stderr, "failed to allocate buffer\n");
        exit(1);
    }
    return ptr;
}

universe load_universe(const char* file, unsigned width, unsigned height) {
    FILE* fp = fopen(file, "r");
    if (fp == NULL) {
        perror(file);
        exit(1);
    }

    universe u = {
       .width = width,
       .height = height,
       .galaxy_count = 0,
       .empty_row_count = 0,
       .empty_col_count = 0,
       .data = malloc_or_die(width * height + 3),
       .galaxies = malloc_or_die(width * height * sizeof(unsigned)),
       .empty_rows = malloc_or_die(height * sizeof(unsigned)),
       .empty_cols = malloc_or_die(width * sizeof(unsigned)),
    };

    // Reads each line including the following line separator and terminator,
    // but writes over those when reading the next line, resulting a continuous
    // segment of our universe.
    for (unsigned y = 0; y < height; y++)
        fgets(u.data + y * width, width + 2, fp);

    for (unsigned i = 0; i < width * height; i++)
        if (u.data[i] == '#')
            u.galaxy_count++;

    for (unsigned i = 0, g = 0; i < width * height; i++)
        if (u.data[i] == '#')
            u.galaxies[g++] = i;

    for (unsigned y = 0; y < height; y++) {
        bool empty = true;
        for (unsigned x = 0; x < width; x++) {
            if (u.data[y*width + x] != '.') {
                empty = false;
                break;
            }
        }

        if (empty)
            u.empty_rows[u.empty_row_count++] = y;
    }

    for (unsigned x = 0; x < width; x++) {
        bool empty = true;
        for (unsigned y = 0; y < height; y++) {
            if (u.data[y*width + x] != '.') {
                empty = false;
                break;
            }
        }

        if (empty)
            u.empty_cols[u.empty_col_count++] = x;
    }

    fclose(fp);

    return u;
}

void free_universe(universe u) {
    free(u.data);
    free(u.galaxies);
    free(u.empty_rows);
    free(u.empty_cols);
}

int compare_unsigned(const void * a, const void * b) {
    return (*(unsigned*)a - *(unsigned*)b);
}

unsigned long distance(const universe* u, unsigned g1, unsigned g2, unsigned expansion) {
    unsigned x1 = g1 % u->width;
    unsigned y1 = g1 / u->width;
    unsigned x2 = g2 % u->width;
    unsigned y2 = g2 / u->width;
    unsigned x_start = MIN(x1, x2);
    unsigned x_end = MAX(x1, x2);
    unsigned y_start = MIN(y1, y2);
    unsigned y_end = MAX(y1, y2);

    unsigned long empty = 0;
    for (unsigned y = y_start+1; y < y_end; y++)
        if (bsearch(&y, u->empty_rows, u->empty_row_count, sizeof(unsigned), compare_unsigned) != NULL)
            empty++;

    for (unsigned x = x_start+1; x < x_end; x++)
        if (bsearch(&x, u->empty_cols, u->empty_col_count, sizeof(unsigned), compare_unsigned) != NULL)
            empty++;

    return (x_end - x_start) + (y_end - y_start) + empty * (expansion - 1);
}

unsigned long solve(const universe* u, unsigned expansion) {
    unsigned long sum = 0;

    for (unsigned a = 0; a < u->galaxy_count; a++)
        for (unsigned b = a + 1; b < u->galaxy_count; b++)
            sum += distance(u, u->galaxies[a], u->galaxies[b], expansion);

    return sum;
}

int main() {
    universe u = load_universe("Day11.txt", 140, 140);

    printf("part1: %ld\n", solve(&u, 2));
    printf("part2: %ld\n", solve(&u, 1000000));

    free_universe(u);
    return 0;
}
