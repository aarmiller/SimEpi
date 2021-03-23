Week 9 - Bootstrapping & Resampling Applications
================
Aaron Miller
3/22/2021

## Applications

The following applications use simulation and/or data resampling to
generate effect estimates, perform statistical analyses and/or evaluate
potential biases in study designs. We will go through a number of these
examples in class. Whatever examples we do not cover in class, you are
responsible to complete on your own outside of class. **Note: I will
update this assignment with additional details over the next few class
periods.**

## Example 1: Power calculation for study involving fever surveillance

*Note: This example comes from research projects I have been involved
in. This was also presented as part of the simulation presentation in
the Epi 2 class.*

Suppose we want to conduct a study involving an intervention where we
use smart phones or mobile device sensors to collect information from or
communicate with patients. For example, we might ask participants to
send us health information in real-time then respond if we detect a
potential health risk/threat. Proposing to conduct such a study will
likely require some sort of power calculation. However, such a
calculation may be challenging due not just to the complexity of the
study design or analogical methodology

Consider a study where we distribute thermometers to patients after
surgery and then ask them to send us real-time temperature readings to
monitor for early signs of a surgical site infection. We might use
something like a smart thermometer (that uploads readings to a cloud) or
text messaging to collect readings from a standard thermometer.

This type of intervention is likely to involve a number of complexities
in the data generating process:

1.  Diurnal temperature variation - normal body temperature fluctuates
    over the course of the day in a regular pattern. Depending on when
    participants take their temperature we may get differing results
    based on natural temperature variation

2.  Demographic variation in body temperature - body temperature has
    been shown to vary by age, sex, region and outside temperature. We
    may have some idea about the demographics of our study population
    but this will also depend on who needs surgery when the study is
    performed (we may not be able to focus on a specific type of patient
    population)

3.  Febrile thresholds may vary - in addition to the above factors that
    may cause temperature patterns to fluctuate between individuals and
    over the course of a day, the individual-specific temperature
    threshold that defines a fever may differ between individuals.

4.  User error/variation - depending on how a participant uses the
    thermometer we may get more/less accurate information

5.  Device error - thermometers are likely to produce a degree of
    variation from the true temperature even when used properly

For this problem you will develop a simulation to perform a power
analysis for a hypothetical study the involves the use of remotely
collected temperature readings to monitor for surgical site infections.
Assume we will distribute a thermometer to individuals after surgery and
then collect readings at multiple time points during follow up.

Suppose we first wanted to conduct a pilot study demonstrating the
feasibility of remote monitoring for fever. Assume we can identify which
individuals had a SSI. Our goal of the pilot project would be to
demonstrate the ability to detect a difference in fever reading between
individuals with and without infection. For this example, suppose we
want to use a simple t-test to tell us the difference between
individuals. Note: this is a way oversimplified version of what we would
actually need to to to power an actual intervention study. In reality,
we would be building some sort predictive model to predict who is
febrile, then evaluate the ability of such a model to segregate
infections from non-infections. However, from the standpoint of
designing a pilot study (with the goal of demonstrating feasibility) we
would be focusing on the ability to segment individuals based on
infection status.

For this problem use the dataset `temperature_episodes.RData` to
generate your simulation.

## Example 2: Misclassification in observational study based on genetic screening results

*Note: This example also comes from research projects I have been
personally involved in. This was also presented as part of the
simulation presentation in the Epi 2 class.*

We conducted a study using administrative claims data to evaluate if
carriers of cystic fibrosis were at increased risk for the variety of
conditions that impact individuals with CF. The specific study can be
found [here](https://www.pnas.org/content/117/3/1621). Our hypothesis
was that carriers would be at increased risk for most, or potentially
all, of the same conditions that individuals at but that the level of
risk would be diminished. For our study, we first conducted a literature
review and identified 59 conditions for which individuals with CF were
at increased risk.

To evaluate our study question we conducted a matched-cohort study,
comparing a cohort of CF carriers to a cohort of non-carriers. We build
a study population using the IBM MarketScan commercial claims databases.
To identify carriers of CF we select individuals who have a diagnosis
code for “Cystic fibrosis gene carrier” identified through genetic
screening. We then match each CF carrier to 5 patients not identified to
be a carrier of CF on the basis of age, sex, and enrollment period.
Finally, we compare the incidence of each condition between the two
cohorts. (Note: in the linked study we also compare results with matched
CF/non-CF cohort and a secondary analysis in obligate carriers based on
relation to a newborn child with CF).

Based on the observational nature of this study there were a number of
limitations that might alter our findings. In particular, because we are
not able to confirm the screening or disease diagnoses in the dataset.
To address some of these limitations we conducted the simulation
analyses described below. For this problem you should try to replicate
these analyses.

#### Misclassification bias - undiagnosed cases of CF among carriers

Not all CFTR mutations are detectable by standard/common genetic
screening panels. It is possible that some CF carriers in our data
actually have CF but have one mutations that is un-detectable by common
panels. In other words, they were misclassified as being a CF carrier
because they had a rare mutation of the CFTR gene. If such
misclassification were

To evaluate this hypothesis, we simulated our study under the null
hypothesis (that there is no difference between CF carriers and
non-carriers and instead our results were generated by misclassification
of unidentified patients with CF). Specifically, we re-built our dataset
composed of carriers and non-carriers who were identical (i.e., all
drawn from non-carriers) and then randomly injected misclassification by
including a portion of labelled carriers from among patients who
actually had CF. We evaluated this possibility using two approaches: (1)
by relying on estimate of misclassification rates for standard screening
panels and (2) by computing the misclassification rate that would be
required to reproduce results for each condition.

Try to re-write these simulation analyses using the provided example
datasets.

#### False discovery - multiple comparisons within our matched cohorts

For our study we evaluated 59 different conditions. For each condition
we performed a statistical test comparing the incidence between CF
carriers and non-carriers and reported corresponding confidence
intervals and P-values. One potential problem with this type or analysis
is the repeated evaluation - performing multiple comparisons across
study populations may generate significant findings simply by chance.

Because of the complex nature of our study design and dataset (e.g.,
correlation between multiple conditions/organ systems, differing
enrollment and observation windows) we decided to use a simulation
analysis to compute an “empirical false discovery rate” that we would
expect by performing repeated analyses using our dataset. For this
simulation

## Example 3: Simulating p-value interpretation

Note: This example and the next example were adapted from a prior
publication, I will provide a link to the publication with the solutions
(I recommend against trying to find the link until after you have
attempted the problem yourself)

P-values are frequently misinterpreted in in common parlance and often
even in published literature. Moreover, the assumptions underlying the
p-value are often ignored or not described when they are used. It is not
uncommon to find p-values being reported, even when the statistical
model being applied is not appropriate or assumptions of the model are
violated. A p-value produced from an improper statistical test is often
essentially meaningless. For these and variety of other reasons,
recommendations have been made to avoid reporting of, or reliance on,
p-values in many contexts.

The objective of this simulation is two-fold. First, this simulation
will be used to demonstrate the correct interpretation of the p-value.
Second, this simulation will be used to demonstrate how this
interpretation/calculation fails when the assumptions of the statistical
test are violated.

For this simulation we will assume a simple experimental study with a
binary exposure and binary outcome. Assume that roughly half the
individuals are exposed. Setup the problem and develop a simulation
model to address the two questions described above.

## Example 4: Non-differential misclassification under different scenarios

*Note: This example and the next example were adapted from a prior
publication, I will provide a link to the publication with the solutions
(I recommend against trying to find the link until after you have
attempted the problem yourself)*

In introductory epidemiology courses we often teach students that
non-differential misclassification is typically less of a concern as it
generally biases results toward the null hypotheses in comparison to
differential misclassification in which the direction of the bias is
uncertain. However, this is not always the case. Non-differential
misclassification can result in an expected bias that is both toward or
away from the null hypothesis depending on they context of the
misclassification. Moreover, in any given study the direction of bias
may actually differ from that which is expected.

For this example you will simulate the effect of non-differential
misclassification under the following 4 scenarios:

1.  Misclassification in a binary exposure

2.  Misclassification in a continuous confounder

3.  Misclassification in both exposure and confounder with independent
    errors

4.  Misclassification in both exposure and confounder with dependent
    errors

By comparing across the 4 different scenarios you can demonstrate how
the expected direction of the effect of misclassification can differ
based on the context of the problem. You will also demonstrate how any
individual study can lead to results that differ from that which may be
expected.

Setup the problem under the following assumptions:

## Example 5: Instrumental variable estimation

Often in non-randomized study designs the assumption that an explanatory
variable is uncorrelated with the error term may be violated. As a
consequence, standard statistical models may generate biased effect
estimates when estimating causal effects. For example, in a study where
patients/clinicians can voluntarily choose which treatment they receive,
it may be the case that patients for whom the treatment is more likely
to be successful are more likely to opt to receive the treatment. It may
also be the case that such patients are healthier to begin with. In such
a situation, standard statistical approaches may over-estimate the
treatment effect because of a correlation between treatment assignment
and the error term.

An approach to deal with this problem, which was developed in
econometrics but has grown in popularity within epidemiology, is
“instrumental variable estimation.” In this approach, an *instrumental
variable*, if a good one can be obtained, substituted into the
statistical problem in a way that can be used to produced unbiased
effect estimates. Thus, in order to utilize an instrumental variable
estimation approach one need to find a proper instrumental variable. A
good instrumental variable can be defined to satisfy two conditions:

1.  The IV is correlated with the endogenous (problematic) explanatory
    variable of interest

2.  The IV is not correlated with the error term (or alternatively the
    instrument is only correlated with the outcome of interest via the
    endogenous explanatory term)

If a proper instrument can be identified, causal effect estimates may be
produced using an IV estimation approach such as two-stage least squares
(2SLS).

For this example, you will setup a hypothetical example with an
endogenous treatment variable. You will then demonstrate how standard
statistical estimators (e.g., OLS regression) produce biased effect
estimates. Finally, you will demonstrate how the 2SLS IV estimator can
produce correct estimates.
