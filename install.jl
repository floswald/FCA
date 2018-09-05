# install script
#
# This will download and precompile a number of julia packages.
#
# Requirements:
# * You need a local R installation if you want to run the R benchmark.
# * If you don't have R, just comment out the lines `Pkg.add("RCall")` and `using(RCall)`
# * For another benchmark you need GCC. If you don't have it, no problem to just skip.
# 
# Steps:
# 1. download julia 1.0
# 2. start julia
# 3. change directory to where you downloaded this:
#     cd("path/to/download")
# 4. type command include("install.jl")

@info("I'll install a couple of packages now")

using Pkg
Pkg.add.(["BenchmarkTools","Plots","GR","StatPlots","PyCall","Conda","IJulia","Query","CSV","GLM","Clustering"])
Pkg.add("RCall")



@info("done with installation. now will precompile some packages, so we are faster in the tutorial.")

using BenchmarkTools
using DataFrames
using CSV
using GLM
using Query
using IJulia
using GR
Pkg.build("PyCall")
using PyCall
using Conda


using RCall

@info("done! thanks. See you Thursday!")
