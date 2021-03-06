using Test
using QuantumOptics, CollectiveSpins
using Statistics

@testset "symmetric-equations" begin

cs = CollectiveSpins

# System parameters
a = 0.18
γ = 1
e_dipole = [0, 0, 1]
T = [0:0.05:5;]


# =========== Test square configuration =========================

system_square = SpinCollection(cs.geometry.square(a), e_dipole; gamma=γ)
N_square = length(system_square.spins)

# Initial state (Bloch state)
phi0_square = [0. for i=1:N_square]
phi1_square = [0., 0.5*pi, 1.5*pi, 1.0*pi]
phi2_square = [0., 1.0*pi, 1.0*pi, 2.0*pi]
theta_square = ones(Float64, N_square)*pi/2.


# Meanfield
state0_mf = cs.meanfield.blochstate(phi0_square, theta_square)
state1_mf = cs.meanfield.blochstate(phi1_square, theta_square)
state2_mf = cs.meanfield.blochstate(phi2_square, theta_square)

tout, state0_mf_t = cs.meanfield.timeevolution(T, system_square, state0_mf)
tout, state1_mf_t = cs.meanfield.timeevolution(T, system_square, state1_mf)
tout, state2_mf_t = cs.meanfield.timeevolution(T, system_square, state2_mf)

# Symmetric meanfield
state0_sym = cs.meanfield.blochstate(0., pi/2., 1)

Ωeff0_, Γeff0_ = cs.effective_interaction.square_orthogonal(a)
Ωeff0, Γeff0 = cs.effective_interaction_rotated.square_orthogonal(a, 0)
Ωeff1, Γeff1 = cs.effective_interaction_rotated.square_orthogonal(a, 1)
Ωeff2, Γeff2 = cs.effective_interaction_rotated.square_orthogonal(a, 2)
@test (Ωeff0_-Ωeff0) < 1e-12
@test (Γeff0_-Γeff0) < 1e-12

tout, state0_mfsym_t = cs.meanfield.timeevolution_symmetric(T, state0_sym, Ωeff0, Γeff0)
tout, state1_mfsym_t = cs.meanfield.timeevolution_symmetric(T, state0_sym, Ωeff1, Γeff1)
tout, state2_mfsym_t = cs.meanfield.timeevolution_symmetric(T, state0_sym, Ωeff2, Γeff2)

for i=1:length(T)
    state0_mf_rotated = state0_mf_t[i]
    state1_mf_rotated = cs.meanfield.rotate([0.,0.,1.], -phi1_square, state1_mf_t[i])
    state2_mf_rotated = cs.meanfield.rotate([0.,0.,1.], -phi2_square, state2_mf_t[i])
    @test var(cs.meanfield.sx(state0_mf_rotated)) < 1e-12
    @test var(cs.meanfield.sy(state0_mf_rotated)) < 1e-12
    @test var(cs.meanfield.sz(state0_mf_rotated)) < 1e-12
    @test var(cs.meanfield.sx(state1_mf_rotated)) < 1e-12
    @test var(cs.meanfield.sy(state1_mf_rotated)) < 1e-12
    @test var(cs.meanfield.sz(state1_mf_rotated)) < 1e-12
    @test var(cs.meanfield.sx(state2_mf_rotated)) < 1e-12
    @test var(cs.meanfield.sy(state2_mf_rotated)) < 1e-12
    @test var(cs.meanfield.sz(state2_mf_rotated)) < 1e-12

    @test cs.meanfield.sx(state0_mf_rotated)[1]-cs.meanfield.sx(state0_mfsym_t[i])[1] < 1e-12
    @test cs.meanfield.sy(state0_mf_rotated)[1]-cs.meanfield.sy(state0_mfsym_t[i])[1] < 1e-12
    @test cs.meanfield.sz(state0_mf_rotated)[1]-cs.meanfield.sz(state0_mfsym_t[i])[1] < 1e-12
    @test cs.meanfield.sx(state1_mf_rotated)[1]-cs.meanfield.sx(state1_mfsym_t[i])[1] < 1e-12
    @test cs.meanfield.sy(state1_mf_rotated)[1]-cs.meanfield.sy(state1_mfsym_t[i])[1] < 1e-12
    @test cs.meanfield.sz(state1_mf_rotated)[1]-cs.meanfield.sz(state1_mfsym_t[i])[1] < 1e-12
    @test cs.meanfield.sx(state2_mf_rotated)[1]-cs.meanfield.sx(state2_mfsym_t[i])[1] < 1e-12
    @test cs.meanfield.sy(state2_mf_rotated)[1]-cs.meanfield.sy(state2_mfsym_t[i])[1] < 1e-12
    @test cs.meanfield.sz(state2_mf_rotated)[1]-cs.meanfield.sz(state2_mfsym_t[i])[1] < 1e-12
end



# =========== Test cube configuration ===========================

system_cube = SpinCollection(cs.geometry.cube(a), e_dipole; gamma=γ)
N_cube = length(system_cube.spins)

# Initial state (Bloch state)

dphi1_cube = pi
phi0_cube = [0. for i=1:N_cube]
phi1_cube = [0., 0., 0., 0., dphi1_cube, dphi1_cube, dphi1_cube, dphi1_cube]
theta_cube = ones(Float64, N_cube)*pi/2.

# Meanfield
state0_mf = cs.meanfield.blochstate(phi0_cube, theta_cube)
state1_mf = cs.meanfield.blochstate(phi1_cube, theta_cube)

tout, state0_mf_t = cs.meanfield.timeevolution(T, system_cube, state0_mf)
tout, state1_mf_t = cs.meanfield.timeevolution(T, system_cube, state1_mf)

# Symmetric meanfield
state0_sym = cs.meanfield.blochstate(0., pi/2., 1)

Ωeff0_, Γeff0_ = cs.effective_interaction.cube_orthogonal(a)
Ωeff0, Γeff0 = cs.effective_interaction_rotated.cube_orthogonal(a, 0.)
Ωeff1, Γeff1 = cs.effective_interaction_rotated.cube_orthogonal(a, dphi1_cube)
@test (Ωeff0_-Ωeff0) < 1e-12
@test (Γeff0_-Γeff0) < 1e-12

tout, state0_mfsym_t = cs.meanfield.timeevolution_symmetric(T, state0_sym, Ωeff0, Γeff0)
tout, state1_mfsym_t = cs.meanfield.timeevolution_symmetric(T, state0_sym, Ωeff1, Γeff1)

for i=1:length(T)
    state0_mf_rotated = state0_mf_t[i]
    state1_mf_rotated = cs.meanfield.rotate([0.,0.,1.], -phi1_cube, state1_mf_t[i])

    @test var(cs.meanfield.sx(state0_mf_rotated)) < 1e-8
    @test var(cs.meanfield.sy(state0_mf_rotated)) < 1e-8
    @test var(cs.meanfield.sz(state0_mf_rotated)) < 1e-8
    @test var(cs.meanfield.sx(state1_mf_rotated)) < 1e-8
    @test var(cs.meanfield.sy(state1_mf_rotated)) < 1e-8
    @test var(cs.meanfield.sz(state1_mf_rotated)) < 1e-8

    @test cs.meanfield.sx(state0_mf_rotated)[1]-cs.meanfield.sx(state0_mfsym_t[i])[1] < 1e-8
    @test cs.meanfield.sy(state0_mf_rotated)[1]-cs.meanfield.sy(state0_mfsym_t[i])[1] < 1e-8
    @test cs.meanfield.sz(state0_mf_rotated)[1]-cs.meanfield.sz(state0_mfsym_t[i])[1] < 1e-8
    @test cs.meanfield.sx(state1_mf_rotated)[1]-cs.meanfield.sx(state1_mfsym_t[i])[1] < 1e-8
    @test cs.meanfield.sy(state1_mf_rotated)[1]-cs.meanfield.sy(state1_mfsym_t[i])[1] < 1e-8
    @test cs.meanfield.sz(state1_mf_rotated)[1]-cs.meanfield.sz(state1_mfsym_t[i])[1] < 1e-8
end

end # testset
