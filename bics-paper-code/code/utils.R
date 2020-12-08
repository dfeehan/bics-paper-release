# function to get polymod contact matrix based on country and age groupings
getPolymodMatrix <- function(polymod_country = "United Kingdom",
                             polymod_age_limits = c(0, 18, 25, 35, 45, 55,  65)){
  #need the socialmixr package loaded
  data(polymod)
  poly <- socialmixr::contact_matrix(polymod, 
                                     countries = polymod_country, 
                                     age.limits = polymod_age_limits, symmetric = TRUE)
  polymod_mat <- poly$matr
  dimnames(polymod_mat)[[1]] <- dimnames(polymod_mat)[[2]]
  return(polymod_mat)
}
  


# function to get polymod contact matrix , with school contacts dropped, based on country and age groupings

getPolymodMatrixNoSchool <- function(polymod_country = "United Kingdom",
                             polymod_age_limits = c(0, 18, 25, 35, 45, 55,  65)){
  #need the socialmixr package loaded
  data(polymod)
  data_part <- polymod$participants
  data_cnt <- polymod$contacts %>% filter(cnt_school == 0)
  
  poly_no_school <- socialmixr::contact_matrix(survey(data_part, data_cnt), 
                                               countries = polymod_country, 
                                               age.limits = polymod_age_limits, symmetric = TRUE)
  polymod_no_school_mat <- poly_no_school$matrix
  dimnames(polymod_no_school_mat)[[1]] <- dimnames(polymod_no_school_mat)[[2]]
  return(polymod_no_school_mat)
}


# function to fill in the BICS matrix for 
# 1) [0,18) having contacts with all other groups based on symmetry and 
# 2) (0,18] within group contacts from POLYMOD with no school
fill_matrix_BICS <- function(df, age_df, fill_mat) {
  

  
  # 1) fill matrix by assuming reciprocity: total contacts between age group (0,18] and age group i = total contacts between age group i and age group (0,18] (i.e. m_ij w_j = m_ji w_i; c_ij = m_ji w_i / w_j)
  fill_in_matrix <- expand.grid(
    ego_age = unique(df$alter_age)[which(!(unique(df$alter_age) %in% unique(df$ego_age)))], alter_age = unique(df$ego_age)) %>%
    mutate(ego_acs_N = (age_df$acs_tot[1] + age_df$acs_tot[2]) / 1e6) %>% #!fix later (this is hacky)
    left_join(., df %>% mutate(total_contacts=sym_avg_per_ego*ego_acs_N) %>% 
                dplyr::select(ego_age, alter_age, total_contacts), by = c("ego_age" = "alter_age", "alter_age" = "ego_age")) %>%
    mutate(sym_avg_per_ego = total_contacts / ego_acs_N) %>%
    dplyr::select(-total_contacts) %>% as.data.frame()
  
  df_agesex_sym_filled <- df %>%
    full_join(., fill_in_matrix,by =c( "ego_acs_N", "sym_avg_per_ego", "ego_age", "alter_age"))
  
  
  
  df_agesex_sym_filled$ego_age <- factor(df_agesex_sym_filled$ego_age, levels = c("[0,18)", "[18,25)",  "[25,35)",
                                                                                  "[35,45)",  "[45,65)",  "[65,100]"))

  
  # 2) BICS contact matrix with contacts within [0,18) age group 
  
  survey_mat <- acast(df_agesex_sym_filled , ego_age~alter_age, value.var = "sym_avg_per_ego")
  
  # get matrix for which we have complete overlap with POLYMOD
  survey_mat_modified <- survey_mat[-1,-1]
  
  
  # get POLYMOD matrix for which we have complete overlap with survey
  polymod_mat_modified <- fill_mat[-1,-1]
  
  #scaling factor
  
  scaling_factor <- max(Re(eigen(survey_mat_modified)$values)) / max(Re(eigen(polymod_mat_modified)$values))
  
  # add to survey matrix
  survey_mat_youngest_added <- survey_mat 
  survey_mat_youngest_added[1,1]  <- fill_mat[1,1]*scaling_factor
  
  return(list(df_agesex_sym_filled = df_agesex_sym_filled, scaling_factor = scaling_factor,
              survey_mat_youngest_added = survey_mat_youngest_added))
  
}




# function to fill in the FB matrix for 
# 1) [0,15) having contacts with all other groups based on symmetry and 
# 2) (0,15] within group contacts from POLYMOD with no school
fill_matrix_FB <- function(df, age_df, fill_mat) {
  
  
  
  # 1) fill matrix by assuming reciprocity: total contacts between age group (0,18] and age group i = total contacts between age group i and age group (0,18] (i.e. m_ij w_j = m_ji w_i; c_ij = m_ji w_i / w_j)
  fill_in_matrix <- expand.grid(
    ego_age = unique(df$alter_age)[which(!(unique(df$alter_age) %in% unique(df$ego_age)))], alter_age = unique(df$ego_age)) %>%
    mutate(ego_acs_N = age_df$acs_tot[1] / 1e6) %>% #!fix later (this is hacky)
    left_join(., df %>% mutate(total_contacts=sym_avg_per_ego*ego_acs_N) %>% 
                dplyr::select(ego_age, alter_age, total_contacts), by = c("ego_age" = "alter_age", "alter_age" = "ego_age")) %>%
    mutate(sym_avg_per_ego = total_contacts / ego_acs_N) %>%
    dplyr::select(-total_contacts) %>% as.data.frame()
  
  df_agesex_sym_filled <- df %>% 
    full_join(., fill_in_matrix,by =c( "ego_acs_N", "sym_avg_per_ego", "ego_age", "alter_age"))
  
  
  df_agesex_sym_filled$ego_age <- factor(df_agesex_sym_filled$ego_age, levels = c("[0,15)", "[15,25)",  "[25,35)",
                                                                                  "[35,45)",  "[45,65)",  "[65,100]"))
  
  
  # 2) BICS contact matrix with contacts within [0,18) age group 
  
  survey_mat <- acast(df_agesex_sym_filled , ego_age~alter_age, value.var = "sym_avg_per_ego")
  
  # get matrix for which we have complete overlap with POLYMOD
  survey_mat_modified <- survey_mat[-1,-1]
  
  
  # get POLYMOD matrix for which we have complete overlap with survey
  polymod_mat_modified <- fill_mat[-1,-1]
  
  #scaling factor
  
  scaling_factor <- max(Re(eigen(survey_mat_modified)$values)) / max(Re(eigen(polymod_mat_modified)$values))
  
  # add to survey matrix
  survey_mat_youngest_added <- survey_mat 
  survey_mat_youngest_added[1,1]  <- fill_mat[1,1]*scaling_factor
  
  return(list(df_agesex_sym_filled = df_agesex_sym_filled, 
              survey_mat_youngest_added = survey_mat_youngest_added))
  
}





# relative R0 given two contact matrices
getRelativeR0 <- function(survey_mat, comparison_mat) {
  survey_eigen <- max(Re(eigen(survey_mat)$values))
  comparison_eigen <- max(Re(eigen(comparison_mat)$values))
  ratio = survey_eigen / comparison_eigen 
  return(ratio)
}

estimateR0 <- function(baselineR0_mean = 2.5, baselineR0_sd = 0.54, relativeR0) {
  baselineR0 <- rnorm(1, mean = baselineR0_mean, sd = baselineR0_sd ) # assume baseline R0 is normally distributed
  R0 <- relativeR0*baselineR0
  return(R0)
}


standardize_RI<-function(vec){return(vec/sum(vec))}

# basic bootstrap CI based on quantiles
# Do something fancier? Studentized bootstrap?
# empirical CI from https://ocw.mit.edu/courses/mathematics/18-05-introduction-to-probability-and-statistics-spring-2014/readings/MIT18_05S14_Reading24.pdf
calc_R0_ci <- function(R0_bootstrapped_est, R0_est) {
  deltastar = R0_bootstrapped_est - R0_est
  d = quantile(deltastar,c(0.025,0.975))
  ci = R0_est - c(d[2], d[1])
  return(ci)
  
}

calc_R0_ci_percentile <- function(R0_bootstrapped_est) {
  ci = quantile(R0_bootstrapped_est,c(0.025,0.975))
  return(ci)
  
}
