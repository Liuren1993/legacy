module MML
#

using Distributions

# types
type clique{T}
  up::Tuple{T,T}
  bottom::Tuple{T,T}
  left::Tuple{T,T}
  right::Tuple{T,T}
  upright::Tuple{T,T}
  bottomleft::Tuple{T,T}
  bottomright::Tuple{T,T}
  upleft::Tuple{T,T}

end

clique(x)=clique( (x[2,2], x[1,2]),
                  (x[2,2], x[3,2]),
                  (x[2,2], x[2,1]),
                  (x[2,2], x[2,3]),
                  (x[2,2], x[1,3]),
                  (x[2,2], x[3,1]),
                  (x[2,2], x[3,3]),
                  (x[2,2], x[1,1]) )

# functions
function pairwise{T}(pair::Tuple{T,T}, beta::Real, label::Real)
    pairwisePotential = 0;
    if isnan(pair[2])

    elseif label == pair[2]
        pairwisePotential = beta
    else
        pairwisePotential = -beta
    end
    return pairwisePotential;
end

function multilevel!{L<:Real,I<:Real,B<:Real}(labelfield::Vector{L}, img::Matrix{I}, alpha::Real, beta::Vector{B})
    labelNum = length(labelfield)
    r,c = size(img)
    imgframe = fill(NaN, r+2, c+2)
    imgframe[2:r+1, 2:c+1] = img
    for i = 1:r, j = 1:c
        # assign clique
        cliqueInstance = clique(imgframe[i:i+2, j:j+2])
        # energy function and conditional probability
        energyFunc = zeros(labelNum)
        conditionalProb = zeros(labelNum)
        for k = 1:labelNum
            potentials = zeros(8)
            potentials[1] = pairwise(cliqueInstance.up, beta[1], labelfield[k])
            potentials[2] = pairwise(cliqueInstance.bottom, beta[1], labelfield[k])
            potentials[3] = pairwise(cliqueInstance.left, beta[2], labelfield[k])
            potentials[4] = pairwise(cliqueInstance.right, beta[2], labelfield[k])
            potentials[5] = pairwise(cliqueInstance.upright, beta[3], labelfield[k])
            potentials[6] = pairwise(cliqueInstance.bottomleft, beta[3], labelfield[k])
            potentials[7] = pairwise(cliqueInstance.bottomright, beta[4], labelfield[k])
            potentials[8] = pairwise(cliqueInstance.upleft, beta[4], labelfield[k])
            energyFunc[k] = alpha * labelfield[k] + sum(potentials)
        end
        for l = 1:labelNum
            conditionalProb[l] = exp(energyFunc[l])/(sum(exp(energyFunc)))
        end
        # sample from multinomial distribution
        mnrnd = Multinomial(1, conditionalProb)
        sample = find(rand(mnrnd,1))
        img[i,j] = sample[1] - 1
    end
    return img
end

# exports
export pairwise, multilevel!, clique

end
