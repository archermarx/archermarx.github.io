#let body_size=11pt
#set text(
    font: "EB Garamond", size: body_size,
    historical-ligatures: true,
    number-type: "old-style",
    kerning: true,
)
#let heading_font = "Futura"
#let heading_weight = "semibold"
#let heading_size = 14pt
#let heading_color = blue
#let par_space = 9pt
#let page_margin = 0.75in
#set line(
    stroke: (
        paint: blue, 
        thickness: 1.2pt, 
        dash: "densely-dotted",
    )
)

//#let setcase(text) = text
#let setcase(text) = upper(text)

#show ";": sym.space.hair
#show "|": sym.space.thin

#set page(margin: page_margin)
#set par(spacing: par_space)

#let tightline(factor: 1) = v(-0.5*factor*body_size)
#let vspace = v(0.5 * body_size)

#let hrule = {
    tightline()
    box(line(length: 100%))
}

#show heading: head => [
    #set text(
        font: heading_font,
        weight: heading_weight,
        size: heading_size,
        fill: heading_color,
    )
    #box[#head.body #hrule]
]

#let title = [
    #box(grid(
        columns: (auto, 1fr),
        align: bottom,
        align(left, text(
            1.3 * heading_size,
            weight: heading_weight,
            font: heading_font,
            fill: heading_color)[
            #setcase[Thomas Archer Marks]
        ]),
        align(right, grid(
            rows: (auto, auto),
            align(right, text(body_size)[
                #link("http://www.thomasmarks.space")[thomasmarks.space]
            ]),
            v(0.5*par_space),
            align(right, text(body_size)[
                marksta\@umich.edu
            ]),
        ))
    ))
    #hrule
]

#let softbreak() = {parbreak(); v(-0.3*par_space)}

#let indentlen = 2em
#let indentedblock(body) = {
    set enum(indent: indentlen)
    set list(indent: indentlen)
    par(body, first-line-indent: indentlen, hanging-indent: indentlen)
}

#let cvblock(title: [], date: [], loc: none, extras: ())={
    grid(
        columns: (3fr, 1fr),
        align: (left, right),
        text(title, weight: "bold"),
        text(date)
    ) 
    set enum(indent: indentlen)
    set list(indent: indentlen)
    if(loc != none) {
        softbreak()
        text(loc)
    }
    for line in extras {
        softbreak()
        line
    }
    vspace
}

#title

== #setcase[Education]
#tightline()
#cvblock(
    title: [Doctor of Philosophy in Aerospace Engineering and Scientific Computing],
    date: [September 2023],
    loc: [University of Michigan, Ann Arbor, MI, USA],
    extras: (
        [_Dissertation: Modeling Anomalous Electron Transport in a Fluid Hall Thruster Code_],
        [_Advisor:_ Professor Benjamin Jorns],
    )
)

#cvblock(
    title: [Bachelor of Science in Aerospace Engineering],
    date: [May 2018],
    loc: [Texas A&M University, College Station, TX, USA],
    extras: ([_Magna cum laude_],)
)

== #setcase[Research Experience]
#tightline()
#cvblock(
    title: [Postdoctoral Research Fellow],
    date: [October 2023--Present],
    loc: [Department of Aerospace Engineering, University of Michigan (remote)],
    extras: (
        [_Supervisor:_ Professor Alex Gorodetsky],
        grid(
            columns: (3.3fr, 1fr),
            [
            - Applying high-performance, GPU-accelerated computing to kinetic simulations of low-temperature plasma devices. 
            - Developing predictive engineering models of Hall thrusters as part of the NASA's Joint Advanced Propulsion Institute (JANUS). 
            - Pursuing tensor-based data-compression methods for kinetic plasma simulations.
            ],
            []
    ))
)

#cvblock(
    title: [Graduate Student Research Assistant],
    date: [2018--2023],
    loc: [Department of Aerospace Engineering, University of Michigan],
    extras: (
       [_Advisor:_ Professor Benjamin Jorns], [
        - Simulated plasma expansion in magnetic nozzles.
        - Assisted in high-power Hall thruster design and testing.
        - Wrote one-dimensional open-source Hall thruster code _HallThruster.jl._
        - Developed and tested models for Hall thruster anomalous electron transport.
        ]
    )
)

#cvblock(
    title: [Intern],
    date: [June--August 2020],
    loc: [Jet Propulsion Laboratory, Pasadena, California (remote)],
    extras: (
        [_Supervisor:_ Dr. Alejandro Lopez Ortega], [
        - Modified Hall thruster code Hall2De to simulate magnetic nozzles.
        - Assessed role of instability-induced transport in magnetic nozzle electron dynamics.
        ]
    )
)

#cvblock(
    title: [Undergraduate Research Assistant],
    date: [2017--2018],
    loc: [Department of Aerospace Engineering, Texas A&M University],
    extras: (
        [_Advisor:_ Professor Christopher Limbach], 
        [
        - Aligned Nd-YAG laser for use in laser-induced fluorescence (LIF) experiments.
        - Assembled and aligned infrared dye laser for use in LIF experiments.
        - Performed LIF of xenon-helium glow discharge to probe metastable Xe density.
        ],
        vspace,
        [_Advisor:_ Professor Kentaro Hara], 
        [
        - Wrote numerical model of electrostatic potential at plasma-liquid interface.
        - Assessed depth of charge penetration into liquid to evaluate plasma medicine concept.
        ]
    )
)

== #setcase[Teaching experience]
#tightline()
#cvblock(
    title: [Graduate Student Instructor],
    date: [January--May 2021],
    loc: [Department of Aerospace Engineering, University of Michigan],
    extras :(
        [AEROSP 335: _Aerospace Propulsion_],
        [
        - Wrote weekly homework assignments for third-year aerospace students
        - Graded exams and hosted weekly office hours.
        ]
    )
)

#cvblock(
    title: [Teaching Assistant],
    date: [2016--2017],
    loc: [Department of International Studies, Texas A&M University],
    extras: (
        [GERM 101: _Beginning German I_ & GERM 102: _Beginning German II_],
        [
        - Taught biweekly classes to first-year students.
        - Tutored students in German twice/week outside of class.
        ]
    )
)

== #setcase[Skills]
#tightline()
- *Numerical methods:* Particle and fluid methods for PDEs, Bayesian inference, and Monte Carlo methods.

- *Experimental techniques:* Hall thruster operation, plasma probe construction, laser system setup and alignment. Analysis of common plasma diagnostics.

- *Software:* Linux, MacOS, Windows. High-performance computing on SLURM clusters. LaTeX, Typst, Microsoft Office.

- *Programming languages:* Julia, C, C++, CUDA, Python, Fortran, MATLAB, Javascript, various shader languages.

- *Human languages:* English (native), German (intermediate).
#vspace

== #setcase[Honors and Awards]
#tightline()
#cvblock(
    title: [Best Paper in Session],
    date: [June 2024],
    loc: [2024 International Electric Propulsion Conference. Toulouse, France.],
    extras: (
        indentedblock[T.\;A. Marks and A.\;A. Gorodetsky, _Hall thruster simulations in WarpX._],
    )
)

#cvblock(
    title: [Best Paper: Electric Propulsion],
    date: [January 2023],
    loc: [2023 AIAA SciTech Forum. National Harbor, MD.],
    extras: (
        indentedblock[L.\;L. Su et al. _Operation and Performance of a Magnetically Shielded Hall thruster at Ultrahigh Current Densities on Xenon and Krypton._],
    )
)

#cvblock(
    title: [Best Paper: Electric Propulsion],
    date: [2020],
    loc: [2020 AIAA Propulsion and Energy Forum. Remote.],
    extras: (
        indentedblock[B.\;A. Jorns, T.\;A. Marks, and E.\;T. Dale. _A Predictive Hall Thruster Model Enabled by Data-Driven Closure._],
    )
)

== #setcase[Journal Publications]
#tightline()
- Eckels, J.\;D., *Marks, T.*\|*A.,* Allen, M.\;G., Jorns, B.\;A., & Gorodetsky, A.\;A. (2024). _Hall thruster model improvement by multidisciplinary uncertainty quantification_. Journal of Electric Propulsion, 3(19).
- Su, L.\;L., *Marks, T.*\|*A.,* & Jorns, B.\;A. (2024). _Trends in mass utilization of a magnetically shielded hall thruster operating on xenon and krypton_. Plasma Sources Science and Technology, 33(6), 065008.
- Su, L.\;L., Roberts, P.\;J., Gill, T.\;M., Hurley, W.\;J., *Marks, T.*\|*A.,* Sercel, C.\;L, Allen, M.\;G., Whittaker, C.\;B., Viges, E. and Jorns, B. A. (2024). _High-current density performance of a magnetically shielded Hall thruster._ Journal of Propulsion and Power, 1-18.
- *Marks, T.*\|*A.* & Jorns, B.\;A. (2023). _Evaluation of algebraic models of anomalous transport in a multi-fluid Hall thruster code._ Journal of Applied Physics, 134(15), 153301.
- *Marks, T.*\|*A.* & Jorns, B.\;A. (2023). _Challenges with the self-consistent implementation of closure models for anomalous electron transport in fluid simulations of Hall thrusters._ Plasma Sources Science and Technology, 32 (4), 0450516.
- *Marks, T.*\|*A.,* Schedler, P. & Jorns, B.\;A. (2023). _HallThruster.jl: A Julia package for 1D Hall thruster discharge simulation_. Journal of Open Source Software, 8 (86), 4672.
#vspace

== #setcase[Conference Publications]
#tightline()
- *Marks, T.*\|*A.* & Gorodetsky, A.\;A. (2024). _HallThruster simulations in WarpX_. 38th International Electric Propulsion Conference, Toulouse, France. \#409. 
- Eckels, J.\;D., *Marks, T.*\|*A.*, Aksoy, D., Vutukury, S., & Gorodetsky, A.\;A. (2024). _Dynamic mode decomposition for particle-in-cell simulations of a Hall thruster and plume._ 38th International Electric Propulsion Conference, Toulouse, France. \#412.
- Aksoy, D., Vutukury, S., *Marks, T.*\|*A.*, Eckels, J.\;D. & Gorodetsky, A.\;A. (2024). _Compressed analysis of electric propulsion simulations using low-rank tensor networks._ 38th international Electric Propulsion Conference, Toulouse, France. \# 795.
- Lipscomb, C.\;P., Stasiukevicius, M.\;J., Boyd, I.\;D., Hansson, K.\;B., *Marks, T.*\|*A.*, Brick, D.\;G., & Jorns, B. A. (2024). _Evaluation of H9 Hall thruster plume simulations using coupled thruster and facility models._ 38th International Electric Propulsion Conference, Toulouse, France. \#483.
- Allen, M.\;G., *Marks, T.*\|*A.*, Eckels, J.\;D., Gorodetsky, A.\;A., & Jorns, B.\;A. (2024). _Optimal Experimental Design for Interring Anomalous Electron Transport in a Hall thruster._ AIAA SciTech 2024 Forum, Orlando, FL, USA. \#2164.
- *Marks, T.*\|*A.* & Jorns, B.\;A. (2023). _Evaluation of several first-principles closure models for Hall thruster anomalous transport._ AIAA SciTech 2023 Forum, National Harbor, MD, USA. \#0067.
- Su, L.\;L., Roberts, P.\;J., Gill, T.\;M. Hurley, W.\;J., *Marks, T.*\|*A.*, Sercel, C.\;L., Allen, M.\;G., Whittaker, C.\;B., Byrne, M., Brown, Z., Viges, E. and Jorns, B.\;A. (2023). _Operation and performance of a magnetically-shielded Hall thruster at ultrahigh current densities on xenon and krypton._ AIAA Scitech 2023 Forum, National Harbor, MD, USA. \#0842.
- Hurley, W.\;J., *Marks, T.*\|*A.*, & Jorns, B.\;A. (2023). _Design of an air-core circuit for a Hall thruster_. AIAA SciTech 2023 Forum, National Harbor, MD, USA. \#0841.
- *Marks, T.*\|*A.* & Jorns, B.\;A. (2022). _Modeling anomalous electron transport in Hall thrusters using surrogate methods._ 38th International Electric Propulsion Conference, Boston, MA, USA. \#344. 
- Su, L.\;L., *Marks, T.*\|*A.*, & Jorns, B.\;A. (2022). _Investigation into the efficiency gap between krypton and xenon operation on a magnetically shielded Hall thruster._ 38th International Electric Propulsion Conference, Boston, MA, USA.
- Hurley, W.\;J., *Marks, T.*\|*A.*, Gorodetsky, A.\;A. & Jorns, B.\;A. (2022)._ Application of Bayesian inference to develop an air-core magnetic circuit for a magnetically shielded Hall thruster._ 38th International Electric Propulsion Conference, Boston, MA, USA.
- *Marks, T.*\|*A.*, Lopez Ortega, A., Mikellides, I.\;G., & Jorns, B.\;A. (2021). _Self-consistent implementation of a zero-equation transport model into a predictive model for a Hall effect thruster._ AIAA Propulsion and Energy 2021 Forum, Remote. \#3424.
- *Marks, T.*\|*A.*, Lopez Ortega, A., Mikellides, I.\;G., & Jorns, B.\;A. (2020). _Hall2De simulations of a magnetic nozzle._ AIAA Propulsion and Energy 2020 Forum, Remote. \#3642.
- Jorns, B.\;A., *Marks, T.*\|*A.*, & Dale, E.\;T. (2020). _A predictive Hall thruster model enabled by data-driven closure._ AIAA Propulsion and Energy 2020 Forum, Remote. \#3622.

