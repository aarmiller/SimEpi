

### This function takes a nested dataset (data) then draws a random sample from 
### the column non_carriers based on the value in the column draw_num
draw_non_carriers <- function(data, replace = TRUE){
  data %>% 
    mutate(controls = map2(non_carriers,draw_num,
                           ~sample(x = .x$id, size = .y, replace = replace)))
}


### Compute standard odds ratios...this function manually computes the simple
### odds ratios for each condition
compute_odds_ratios <- function(data){
  
  case_count <- sum(data$case==1)
  control_count <- sum(data$case==0)
  
  data %>% 
    summarise_at(vars(-id,-case,-strata),funs((sum(case==1 & .==1)/
                                                 (case_count-sum(case==1 & .==1)))/
                                                (sum(case==0 & .==1)/
                                                   (control_count-sum(case==0 & .==1)))))
}

### another approach to return odds ratio and p-value
compute_odds_ratios2 <- function(data){
  
  temp_func <- function(cond_name){
    tmp_data <- data[c("case",cond_name)] 
    
    names(tmp_data) <- c("case","cond")
    
    tmp <- tmp_data %>% 
      count(case,cond) %>% 
      pivot_wider(names_from = cond,values_from = n) %>% 
      select(`0`,`1`) %>% 
      as.matrix() %>% 
      epitools::oddsratio.wald()
    
    tibble(or = tmp$measure[2,1],
           p_val = tmp$p.value[2,2])
  }
  
  res <- tibble(name = data %>% 
                  select(-strata,-id,-case) %>% 
                  names()) %>% 
    mutate(est=map(name,~temp_func(.))) %>% 
    unnest(est)
  
  return(res)
  
}

temp_func

# Get paired odds ratios using conditional logistic regression...this function 
# computes the paired odds ratio using conditional logistic regression to account
# for stratification from matching...note the details of this model/function are 
# beyond the scope of this course...but notes are provided.
get_paired_or <- function(data){
  
  # a temporary function to run the conditional logit model for a given condition
  temp_func <- function(var_name) {
    # rename the variable in the dataset to "cond_ind" for running model below
    in_data <- data %>% 
      rename(cond_ind := !!var_name)
    
    # run conditional logistic regression model...not tryCatch will retun NA in the case
    # that the model breaks (e.g., we draw no outcome cases)
    temp_mod <- tryCatch(survival::clogit(cond_ind ~ case + strata(strata), data=in_data),
                         warning = function(w) {NA},
                         error = function(e) {NA})
    
    # return model odds ratio...again tryCatch helps avoid errors
    mod_or <- tryCatch(exp(coef(temp_mod)[[1]]),
                       warning = function(w) {NA},
                       error = function(e) {NA})
    
    # return model p-value
    mod_or_p <- tryCatch(coef(summary(temp_mod))[,5],
                         warning = function(w) {NA},
                         error = function(e) {NA})
    
    # retun the paired odds ratio and the corresponding p_val
    out <- tibble(or=mod_or,
                  p_val=mod_or_p)
    
    return(out)
  }
  
  # loop over the different conditions 
  res <- original_results %>% 
    select(name) %>% 
    mutate(est=map(name,~temp_func(.))) %>% 
    unnest(est)
  
  return(res)
}
