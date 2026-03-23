---
pagetitle: SIAM UQ 2026
bibliography: '../assets/bib/references.bib'
csl: '../assets/csl/iop-style.csl'
suppress-bibliography: false
link-citations: true
citations-hover: true
---

# SIAM UQ 2026

## Diffusion models for inverse problems in low temperature plasmas

[Thomas A. Marks](https://www.thomasmarks.space) and [Alex A. Gorodetsky](https://www.alexgorodetsky.com/index.html)
<a href="https://dx.doi.org/10.7302/27333" class="ai ai-doi"></a> [10.7302/27333](https://dx.doi.org/10.7302/27333)

****

_Presented at SIAM Conference on Uncertainty Quantification, March 22--25, 2026._

| <a href="https://www.alexgorodetsky.com/static/papers/marks_2026_generative_field_inversion_crossed_field_ion_source_v1.pdf"  class="icon fa-file-pdf"> Preprint (pdf) </a>
| <a href="https://docs.google.com/presentation/d/13Srd1CYIrd9xRzXxrGyyeNUfr3_wI8zu/edit?usp=sharing&ouid=105276535149914518471&rtpof=true&sd=true" class="icon fa-file-powerpoint"> Slides </a>

## Abstract

A common task across all fields of science and engineering is to predict the inputs of a model or simulation given partial observations of the models outputs.
These "inverse problems" are notoriously difficult to solve.
Classical optimization methods are commonly used but only provide one answer and thus cannot quantify the uncertainty in that answer.
Bayesian inference methods, such as Markov chain Monte Carlo (MCMC), address this need by generating samples from the posterior distribution of the inputs, specified by a likelihood function.
The generated samples can be analyzed to quantify uncertainty in model predictions.
Such methods are robust and widely used, but are difficult to parallelize and have challenges scaling to high dimensions.
To this end, we propose and demonstrate the use of a diffusion model for solving inverse problems in the field of low temperature plasmas.
These models have become extremely widely-used for generative modeling tasks, particularly image generation.
They have also been applied more recently to text generation and the solution of inverse problems in science and engineering.
Specifically, we apply a diffusion model to the task of learning unknown scalar input fields given partial observation of the results of a 1-D fluid simulation of a Hall thruster.
We show that these methods provide a powerful, robust, and fast alternative to traditional Bayesian inference methods.

::: {#figure}
![_Figure 1: Diffusion model architecture](../assets/images/siamuq-2026-model.png)
:::

::: {#figure}
![_Figure 2: Comparison of diffusion model results to MCMC_](../assets/images/siamuq-2026-mcmc.png)
:::
