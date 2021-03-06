import OrdinaryDiffEq, DiffEqCallbacks

"""
integrate()
"""
function integrate(T::Vector{Float64}, f:: Function, state0::S, fout::Function;
                    alg::OrdinaryDiffEq.OrdinaryDiffEqAlgorithm = OrdinaryDiffEq.DP5(),
                    callback = nothing, kwargs...) where S

    if isa(state0, Vector{Float64})
        x0 = state
    else
        x0 = state0.data
    end
    
    fout_diff(u::Vector{Float64}, t::Float64, integrator) = fout(t, S(deepcopy(u)))        

    out_type = pure_inference(fout, Tuple{eltype(T),typeof(state0)})
    out = DiffEqCallbacks.SavedValues(Float64,out_type)
    scb = DiffEqCallbacks.SavingCallback(fout_diff,out,saveat=T,
                                        save_everystep=false,
                                        save_start = false)

    prob = OrdinaryDiffEq.ODEProblem(f, x0, (T[1], T[end]))

    full_cb = OrdinaryDiffEq.CallbackSet(callback, scb)

    sol = OrdinaryDiffEq.solve(prob, alg;
            reltol=1.0e-6,
            abstol=1.0e-8,
            save_everystep = false,
            save_start = false,
            save_end = false,
            callback=full_cb,
            kwargs...)

    out.t, out.saveval

end

Base.@pure pure_inference(fout,T) = Core.Compiler.return_type(fout, T)
