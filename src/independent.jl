module independent

using ArrayViews
using QuantumOptics
using ..interaction, ..system

"""
Product state of N single spin Bloch states.

Arguments
---------

phi
    Azimuthal angle(s).
theta
    Polar angle(s).
"""
function blochstate{T1<:Real, T2<:Real}(phi::Vector{T1}, theta::Vector{T2})
    N = length(phi)
    @assert length(theta)==N
    state = zeros(Float64, 3*N)
    state[0*N+1:1*N] = cos(phi).*sin(theta)
    state[1*N+1:2*N] = sin(phi).*sin(theta)
    state[2*N+1:3*N] = cos(theta)
    return state
end

function blochstate(phi::Real, theta::Real, N::Int=1)
    state = zeros(Float64, 3*N)
    state[0*N+1:1*N] = ones(Float64, N)*cos(phi)*sin(theta)
    state[1*N+1:2*N] = ones(Float64, N)*sin(phi)*sin(theta)
    state[2*N+1:3*N] = ones(Float64, N)*cos(theta)
    return state
end

"""
Number of spins described by this state.
"""
function dim(state::Vector{Float64})
    N, rem = divrem(length(state), 3)
    @assert rem==0
    return N
end

"""
Split state into sx, sy and sz parts.
"""
function splitstate(state::Vector{Float64})
    N = dim(state)
    return ArrayViews.view(state, 0*N+1:1*N), ArrayViews.view(state, 1*N+1:2*N), ArrayViews.view(state, 2*N+1:3*N)
end

"""
Create single spin density operator.

Arguments
---------

sx
    sigmax expectation value.
sy
    sigmay expectation value.
sz
    sigmaz expectation value.
"""
function densityoperator(sx::Number, sy::Number, sz::Number)
    return 0.5*(identityoperator(spinbasis) + sx*sigmax + sy*sigmay + sz*sigmaz)
end

"""
Create density operator from vector.

Arguments
---------

state
    Classical state consisting of single spin expectation values.
"""
function densityoperator(state::Vector{Float64})
    N = dim(state)
    sx, sy, sz = splitstate(state)
    if N>1
        return reduce(tensor, [densityoperator(sx[i], sy[i], sz[i]) for i=1:N])
    else
        return densityoperator(sx[i], sy[i], sz[i])
    end
end

"""
Sigmax expectation values of state.
"""
sx(state::Vector{Float64}) = ArrayViews.view(state, 1:dim(state))
"""
Sigmay expectation values of state.
"""
sy(state::Vector{Float64}) = ArrayViews.view(state, dim(state)+1:2*dim(state))
"""
Sigmaz expectation values of state.
"""
sz(state::Vector{Float64}) = ArrayViews.view(state, 2*dim(state)+1:3*dim(state))


"""
Independent time evolution.

Arguments
---------

T
    Points of time for which output will be generated.
gamma
    Single spin decay rate.
state0
    Initial state.
"""
function timeevolution(T, gamma::Number, state0::Vector{Float64})
    N = dim(state0)
    γ = gamma
    function f(t, s::Vector{Float64}, ds::Vector{Float64})
        sx, sy, sz = splitstate(s)
        dsx, dsy, dsz = splitstate(ds)
        @inbounds for k=1:N
            dsx[k] = -0.5*γ*sx[k]
            dsy[k] = -0.5*γ*sy[k]
            dsz[k] = -γ*(1+sz[k])
        end
    end

    t_out = Float64[]
    state_out = Vector{Float64}[]
    function fout(t, y::Vector{Float64})
        push!(t_out, t)
        push!(state_out, deepcopy(y))
    end

    QuantumOptics.ode_dopri.ode(f, T, state0, fout=fout)
    return t_out, state_out
end

"""
Independent time evolution.

Arguments
---------

T
    Points of time for which output will be generated.
S
    SpinCollection describing the system.
state0
    Initial state.
"""
timeevolution(T, S::system.SpinCollection, state0::Vector{Float64}) = timeevolution(T, S.gamma, state0)

end # module