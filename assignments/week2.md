Week 2 Assignment - Explore the Synthetic Medicare Data
================
Due 2/9/2021

In this assignment you will load and explore the synthetic Medicare data
posted on the course website. A template script to get you started on
this assignment is posted here. You can find,

``` r
library(tidyverse)
library(icd)
library(lubridate)
```

# Load Data

For this assignment we will be working with the synthetic Medicare data.
This data is a synthetic dataset meant to mimic actual Medicare data.
Additional details on the dataset can be found here. This data is
publicly available and can be used for trial and demonstration purposes;
this allows researches to test our their analysis or code before
applying it to actual data which is subject to numerous security
restrictions.

Start by loading the beneficiary summary data for 2008, 2009 and 2010
along with the inpatient data. Read these in and store them as the
objects named `bene_2008, bene_2009, bene_2010, inpatient`. **Note:** I
have saved my data in my R project directory for this course under
`"SimEpi2021/data/synthetic_medicare/sample1/"`.

## Process the data

#### Beneficiary Data

Create a dataset that contains some of the basic immutable
characteristics of the beneficiaries across all three years of data.
Start by combining (stacking) the three years of beneficiary data. Next,
create a dataset that contains the beneficiary id, sex, race, date of
birth, and state code. Name these variables as:
`bene_id, sex, race, dob, state`. Finally, reduce the dataset down to
just the distinct/unique beneficiary (note: many beneficiaries are
present in multiple years).

Your dataset should look like the following, and you should have 116,352
unique beneficiaries

    ## # A tibble: 116,352 x 5
    ##    bene_id            sex  race      dob state
    ##    <chr>            <dbl> <dbl>    <dbl> <chr>
    ##  1 00013D2EFD8E45D1     1     1 19230501 26   
    ##  2 00016F745862898F     1     1 19430101 39   
    ##  3 0001FDD721E223DC     2     1 19360901 39   
    ##  4 00021CA6FF03E670     1     5 19410601 06   
    ##  5 00024B3D2352D2D0     1     1 19360801 52   
    ##  6 0002DAE1C81CC70D     1     2 19431001 33   
    ##  7 0002F28CE057345B     1     1 19220701 39   
    ##  8 000308435E3E5B76     1     1 19350901 24   
    ##  9 000345A39D4157C9     2     1 19760901 23   
    ## 10 00036A21B65B0206     2     2 19381001 01   
    ## # … with 116,342 more rows

Now, using dplyr verbs cleanup the data so that the variables are more
informative. First, update the sex and race variables to factors with
their corresponding values. Second, add in the labels for the state
abbreviations corresponding to their numeric categories. The dataset
“state\_values.csv” contains values for states and their abbreviations.
Third, using the `ymd()` function from the `lubridate` package convert
the `dob` variable to a date (try running `ymd(19230501)` to see how
this works.

Once you have completed these steps, your `bene_info` data should then
look like the following:

    ## # A tibble: 116,352 x 5
    ##    bene_id          sex    race     dob        state
    ##    <chr>            <fct>  <fct>    <date>     <chr>
    ##  1 00013D2EFD8E45D1 Male   white    1923-05-01 MO   
    ##  2 00016F745862898F Male   white    1943-01-01 PA   
    ##  3 0001FDD721E223DC Female white    1936-09-01 PA   
    ##  4 00021CA6FF03E670 Male   hispanic 1941-06-01 CO   
    ##  5 00024B3D2352D2D0 Male   white    1936-08-01 WI   
    ##  6 0002DAE1C81CC70D Male   black    1943-10-01 NY   
    ##  7 0002F28CE057345B Male   white    1922-07-01 PA   
    ##  8 000308435E3E5B76 Male   white    1935-09-01 MN   
    ##  9 000345A39D4157C9 Female white    1976-09-01 MI   
    ## 10 00036A21B65B0206 Female black    1938-10-01 AL   
    ## # … with 116,342 more rows

#### Inpatient Data

Create another dataset that contains the basic information of the
inpatient claims data. Specifically, create a dataset that contains the
variables for beneficiary ID, inpatient claim ID, payment, admission
date, discharge date, admitting diagnosis code, principal diagnosis (the
first diagnosis code on the claim). Use the following names for these
variables `bene_id, claim_id, payment, adm_date, dis_date, adm_dx, dx1`.
Your inpatient dataset should look like the following:

    ## # A tibble: 66,773 x 7
    ##    bene_id          claim_id        payment adm_date dis_date adm_dx dx1  
    ##    <chr>            <chr>             <dbl>    <dbl>    <dbl> <chr>  <chr>
    ##  1 00013D2EFD8E45D1 196661176988405    4000 20100312 20100313 4580   7802 
    ##  2 00016F745862898F 196201177000368   26000 20090412 20090418 7866   1970 
    ##  3 00016F745862898F 196661177015632    5000 20090831 20090902 6186   6186 
    ##  4 00016F745862898F 196091176981058    5000 20090917 20090920 29590  29623
    ##  5 00016F745862898F 196261176983265   16000 20100626 20100701 5849   3569 
    ##  6 00052705243EA128 196991176971757   14000 20080912 20080912 78079  486  
    ##  7 0007F12A492FD25D 196661176963773    5000 20080919 20080922 78097  33811
    ##  8 0007F12A492FD25D 196821177025734    5000 20100602 20100606 49392  49121
    ##  9 0007F12A492FD25D 196551177025145   14000 20100522 20100612 V5789  V5789
    ## 10 0007F12A492FD25D 196831176966961   29000 20100616 20100619 99641  7366 
    ## # … with 66,763 more rows

Now clean up the data a bit by doing the following. First, create a
length of stary variable named `los` that gives the amount of time the
patient stayed in the hospital. Second, convert the admission and
discharge dates to dates using the `ymd()` function. After completing
these steps your dataset should look like the following:

    ## # A tibble: 66,773 x 8
    ##    bene_id        claim_id      payment adm_date   dis_date   adm_dx dx1     los
    ##    <chr>          <chr>           <dbl> <date>     <date>     <chr>  <chr> <dbl>
    ##  1 00013D2EFD8E4… 196661176988…    4000 2010-03-12 2010-03-13 4580   7802      1
    ##  2 00016F7458628… 196201177000…   26000 2009-04-12 2009-04-18 7866   1970      6
    ##  3 00016F7458628… 196661177015…    5000 2009-08-31 2009-09-02 6186   6186     71
    ##  4 00016F7458628… 196091176981…    5000 2009-09-17 2009-09-20 29590  29623     3
    ##  5 00016F7458628… 196261176983…   16000 2010-06-26 2010-07-01 5849   3569     75
    ##  6 00052705243EA… 196991176971…   14000 2008-09-12 2008-09-12 78079  486       0
    ##  7 0007F12A492FD… 196661176963…    5000 2008-09-19 2008-09-22 78097  33811     3
    ##  8 0007F12A492FD… 196821177025…    5000 2010-06-02 2010-06-06 49392  49121     4
    ##  9 0007F12A492FD… 196551177025…   14000 2010-05-22 2010-06-12 V5789  V5789    90
    ## 10 0007F12A492FD… 196831176966…   29000 2010-06-16 2010-06-19 99641  7366      3
    ## # … with 66,763 more rows

# Some Basic Analysis

### Describe the Medicare Population

Summarize the breakdown of the beneficiaries by sex and race. Compute
both the count breakdown and the fraction of beneficiaries that fall
into each category. Note: your data should look something like this.

    ## # A tibble: 8 x 4
    ##   sex    race         n   pct
    ##   <fct>  <fct>    <int> <dbl>
    ## 1 Female white    53291 45.8 
    ## 2 Female black     6935  5.96
    ## 3 Female other     2649  2.28
    ## 4 Female hispanic  1472  1.27
    ## 5 Male   white    43058 37.0 
    ## 6 Male   black     5408  4.65
    ## 7 Male   other     2282  1.96
    ## 8 Male   hispanic  1257  1.08

Using this above result, try to generate the following table that gives
a population breakdown by race and sex. Note: this might take a few
steps using the current functions we have covered (later we will discuss
reshaping that will make this easier).

    ## # A tibble: 4 x 3
    ##   race     Male           Female       
    ##   <fct>    <chr>          <chr>        
    ## 1 white    43058 (37.01%) 53291 (45.8%)
    ## 2 black    5408 (4.65%)   6935 (5.96%) 
    ## 3 other    2282 (1.96%)   2649 (2.28%) 
    ## 4 hispanic 1257 (1.08%)   1472 (1.27%)

For each state compute the percentage of beneficiaries from that state
that are female. You should have a result that looks like the following:

    ## # A tibble: 52 x 2
    ##    state female_pct
    ##  * <chr>      <dbl>
    ##  1 AK          43.4
    ##  2 AL          52.9
    ##  3 AR          49.5
    ##  4 AZ          53.8
    ##  5 CA          56.5
    ##  6 CO          49.7
    ##  7 CT          55.8
    ##  8 DC          47.1
    ##  9 DE          49.9
    ## 10 FL          55.4
    ## # … with 42 more rows

Use the `arrange()` and `slice()` to find the states with the highest
and lowest percentage of female beneficiaries. Your result should look
like this:

    ## # A tibble: 2 x 2
    ##   state female_pct
    ##   <chr>      <dbl>
    ## 1 WY          41.9
    ## 2 WI          58.8

Now try to do the exact same thing but using only a single filter
statement (note you will need to incorporate a max and min value)

    ## # A tibble: 2 x 2
    ##   state female_pct
    ##   <chr>      <dbl>
    ## 1 WI          58.8
    ## 2 WY          41.9

### Find inpatient visits for AMI

Find all inpatient visits with a primary diagnosis of Acute Myocardial
Infarction using the icd codes “410.XX”. The `children()` function in
the icd package can be used to expand upon a series of codes.

``` r
ami_codes <- children("410")
```

    ## # A tibble: 751 x 8
    ##    bene_id        claim_id      payment adm_date   dis_date   adm_dx dx1     los
    ##    <chr>          <chr>           <dbl> <date>     <date>     <chr>  <chr> <dbl>
    ##  1 00DA910E42BA3… 196601176968…   18000 2009-09-05 2009-09-15 41071  4280     10
    ##  2 0109DE95C1C45… 196481177021…    6000 2010-05-27 2010-05-30 41091  41051     3
    ##  3 0124E58C3460D… 196131176983…    6000 2010-01-09 2010-01-12 41071  41071     3
    ##  4 0133AD95B7A96… 196321177025…    5000 2008-12-08 2008-12-10 41071  41091     2
    ##  5 0137BBB5B93D6… 196941177004…   16000 2009-11-13 2009-11-15 41011  41401     2
    ##  6 01B99FF2F1121… 196531176990…    5000 2008-08-26 2008-08-27 41071  41071     1
    ##  7 022C7819395BE… 196251176978…    2000 2008-02-24 2008-02-25 41071  7295      1
    ##  8 0289ABA0311E4… 196011176959…   57000 2009-08-01 2009-08-15 41071  3962     14
    ##  9 02C96D4BAA0EF… 196191177004…   13000 2008-10-02 2008-10-08 41071  99672     6
    ## 10 02E24F70DEF07… 196171177010…    3000 2008-01-25 2008-01-31 41090  5849      6
    ## # … with 741 more rows

### Compute the monthly incidence of AMI admissions

For this next analysis we are going to compute a monthly incidence of
hospital AMI admissions using our population. To do so we will first
compute the number of AMI admission each month. Next we must obtain a
denominator corresponding to the number of beneficiaries we can observe
each month. Finally, we will compute an incidence rate per 10,000
beneficiaries.

Let’s start by computing the number of ami cases each month (for the
three different years of data we have). You will likely want to use the
`month()` and `year()` functions from the `lubridate` package to extract
the year. You should then get a year and month count of AMI cases that
looks like the following:

    ## # A tibble: 37 x 3
    ##     year month     n
    ##    <dbl> <dbl> <int>
    ##  1  2007    12     1
    ##  2  2008     1    18
    ##  3  2008     2    22
    ##  4  2008     3    32
    ##  5  2008     4    30
    ##  6  2008     5    31
    ##  7  2008     6    25
    ##  8  2008     7    24
    ##  9  2008     8    25
    ## 10  2008     9    22
    ## # … with 27 more rows

Next we need to compute a denominator for each month, specifically the
number of beneficiaries we are able to observe each month in our data.
In order to do so we would need the exact start and stop date when each
beneficiary had Part A (hospital) Medicare coverage; however, we do not
have all this information. As an alternative we will compute the average
number of beneficiaries represented in our data each month for the three
different years. The yearly beneficiary data contains the number of
months each beneficiary had Part A coverage (`BENE_HI_CVRAGE_TOT_MONS`),
we will use this to compute a monthly average across the year.

If we go back to the original beneficiary files we can compute the
average number of beneficiaries each month for 2008-2010 by summing up
the total months of Part A coverage and dividing by 12. This should give
us the following values, respectively. Note I have put this information
into a tibble to prepare for the next step…you should figure out how to
do this.

    ## # A tibble: 3 x 2
    ##    year total_enroll
    ##   <int>        <dbl>
    ## 1  2008      108052.
    ## 2  2009      107119.
    ## 3  2010      105200.

Now we can join these two datasets together to compute the monthly
incidence per 10,000 beneficiaries. You should get something like the
following:

    ## Joining, by = "year"

    ## # A tibble: 36 x 5
    ##     year month     n total_enroll incidence
    ##    <dbl> <dbl> <int>        <dbl>     <dbl>
    ##  1  2008     1    18      108052.      1.67
    ##  2  2008     2    22      108052.      2.04
    ##  3  2008     3    32      108052.      2.96
    ##  4  2008     4    30      108052.      2.78
    ##  5  2008     5    31      108052.      2.87
    ##  6  2008     6    25      108052.      2.31
    ##  7  2008     7    24      108052.      2.22
    ##  8  2008     8    25      108052.      2.31
    ##  9  2008     9    22      108052.      2.04
    ## 10  2008    10    46      108052.      4.26
    ## # … with 26 more rows

### Describe the Age and LOS for patients with AMI

For the inpatient AMI admissions that you found, compute the mean age
(at admission), mean length of stay, mean payment, and percent who were
female. Your results should look like the following:

    ## # A tibble: 1 x 6
    ##   median_age mean_age median_los mean_los mean_pay pct_female
    ##        <dbl>    <dbl>      <dbl>    <dbl>    <dbl>      <dbl>
    ## 1         75     74.3          4     158.   13770.      0.563

Now how does this compare to the inpatient admissions that did not have
an AMI? For the non-AMI patients you should exclude patients where AMI
was either the admitting diagnosis or the principal diagnosis. Start by
finding all inpatient admissions without AMI then use the same commands
as did above.

    ## # A tibble: 1 x 6
    ##   median_age mean_age median_los mean_los mean_pay pct_female
    ##        <dbl>    <dbl>      <dbl>    <dbl>    <dbl>      <dbl>
    ## 1         75     73.7          4     149.    9446.      0.565

### Build a matched case-control study sample

Suppose we want to conduct a study comparing cases of AMI to individuals
who did not have an AMI. Our strategy is to build a matched case-control
using a 1:1 match where each patient who had an AMI is matched to a
patient that did not have an AMI.

In this simple example we will match cases based on age, dob year and
race. Let’s start by computing the number of matches we need to generate
in each strata. To do so count how many ami cases we have for each
corresponding sex, dob year and race. I will store this as an object
`match_strata`

    ## # A tibble: 196 x 4
    ##    sex    dobyr race         n
    ##    <fct>  <dbl> <fct>    <int>
    ##  1 Female  1909 white        3
    ##  2 Female  1909 other        1
    ##  3 Female  1910 white        1
    ##  4 Female  1911 white        2
    ##  5 Female  1912 white        2
    ##  6 Female  1913 white        2
    ##  7 Female  1913 hispanic     1
    ##  8 Female  1914 white        2
    ##  9 Female  1915 white        4
    ## 10 Female  1915 black        1
    ## # … with 186 more rows

Next identify the set of enrollees that did not have an AMI. To do so,
go back and find all patients that had AMI as the admitting or principal
diagnosis. Note this should give you 1,976 beneficiaries with the
following bene\_id’s:

    ## # A tibble: 1,976 x 1
    ##    bene_id         
    ##    <chr>           
    ##  1 0021B3C854C968C8
    ##  2 002A6E193552D760
    ##  3 007C99D466D0E3A6
    ##  4 00C91B5EEA137225
    ##  5 00DA910E42BA3E35
    ##  6 00DA910E42BA3E35
    ##  7 00F7B2371F215D5E
    ##  8 0109DE95C1C45042
    ##  9 0124E58C3460D3F8
    ## 10 0133AD95B7A966DE
    ## # … with 1,966 more rows

Next reduce the set of beneficiaries down to those without an AMI
admission. Select bene\_id, sex, dob year (may need to create this), and
race. Then arrange and group the data by sex, dob year, and race. Using
the helper function `row_number()` create a variable that contains
observation number in a given strata. Note: this count should start back
over at 1 for each new strata.

    ## # A tibble: 114,467 x 5
    ## # Groups:   dobyr, sex, race [598]
    ##    bene_id          sex    dobyr race  obs_number
    ##    <chr>            <fct>  <dbl> <fct>      <int>
    ##  1 00CF414D3C00696D Female  1909 white          1
    ##  2 019E38924283B16A Female  1909 white          2
    ##  3 029DEB0A4ECA8C67 Female  1909 white          3
    ##  4 02C598F9B4F67D40 Female  1909 white          4
    ##  5 037C6C3B3B6113B9 Female  1909 white          5
    ##  6 03A62EA766FB77B1 Female  1909 white          6
    ##  7 03D22C2EE867FA0C Female  1909 white          7
    ##  8 04201C34A6A7780A Female  1909 white          8
    ##  9 049D5E2C94D8C422 Female  1909 white          9
    ## 10 04D15FDEC910AD67 Female  1909 white         10
    ## # … with 114,457 more rows

You now have all the pieces needed to build a set of matched controls.
Figure out how to do so. You resulting matches should look something
like the following:

    ## # A tibble: 751 x 6
    ##    bene_id          sex    dobyr race  obs_number     n
    ##    <chr>            <fct>  <dbl> <fct>      <int> <int>
    ##  1 00CF414D3C00696D Female  1909 white          1     3
    ##  2 019E38924283B16A Female  1909 white          2     3
    ##  3 029DEB0A4ECA8C67 Female  1909 white          3     3
    ##  4 0A69238A6641E39F Female  1909 other          1     1
    ##  5 02590F7BCF2D75F1 Male    1909 white          1     5
    ##  6 03698322C10F30A8 Male    1909 white          2     5
    ##  7 048FF3022D9BBA39 Male    1909 white          3     5
    ##  8 0CD2515E63A7D82F Male    1909 white          4     5
    ##  9 0DEE5ED80C23B601 Male    1909 white          5     5
    ## 10 0152D6726F90EFCF Female  1910 white          1     1
    ## # … with 741 more rows

# Plot Some Trends

(Coming Soon)
