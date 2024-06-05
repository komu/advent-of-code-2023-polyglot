#!/usr/bin/env python

import networkx as nx

def solve(path):
    G = nx.Graph()

    for line in open(path).readlines():
        (node, connected_nodes) = line.split(": ")

        for connected_node in connected_nodes.split():
            G.add_edge(node, connected_node)

    (c1, c2) = nx.k_edge_components(G, 4)
    return len(c1) * len(c2)


if __name__ == '__main__':
    print(solve("../../data/Day25_test.txt"))
    print(solve("../../data/Day25.txt"))
