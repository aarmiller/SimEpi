Week 4 Assignment - functions & iteration
================
Due 2/25/2021

``` r
library(tidyverse)
library(lubridate)
```

# Write some functions

For this assignment you will be writing a series of functions and
operations that involve iteration.

### Check for odd values

Write a function `is.odd()` that checks if a value is even or odd. If it
is odd, the function should return `TRUE` and if even it should return
`FALSE`. You should also make this function vectorized so it behaves
like the following:

``` r
is.odd(1)
```

    ## [1] TRUE

``` r
is.odd(c(4,4,3))
```

    ## [1] FALSE FALSE  TRUE

Using the function you just wrote, create another function called
`separate_odd_even(x)` that takes a vector of values `x` and separates
them into a list containing two vectors one containing the odd values
and one containing the even values. Your function should behave like
like the following:

``` r
separate_odd_even(1:100)
```

    ## $odd
    ##  [1]  1  3  5  7  9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49
    ## [26] 51 53 55 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99
    ## 
    ## $even
    ##  [1]   2   4   6   8  10  12  14  16  18  20  22  24  26  28  30  32  34  36  38
    ## [20]  40  42  44  46  48  50  52  54  56  58  60  62  64  66  68  70  72  74  76
    ## [39]  78  80  82  84  86  88  90  92  94  96  98 100

### Return prime numbers

Create a function that allows someone to enter a positive number &gt;1
and then return all the prime numbers prior to that value. This function
should also work for values &lt;=1, by returning a value of `FALSE`

Start by creating a test function that determines if a given value is
prime or not; call this function`is.prime()`. Here are examples of how
that function should behave. Note: You can use a loop (or some other
iteration) to do this, but this can also be done using simple vectorized
operations in R.

``` r
is.prime(2)
```

    ## [1] TRUE

``` r
is.prime(5)
```

    ## [1] TRUE

``` r
is.prime(10)
```

    ## [1] FALSE

Next write the final function `find_all_primes(x)` that finds all the
prime numbers ≤ `x`. This function should call the above `is.prime()`
function to check if a number is prime. Here is how the function should
behave:

``` r
find_all_primes(1000)
```

    ##   [1]   2   3   5   7  11  13  17  19  23  29  31  37  41  43  47  53  59  61
    ##  [19]  67  71  73  79  83  89  97 101 103 107 109 113 127 131 137 139 149 151
    ##  [37] 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 241 251
    ##  [55] 257 263 269 271 277 281 283 293 307 311 313 317 331 337 347 349 353 359
    ##  [73] 367 373 379 383 389 397 401 409 419 421 431 433 439 443 449 457 461 463
    ##  [91] 467 479 487 491 499 503 509 521 523 541 547 557 563 569 571 577 587 593
    ## [109] 599 601 607 613 617 619 631 641 643 647 653 659 661 673 677 683 691 701
    ## [127] 709 719 727 733 739 743 751 757 761 769 773 787 797 809 811 821 823 827
    ## [145] 829 839 853 857 859 863 877 881 883 887 907 911 919 929 937 941 947 953
    ## [163] 967 971 977 983 991 997

### Make indicators

Go back to the NHDS adult dataset. Create a function that creates an
indicator of all individuals that have any one of a set of icd-9 codes
for their primary diagnosis. This function should take three arguments:
(1) a dataset (containing icd9 data for primary diagnosis), (2) a vector
of icd-9 codes to create an indicator for and (3) a name to assign the
indicator column that gets created. Call the function
`add_indicators()`.

Start by loading the NHDS to work with:

Your function should then allow you to add indicators as a new column.
Here is an example where we create an indicator for *C. difficile
infection* (CDI):

``` r
nhds_adult %>% 
  add_indicators(dx_codes = c("00845"), name = "cdi")
```

    ## # A tibble: 129,242 x 40
    ##    age_years sex   race  marital_status dc_month dc_status care_days region
    ##        <int> <fct> <fct> <fct>             <int> <fct>         <int> <fct> 
    ##  1        19 fema… white not_stated            2 home              7 west  
    ##  2        20 fema… black single                8 home              1 midwe…
    ##  3        44 fema… black not_stated            8 home              1 north…
    ##  4        80 fema… not_… not_stated           10 home              3 north…
    ##  5        66 male  white not_stated            6 short_te…         1 north…
    ##  6        52 fema… white not_stated            5 alive_NOS         8 south 
    ##  7        76 fema… white widowed              11 home             19 south 
    ##  8        58 fema… white widowed              12 alive_NOS         7 north…
    ##  9        78 fema… asian divorced              2 home             15 south 
    ## 10        33 fema… white not_stated            9 home              1 north…
    ## # … with 129,232 more rows, and 32 more variables: n_beds <ord>,
    ## #   hospital_ownership <fct>, dx01 <icd9cm>, dx02 <icd9cm>, dx03 <icd9cm>,
    ## #   dx04 <icd9cm>, dx05 <icd9cm>, dx06 <icd9cm>, dx07 <icd9cm>, dx08 <icd9cm>,
    ## #   dx09 <icd9cm>, dx10 <icd9cm>, dx11 <icd9cm>, dx12 <icd9cm>, dx13 <icd9cm>,
    ## #   dx14 <icd9cm>, dx15 <icd9cm>, pc01 <icd9cm_p>, pc02 <icd9cm_p>,
    ## #   pc03 <icd9cm_p>, pc04 <icd9cm_p>, pc05 <icd9cm_p>, pc06 <icd9cm_p>,
    ## #   pc07 <icd9cm_p>, pc08 <icd9cm_p>, payor_primary <fct>,
    ## #   payor_secondary <fct>, DRG <chr>, adm_type <fct>, adm_origin <fct>,
    ## #   dx_adm <icd9cm>, cdi <lgl>

Your code should also allow you to create indicators based on a vector
of ICD-9 codes. For example, here we create an indicator for AMI, then
count how many patients had an AMI.

``` r
library(icd)
ami_codes <- children("410")

nhds_adult %>% 
  add_indicators(dx_codes = ami_codes, name = "ami") %>% 
  count(ami)
```

    ## # A tibble: 2 x 2
    ##   ami        n
    ## * <lgl>  <int>
    ## 1 FALSE 126588
    ## 2 TRUE    2654

### Indicators based on multiple diagnosis locations

Next update the function so that you can specify which dx values to look
at for example across all diagnosis codes or just the principal code,
etc. To do this add an argument `dx_num` that takes a vector of integers
between 1-15 and then looks for codes in those positions. For example,
setting `dx_num=1` would look only at the principal diagnosis, whereas
`dx_num=2:15` would look at all secondary (non-principal) diagnoses.
Hint: try out the function `str_pad(1:3,width = 2,pad = "0")`

Here is an example of how you might use the code twice to first create
indicators for primary CDI (based on principal diagnosis) and secondary
CDI, then count the number of cases of CDI. This tells us that 374
people had CDI as a primary diagnosis, 774 as a secondary diagnosis, and
128,094 did not have CDI.

``` r
nhds_adult %>% 
  add_indicators(dx_codes = c("00845"),
                 dx_num = 1,
                 name = "primary_cdi") %>% 
  add_indicators(dx_codes = c("00845"),
                 dx_num = 2:15,
                 name = "secondary_cdi") %>% 
  count(primary_cdi,secondary_cdi)
```

    ## # A tibble: 3 x 3
    ##   primary_cdi secondary_cdi      n
    ##   <lgl>       <lgl>          <int>
    ## 1 FALSE       FALSE         128094
    ## 2 FALSE       TRUE             774
    ## 3 TRUE        FALSE            374

### Sample Size and the LLN

This example asks you to evaluate what happens to a sample mean as the
number of observations increases. For the following sample sizes, in the
`sample_sizes` vector below, draw a random sample of that number of
observations from from a normal distribution with mean=0 and sd=1. Then
compute the mean across the sample for each of the sample sizes. For
example, compute the mean for a sample size of 10, 20, 50, 100, and 200.
Note: `rnorm(10)` could be used to draw a sample of 10 random numbers
from a normal with mean 0 and sd 1.

``` r
sample_sizes <- c(10,20,50,100,200)
```

For each of the iteration approaches (i.e., for loop, apply function,
map function) perform this operation.

Next, take one of the iteration approaches you wrote and turn it into a
function that takes as an argument a vector of sample sizes, and returns
the sample mean corresponding to a random draw of each sample size. Call
this function `run_single_trial()` . You should then be able to run this
function using the sample sizes above and get an output that resembles
something like the following. **Note: the way you return your output and
the random mean you compute will differ from mine. I chose to output my
result in a table with a column for the sample size and a column for the
computed mean.**

``` r
run_single_trial(sample_sizes)
```

    ## # A tibble: 5 x 2
    ##   sample_size sample_mean
    ##         <dbl>       <dbl>
    ## 1          10     0.363  
    ## 2          20    -0.0966 
    ## 3          50     0.118  
    ## 4         100     0.0201 
    ## 5         200     0.00875

Next write a function that takes 2 arguments, a vector of sample sizes
and the number of trials to run, and then runs multiple trials using the
`run_single_trial()` . Call this new function `run_trials()`. The output
of this function should return the means computed across multiple trials
for the different sample sizes. Here is an example of output (**Note:
again your output structure may differ from mine)**

``` r
run_trials(sample_sizes,100)
```

    ## # A tibble: 500 x 3
    ##    trial sample_size sample_mean
    ##    <int>       <dbl>       <dbl>
    ##  1     1          10     -0.145 
    ##  2     1          20      0.0992
    ##  3     1          50      0.0247
    ##  4     1         100     -0.136 
    ##  5     1         200     -0.0841
    ##  6     2          10     -0.165 
    ##  7     2          20     -0.326 
    ##  8     2          50     -0.0118
    ##  9     2         100      0.139 
    ## 10     2         200      0.0178
    ## # … with 490 more rows

Finally use the above function to run 1,000 simulation trials of the
various sample sizes. Then compute the probability of obtaining a sample
mean that is &gt;0.3 units away from the true mean of 0 (i.e., a trial
mean that is &gt;0.3 or &lt; -0.3). Your results should be somewhere
around these values:

    ## # A tibble: 5 x 2
    ##   sample_size prob_outside
    ## *       <dbl>        <dbl>
    ## 1          10        0.346
    ## 2          20        0.177
    ## 3          50        0.034
    ## 4         100        0.003
    ## 5         200        0

## Exercises from R4DS

The following questions were copied from Chapter 19 of our textbook
R4DS. You can find additional details in the chapter
[here](https://r4ds.had.co.nz/functions.html). **Note: text in
quotes/italics is taken directly from R4DS.**

#### 19.2.1 - Question 4

*“write your own functions to compute the variance and skewness of a
numeric vector” See
[here](https://r4ds.had.co.nz/functions.html#exercises-50) for the
formulas for variance and skewness."*

#### 19.2.1 - Question 5

*“Write `both_na()`, a function that takes two vectors of the same
length and returns the number of positions that have an `NA` in both
vectors.”*

Here is quick test to check that your function is working correctly:

``` r
a <- c( 1,  2, NA,  4, NA, NA,  7,  8,  9, NA)
b <- c(11, 12, NA, NA, NA, 16, 17, NA, 19, NA)

both_na(a,b)
```

    ## [1] 3

#### 19.3.1 - Question 1

*“Read the source code for each of the following three functions, puzzle
out what they do, and then brainstorm better names.”*

``` r
f1 <- function(string, prefix) {
  substr(string, 1, nchar(prefix)) == prefix
}
f2 <- function(x) {
  if (length(x) <= 1) return(NULL)
  x[-length(x)]
}
f3 <- function(x, y) {
  rep(y, length.out = length(x))
}
```

#### 19.4.4 - Question 2

*“Write a greeting function that says”good morning“,”good afternoon“,
or”good evening“, depending on the time of day. (Hint: use a time
argument that defaults
to [`lubridate::now()`](http://lubridate.tidyverse.org/reference/now.html).
That will make it easier to test your function.)”*

#### 19.4.4 - Question 3

*“Implement a `fizzbuzz` function. It takes a single number as input. If
the number is divisible by three, it returns”fizz“. If it’s divisible by
five it returns”buzz“. If it’s divisible by three and five, it
returns”fizzbuzz“. Otherwise, it returns the number. Make sure you first
write working code before you create the function.”*

#### 21.3.5 - Question 3

Write a function that contains an internal loop that computes and prints
the mean for each column in a data.frame where the given column is a
numeric (double or integer) vector. This question is an extension of
question 3 in R4DS 21.3.5.

Here is an example of how the function should work

``` r
show_means(mtcars)
```

    ## mpg: 20.09062
    ## cyl: 6.1875
    ## disp: 230.7219
    ## hp: 146.6875
    ## drat: 3.596563
    ## wt: 3.21725
    ## qsec: 17.84875
    ## vs: 0.4375
    ## am: 0.40625
    ## gear: 3.6875
    ## carb: 2.8125
