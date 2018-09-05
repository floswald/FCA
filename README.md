# FCA workshop

Materials for the FCA workshop.

## How to use

1. You can follow most of what we do in your browser by going to www.juliabox.com. We have julia version 0.6.2 there.
2. If you want to follow along with me on the just released version 1.0 on your computer, you need to download julia and install a couple of packages.

## Installation

If you want to install, please follow these steps.

1. download julia 1.0 from www.julialang.org
2. start julia
3. In julia, change directory to where you downloaded this repository with
    `cd("path/to/download")`
4. type command `include("install.jl")`

**Requirements**:

* You need a local `R` installation if you want to run the `R` benchmark.
* If you don't have R, just comment out the lines `Pkg.add("RCall")` and `using(RCall)` in the `install.jl` script.
* For another benchmark you need GCC. If you don't have it, no problem to just skip.
