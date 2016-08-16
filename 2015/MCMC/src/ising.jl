# Ising Model
#

using ImageView
# algorithm
# include("AutologicModel.jl")
# using AutologicModel
include("SimAnnealing.jl")
using SimAnnealing

# init
# label
labelField = [0, 1]
# image
# img = rand(100,100)
img0 = [zeros(128,128) ones(128,128);
       ones(128,128)  zeros(128,128)]
img =  img0 + 1.5*randn(256,256)
img[ img.>0.5 ] = 1
img[ img.<0.5 ] = 0
# img = img + 0.001*randn(256,256)
view(img0)
view(img)
imgc, imgslice = view(img)

# parameters
alpha = 0                      # 1st-order potential factor
beta = [1, 1, 1, 1]            # interaction parameter
# loops
for mcmctimes = 1:20
    # img = autologic!(labelField, img, alpha, beta)
    temperature = 2/log(1+mcmctimes);
    img = simannealing!(labelField, img, alpha, beta, temperature)
    view(imgc, img)
end

view((img0 - img).^2)
