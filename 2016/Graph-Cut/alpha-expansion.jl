# basic α-expansion
using BKMaxflow, LightGraphs


"""
Method for calculating α-expansion algorithm
"""
function αexpansion{T<:Number}(
    L::Vector{T},                       # label set
    D::Function,                        # data term
    I::Vector{T},                       # observed intensity
    V::Function,                        # smooth term
    neighborhood::Vector{Vector{Int}}   # adjacency list
    )

    n = length(I)
    # init success flag
    successFlag = 1
    # 1. Start with an arbitrary labeling f
    f = rand(L, n)
    # @show f
    # f = [4,5,6,7,4,3,6,7,5,4,2,5,2,6,6,7,6,6,5,6,1,2,6,4,7,6,2,7,4,5,7,1,2,5,2,2,5,1,4,3,1,3,7,4,2,1,2,4,3,2]
    count = 0
    while successFlag == 1 && count <= 100   # 4. If success=1 goto 2
        count += 1
        # 2. Set success := 0
        successFlag = 0
        # 3. For each label α ∈ L
        for α in L
            # @show α
            # 3.1 Find f̂ = argminE(f′) among f′ within one α-expansion of f
            # Section 4: finding the optimal expansion move(featuring BK-Maxflow)
            # init corresponding flow graph: [1,...labeling...,n, α, ᾱ, a,b,...auxiliary vertices...]
            flowGraph = DiGraph(n)
            # add edges corresponding to the neighborhood system
            for p in flowGraph.vertices, q in neighborhood[p]
                add_edge!(flowGraph,p,q)
            end
            # add terminal α
            add_vertex!(flowGraph)
            nodeα = flowGraph.vertices[n+1]
            # add terminal ᾱ
            add_vertex!(flowGraph)
            nodeᾱ = flowGraph.vertices[n+2]
            # add auxiliary vertices
            Partition = flowGraph[1:n]
            for p in Partition.vertices, q in neighborhood[p]
                if f[p] != f[q]
                    add_vertex!(flowGraph)
                    add_edge!(flowGraph, p, flowGraph.vertices[end])
                    add_edge!(flowGraph, flowGraph.vertices[end], q)
                    add_edge!(flowGraph, flowGraph.vertices[end], nodeᾱ)
                end
            end
            # set up weights
            capacityMatrix = zeros(nv(flowGraph), nv(flowGraph))
            # add edges to terminal and specify corresponding weights
            for p in Partition.vertices
                # add edges to α
                add_edge!(flowGraph, nodeα, p)
                # t{p}{α}, p ∈ P
                # capacityMatrix[nodeα,p] = D(α, I[p])
                capacityMatrix[nodeα,p] = D(α, p)
                if f[p] == α
                    # add edges to ᾱ
                    add_edge!(flowGraph, p, nodeᾱ)
                    # t{p}{ᾱ}, p ∈ Pα
                    capacityMatrix[p,nodeᾱ] = Inf
                else
                    add_edge!(flowGraph, p, nodeᾱ)
                    # t{p}{ᾱ}, p ∉ Pα
                    # capacityMatrix[p,nodeᾱ] = D(f[p], I[p])
                    capacityMatrix[p,nodeᾱ] = D(f[p], p)
                end
            end
            for p in Partition.vertices, q in neighborhood[p]
                if f[p] == f[q]
                    # e{p}{q}
                    capacityMatrix[p,q] = V(f[p], α)
                end
            end
            # for each auxiliary vertex
            for a in flowGraph.vertices[n+3:end]
                q = out_neighbors(flowGraph, a)[]
                p = in_neighbors(flowGraph, a)[]
                # V(α,fq)
                capacityMatrix[a,q] = V(α, f[q])
                # V(fp,α)
                capacityMatrix[p,a] = V(f[p], α)
                # t{ᾱ}{α}
                capacityMatrix[a,nodeᾱ] = V(f[p], f[q])
            end
            # return flowGraph, nodeα, nodeᾱ, capacityMatrix
            # calculate maximum flow
            Ef̂, flowMatrix = maximum_flow(flowGraph, nodeα, nodeᾱ, capacityMatrix, algorithm=BoykovKolmogorovAlgorithm())
            # Ef̂, flowMatrix = maximum_flow(flowGraph, nodeα, nodeᾱ, capacityMatrix, algorithm=DinicAlgorithm())
            # for each p ∈ P, find out whether p can be visited by α
            residualCapacity = capacityMatrix - flowMatrix + flowMatrix'
            residualGraph = LightGraphs.residual(flowGraph)
            αSet = [nodeα]
            queue = [nodeα]
            while !isempty(queue)
                u = shift!(queue)
                for v in neighbors(residualGraph, u)
                    if residualCapacity[u,v] > 0 && !in(v, αSet)
                        push!(queue, v)
                        push!(αSet, v)
                    end
                end
            end
            # expansion
            f̂ = deepcopy(f)
            for p in Partition.vertices
                if in(p,αSet)

                else
                    f̂[p] = α
                end
            end
            # 3.2 If E(f̂) < E(f), set f := f̂ and success := 1
            # calculate Ef
            Edata = 0.0
            for p in Partition.vertices
                # Edata += D(f[p], I[p])
                Edata += D(f[p], p)
            end
            Esmooth = 0.0
            for p in Partition.vertices, q in neighborhood[p]
                if p < q
                    Esmooth += V(f[p],f[q])
                end
            end
            Ef = Edata + Esmooth
            # if count == 10
                @show Ef̂, Ef
                # @show f̂, f
            # end
            # update f
            if Ef̂ < Ef
                f = deepcopy(f̂)
                successFlag = 1
            end
        end
    end

    @show count
    # 5. return f
    return f
end



# example
# dataterm(f,i) = (f-i)^2
# smoothterm(p,q) = 50*abs(p-q)
# # smoothterm(p,q) = 0
# # neighborhood = convert(Vector{Vector{Int}}, Any[[2,4],[1,3,5],[2,6],[1,5,7],[2,4,6,8],[3,5,9],[4,8],[5,7,9],[6,8]])
# neighborhood = convert(Vector{Vector{Int}}, Any[[2],[1,3],[2,4],[3]])
# image = Int[1,2,2,4]
# out = αexpansion([1,2,3,4], dataterm, image, smoothterm, neighborhood)
# @show out



# function dataterm(l,p)
#     if p < 5 && l == 0
#         return 0
#     end
#     if p < 5 && l != 0
#         return 10
#     end
#     if p >= 5 && l == 5
#         return 0
#     end
#     if p >= 5 && l != 5
#         return 10
#     end
# end

function smoothterm(p,q)
    return min((p-q)^2, 4)
end

# image = collect(1:9)
# neighborhood = convert(Vector{Vector{Int}}, Any[[2,4],[1,3,5],[2,6],[1,5,7],[2,4,6,8],[3,5,9],[4,8],[5,7,9],[6,8]])
# # flowGraph, nodeα, nodeᾱ, capacityMatrix = αexpansion([0,1,2,3,4,5,6,7], dataterm, image, smoothterm, neighborhood)
# out = αexpansion([0,1,2,3,4,5,6,7], dataterm, image, smoothterm, neighborhood)
# @show out




function dataterm(l,p)
    if p <=25 && l == 0
        return 0
    end
    if p <= 25 && l != 0
        return 10
    end
    if p > 25 && l == 5
        return 0
    end
    if p > 25 && l != 5
        return 10
    end
end
n6 = [1,7,11]
m7 = [2,6,8,12]
neighborhood = convert(Vector{Vector{Int}}, Any[[2,6],[1,3,7],[2,4,8],[3,5,9],[4,10],
                                                n6, m7, m7+1, m7+2, [5,9,15],
                                                n6+5, m7+5, m7+6, m7+7, [10,14,20],
                                                n6+10, m7+10, m7+11, m7+12, [15,19,25],
                                                n6+15, m7+15, m7+16, m7+17, [20,24,30],
                                                n6+20, m7+20, m7+21, m7+22, [25,29,35],
                                                n6+25, m7+25, m7+26, m7+27, [30,34,40],
                                                n6+30, m7+30, m7+31, m7+32, [35,29,45],
                                                n6+35, m7+35, m7+36, m7+37, [40,44,50],
                                                [41,47], [42,46,48], [43,47,49], [44,48,50], [45,49]])
image = collect(1:50)
out = αexpansion([0,1,2,3,4,5,6], dataterm, image, smoothterm, neighborhood)
@show out[1:25]
# exports
