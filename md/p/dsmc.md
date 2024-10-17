---
pagetitle: Implementation of the DSMC method
bibliography: '../assets/bib/references.bib'
csl: '../assets/csl/iop-style.csl'
suppress-bibliography: false
link-citations: true
citations-hover: true
---

# Tutorial - the Direct simulation Monte Carlo method

The [direct simulation Monte Carlo (DSMC)](https://en.wikipedia.org/wiki/Direct_simulation_Monte_Carlo) method is a powerful tool for simulating rarified flows.
Throughout this article, we'll use Julia to implement the method to solve the problem of a cloud of particles in a 2D box. 

## Initialization

We'll start out with $N$ particles uniformly-distributed throughout our box, with a gas temperature of 300 K.
To begin, we need a struct to hold our particle positions and velocities.

```julia
struct Particles{T}
    x::Vector{T}
    y::Vector{T}
    vx::Vector{T}
    vy::Vector{T}
end
```

The positions can be straightforwardly sampled from a 2D uniform distribution.

$$
\mathbf{x_j} \sim \mathcal{U}^2(0, 1)
$$

```julia
function initialize(num_particles)
    x = rand(num_particles)
    y = rand(num_particles)
    ...
```

We will draw particle velocities from the appropriate [Maxwell-Boltzmann distribution](https://en.wikipedia.org/wiki/Maxwell%E2%80%93Boltzmann_distribution).
This is a Gaussian (normal) distribution with standard deviation proportional to the square root
of the temperature;

$$
f(v) \propto \exp\left[-\frac{m v^2}{2 k_B T_0}\right]
$$

$$
\implies v_j \sim \mathcal{N}^2(0, \sqrt{k_B T_0 / m})
$$

Here, $v_j$ is the velocity of the $j$-th particle, $k_B$ is the [Boltzmann constant](https://en.wikipedia.org/wiki/Boltzmann_constant),
$T_0 = 300$ K is the gas temperature and $m$ is the particle mass. For this work, we'll choose
argon as our gas, so $m = 39.948$ amu $\times 1.660\times10^{-27}$ kg/amu.

```julia
const argon_mass = 39.948
const atomic_mass_unit = 1.66053906892e-27
const k_B = 1.380649

function initialize(num_particles, gas_temp, mass)
    x = rand(num_particles)
    y = rand(num_particles)

    thermal_speed = sqrt(k_B * gas_temp / (mass * atomic_mass_unit))
    vx = randn(num_particles) * thermal_speed
    vy = randn(num_particles) * thermal_speed

    return Particles(x, y, vx, vy)
end
```

Once we have completed the initialization, we proceed to the main computational loop, which consists of three main steps.

1. Drift - move particles in space
2. Boundaries - check for interactions with boundaries
3. Collide - collide particles with each other

Next, we'll go through each of these steps and implement them.

## Drift

First, we move the particles to new positions based on their present velocities.
There are no external forces in our simulation, so the velocities are constant at this step.
We'll just use a simple forward Euler integration at this stage.

$$
x_j^{n+1} = x_j^n + \Delta t v_j^n
$$

Below is a basic Julia implementation of the drift stage, which uses multithreading
to move each particle in parallel.

```julia
function drift!(particles, timestep)
    Threads.@threads for j in eachindex(particles.x)
        particles.x[j] += dt * particles.v[j]
    end
end
```

## Boundaries

In this step, we account for particle interactions with the simulation boundaries.
In the present simulation, we'll consider solid boundaries at a temperature of $T_w = 500$ K.
When particles hit a wall, there are a number of things that can happen.
If the surface is very smooth, the particle might reflect *specularly*.
When this happens, the particle's velocity normal to the wall is reversed, while the velocity tangential to the wall is retained.
In specular reflection, we assume that the amount of energy transferred to the particle from the wall is negligible.

More commonly, if there is some surface roughness, the particle will reflect *diffusely*.
Diffuse reflection can be thought of as the particle hitting the surface and bouncing around amongst the hills and valleys of the surface microstructure before finally escaping.
Each reflection is specular, but at each the particle absorbs/transfers a tiny amount of energy from/to the wall.
When it finally emerges, the particle has an effectively random orientation and a speed drawn from a Maxwellian distribution at the surface's temperature.
The particle is then said to have "thermally accomodated" to the surface.

The *accomodation coefficient* of a surface, $\alpha$, describes the fraction of particles that reflect diffusely.
A surface with an $\alpha = 1$ is a rough surface that reflects all particles diffusely,
while one with $\alpha = 0$ is extremely smooth and mirror-like. 
Most real surfaces have accomodation coefficients close to one, so in this article we'll
consider diffuse reflection only.

Here's a basic diffuse reflection function, [adapted from one written by Lubos Breida](https://www.particleincell.com/2015/cosine-distribution/)
For each particle, we first check whether we have left the domain, and if so by which boundary.
Then, we get the tangent vector and inward-facing normal vector of that boundary surface.

```julia
function reflect(particles, dt)
    Threads.@threads for j in eachindex(particles.x)
        # loop over all particles
        x = particles.x[j]
        y = particles.y[j]
        vx = particles.vx[j]
        vy = particles.vy[j]
            
        # boundary surface normal
        norm_x = 0.0
        norm_y = 0.0

        # boundary surface tangent
        tang_x = 0.0
        tang_y = 0.0

        # fraction of last step since particle hit boundary

        inbounds = false

        # check each boundary to determine which one we left, if any
        if x < 0
            norm_x = 1.0
            tang_y = -1.0
        else if x > 1 
            norm_x = -1.0
            tang_y = 1.0
        else if y < 0
            norm_y = 1.0
            tang_x = 1.0
        else if y > 1
            norm_y = -1.0
            tang_x = -1.0
        else
            inbounds = true
        end

        if inbounds
            continue # skip this particle -- it is not out of bounds
        end
    ...
```

We next sample the normal component of the velocity unit vector from a cosine distribution, and the tangential component
from a uniform on $[0, 2\pi]$.

```julia
function reflect!()

end

```

## Collide
