using SparseDiffTools
using LightGraphs
using Random

Random.seed!(123)

#= Test data =#
test_graphs = Array{VSafeGraph, 1}(undef, 0)

for _ in 1:5
    nv = rand(5:20)
    ne = rand(1:100)
    graph = SimpleGraph(nv)
    for e in 1:ne
        v1 = rand(1:nv)
        v2 = rand(1:nv)
        while v1 == v2
            v2 = rand(1:nv)
        end
        add_edge!(graph, v1, v2)
    end
    push!(test_graphs, copy(graph))
end

#=
 Coloring needs to satisfy two conditions:

1. every pair of adjacent vertices receives distinct  colors
(a distance-1 coloring)

2. For any vertex v, any color that leads to a two-colored path
involving v and three other vertices  is  impermissible  for  v.
In other words, every path on four vertices uses at least three
colors.
=#

for i in 1:5
    g = test_graphs[i]

    out_colors1 = SparseDiffTools.greedy_star1_coloring(g)
    out_colors2 = SparseDiffTools.greedy_star2_coloring(g)

    #test condition 1
    for v = vertices(g)
        color = out_colors1[v]
        for j in inneighbors(g, v)
            @test out_color[j] != color
        end
    end

    #test condition 2
    for j = vertices(g)
        walk = saw(g, j, 4)
        walk_colors = zeros(Int64, 0)
        if length(saw) >= 4
            for t in walk
                push!(walk_colors, out_colors1[t])
            end
            @test unique(walk_colors) >= 3
        end
    end

end
