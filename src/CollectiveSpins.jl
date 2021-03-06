module CollectiveSpins

export Spin, SpinCollection, CavityMode, CavitySpinCollection,
        geometry


include("system.jl")
include("timeevolution_base.jl")
include("geometry.jl")
include("interaction.jl")
include("effective_interaction.jl")
include("effective_interaction_simple.jl")
include("effective_interaction_rotated.jl")
include("quantum.jl")
include("independent.jl")
include("meanfield.jl")
include("mpc.jl")
include("io.jl")

using .system
using .quantum
using .meanfield
using .mpc

end # module
