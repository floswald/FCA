

# # The Julia-is-Fast Benchmark Fun: `sum`
#
# In this notebook we are going to compare performance of a very simple function across several different languages: The `sum`. This function computes
# 
# ```math 
# \text{sum}(a) = \sum_{i=1}^n a_i
# ```
# 
# where $n$ is the length of `a`.
# Let's get a vector of numbers:

a = rand(10^7) # 1D vector of random numbers, uniform on [0,1)

sum(a)

# We would expect to see 0.5*10^7, since each element has an expected value of 0.5.

# ## Benchmarks in different languages

# We will use BenchmarkTools.jl for this exercise.

using BenchmarkTools


# C is often considered the gold standard: difficult on the human, nice for the machine. Getting within a factor of 2 of C is often satisfying. Nonetheless, even within C, there are many kinds of optimizations possible that a naive C writer may or may not get the advantage of.

# The current author does not speak C, so he does not read the cell below, but is happy to know that you can put C code in a Julia session, compile it, and run it. Note that the `"""` wrap a multi-line string.

C_code = """
#include <stddef.h>
double c_sum(size_t n, double *X) {
    double s = 0.0;
    for (size_t i = 0; i < n; ++i) {
        s += X[i];
    }
    return s;
}
"""

const Clib = tempname()   # make a temporary file


# compile to a shared library by piping C_code to gcc
# (works only if you have gcc installed):
using Libdl

open(`gcc  -fPIC -O3 -ffast-math -msse3 -xc -shared -o $(Clib * "." * Libdl.dlext) -`, "w") do f
    print(f, C_code) 
end

# define a Julia function that calls the C function:
c_sum(X::Array{Float64}) = ccall(("c_sum", Clib), Float64, (Csize_t, Ptr{Float64}), length(X), X)

c_sum(a)

c_sum(a) ≈ sum(a) # type \approx and then <TAB> to get the ≈ symbolb


c_bench = @benchmark c_sum($a)

println("C: Fastest time was $(minimum(c_bench.times) / 1e6) msec")

d = Dict()  # a "dictionary", i.e. an associative array
d["C"] = minimum(c_bench.times) / 1e6  # in milliseconds
d

# We can see above that the BenchmarkTools library takes many sample runs to account for machine noise in the benchmark. We can look at the distribution of times:

using Plots
gr()

t = c_bench.times / 1e6 # times in milliseconds
using Statistics
m, σ = minimum(t), std(t)

histogram(t, bins=500,
    xlim=(m - 0.01, m + σ),
    xlabel="milliseconds", ylabel="count", label="")

# ## Next: python's built-in `sum`

using PyCall

# Call a low-level PyCall function to get a Python list, because
# by default PyCall will convert to a NumPy array instead (we benchmark NumPy below):

apy_list = PyCall.array2py(a, 1, 1)

# get the Python built-in "sum" function:
pysum = pybuiltin("sum")

pysum(a)

pysum(a) ≈ sum(a)

py_list_bench = @benchmark $pysum($apy_list)

d["Python built-in"] = minimum(py_list_bench.times) / 1e6
d

# ## Next: python's numpy `sum`

# Takes advantage of hardware "SIMD", but only works when it works.

# `numpy` is an optimized C library, callable from Python.
# It may be used within Julia as follows:

using Conda 

numpy_sum = pyimport("numpy")["sum"]
apy_numpy = PyObject(a) # converts to a numpy array by default

py_numpy_bench = @benchmark $numpy_sum($apy_numpy)

numpy_sum(apy_list) # python thing

numpy_sum(apy_list) ≈ sum(a)

d["Python numpy"] = minimum(py_numpy_bench.times) / 1e6
d

# ## Next: python hand-written

py"""
def py_sum(a):
    s = 0.0
    for x in a:
        s = s + x
    return s
"""

sum_py = py"py_sum"

py_hand = @benchmark $sum_py($apy_list)

sum_py(apy_list)

sum_py(apy_list) ≈ sum(a)

d["Python hand-written"] = minimum(py_hand.times) / 1e6
d


# ## julia built-in

# @which sum(a)

j_bench = @benchmark sum($a)

d["Julia built-in"] = minimum(j_bench.times) / 1e6
d

# ## julia hand-written

function mysum(A)   
    s = 0.0  # s = zero(eltype(A))
    for a in A
        s += a
    end
    s
end

j_bench_hand = @benchmark mysum($a)

d["Julia hand-written"] = minimum(j_bench_hand.times) / 1e6
d

# ## `R` built-in
using RCall

r_bench = @benchmark R"sum($a)"
d["R built-in"] = minimum(r_bench.times) / 1e6

# for (key, value) in sort(collect(d))
#     println(rpad(key, 20, "."), lpad(round(value,digits= 1), 8, "."))
# end

for (key, value) in sort(collect(d), by=x->x[2])
    println(rpad(key, 20, "."), lpad(round(value,digits= 2), 10, "."))
end
