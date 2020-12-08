
plot_nb_res <- function(m_out) {
  
  toplot_df <- m_out %>%
    gather_draws(`b_.*`, regex=TRUE) %>%
    mean_qi() %>%
    mutate(coef_type = case_when(str_detect(.variable, 'agecat') ~ 'age',
                                 str_detect(.variable, 'ethnicity') ~ 'personal',
                                 str_detect(.variable, 'city') ~ 'city',
                                 str_detect(.variable, 'political_party') ~ 'political',
                                 str_detect(.variable, 'hispanic') ~ 'personal',
                                 str_detect(.variable, 'gender') ~ 'personal',
                                 TRUE ~ 'other'),
           coef_name = case_when(str_detect(.variable, 'agecat') ~ insert_agegp_dash(str_replace(.variable, 'b_agecat', '')),
                                 str_detect(.variable, 'ethnicity') ~   str_replace(.variable, 'b_ethnicity', ''),
                                 str_detect(.variable, 'wave1:') ~   str_replace(.variable, 'b_wave1:city(.*)', 'Wave 1 X \\1'),
                                 str_detect(.variable, 'wave') ~   str_replace(.variable, 'b_wave(\\d)', 'Wave \\1'),
                                 #str_detect(.variable, 'city') ~   str_replace(.variable, 'b_city', ''),
                                 str_detect(.variable, 'political_party') ~ str_to_title(str_replace(.variable, 'b_political_party_coarse(.*)', '\\1')),
                                 str_detect(.variable, 'city') ~   str_replace(.variable, 'b_city(.*)', '\\1'),
                                 str_detect(.variable, 'hhsize') ~   str_replace(.variable, 'b_w_hhsize(.*)', 'HH size: \\1'),
                                 str_detect(.variable, 'gender') ~   str_replace(.variable, 'b_gender', ''),
                                 str_detect(.variable, 'hispanic') ~   str_replace(.variable, 'b_hispanic', 'Hispanic'),
                                 str_detect(.variable, 'hhsize') ~   str_replace(.variable, 'b_hhsize', 'HH Size'),
                                 str_detect(.variable, 'weekday') ~   str_replace(.variable, 
                                                                                  'b_reference_weekdayTRUE', 
                                                                                  'Weekday'),
                                 TRUE ~ str_replace(.variable, 'b_', '')))
  
  coef_plot <- ggplot(
    toplot_df %>%
      filter(coef_name != 'Intercept')
  ) +
    geom_hline(yintercept=0, color='grey') +
    geom_pointrange(aes(x=coef_name,
                        y=.value,
                        ymin=.lower,
                        ymax=.upper)) +
    coord_flip() +
    facet_wrap(coef_type ~ .,
               scales='free_y') +
    #theme(axis.text. = element_text(angle=90, hjust=1)) +
    xlab("") +
    ylab("Estimated coefficient") +
    labs(caption = str_wrap("Omitted categories are 18-24 (age), white (ethnicity), and the national sample (city)", width=35))
  
  return(list(coef_plot=coef_plot, df=toplot_df))
  
}


plot_preds <- function(cur_mod, cur_ylab, cur_conditions=NULL) {
  
  wave_fill  <- scale_fill_brewer(name='Wave', palette='Set2')
  wave_color <- scale_color_brewer(name='Wave', palette='Set2')
  
  sex_fill  <- scale_fill_brewer(name='Gender',  palette='Set1')
  sex_color <- scale_color_brewer(name='Gender', palette='Set1')
  
  ce_hhsize <- conditional_effects(cur_mod, "w_hhsize", conditions=cur_conditions)
  plot_hhsize <- plot(ce_hhsize, plot=FALSE) 
  plot_hhsize <- plot_hhsize[[1]] + 
    expand_limits(y=0) +
    xlab("Household Size") +
    ylab(cur_ylab) +
    wave_color + wave_fill
  
  ce_dow <- conditional_effects(cur_mod, "reference_weekday", conditions=cur_conditions)
  plot_dow <- plot(ce_dow, plot=FALSE) 
  plot_dow <- plot_dow[[1]] + 
    expand_limits(y=0) +
    xlab("Day of Week") +
    ylab(cur_ylab) +
    wave_color + wave_fill 
  
  ce_agesex <- conditional_effects(cur_mod, "agecat_w0:gender", conditions=cur_conditions)
  plot_agesex <- plot(ce_agesex, plot=FALSE) 
  plot_agesex <- plot_agesex[[1]] + 
    expand_limits(y=0) +
    xlab("Age") +
    ylab(cur_ylab) +
    theme(legend.position='bottom') +
    sex_fill + sex_color
  
  ce_citywave <- conditional_effects(cur_mod, "city:wave")
  ce_citywave_toplot <- ce_citywave
  ce_citywave_toplot[[1]] <- ce_citywave_toplot[[1]] %>%
    filter(! (effect2__ == "Philadelphia" & effect1__ == "0")) %>%
    filter(! (effect1__ == "Philadelphia" & effect2__ == "0"))
    
  plot_citywave <- plot(ce_citywave_toplot, plot=FALSE) 
  plot_citywave <- plot_citywave[[1]] + 
    wave_color +
    wave_fill +
    expand_limits(y=0) +
    xlab("City") +
    ylab(cur_ylab) +
    theme(legend.position='bottom') +
    labs(caption="NB: no Wave 0 data were collected in Philadelphia") +
    NULL
  
  ce_raceethwave <- conditional_effects(cur_mod, "race_ethnicity:wave")
  
  # don't want to plot the 'unknown' coefficient, which is based on very few obs, so has large CIs
  # and is not interesting to us
  ce_raceethwave_toplot <- ce_raceethwave
  ce_raceethwave_toplot[[1]] <- ce_raceethwave_toplot[[1]] %>% 
    filter(effect2__ != "(Unknown)") %>%
    filter(effect1__ != "(Unknown)")
  
  plot_raceethwave <- plot(ce_raceethwave_toplot, plot=FALSE) 
  plot_raceethwave <- plot_raceethwave[[1]] + 
    wave_color +
    wave_fill +
    expand_limits(y=0) +
    xlab("Race/Ethnicity") +
    ylab(cur_ylab) +
    theme(legend.position='bottom') +
    NULL
  
  comb_ylim <- range(c(ce_raceethwave_toplot[[1]]$upper__,
                       ce_citywave[[1]]$upper__,
                       ce_agesex[[1]]$upper__,
                       ce_dow[[1]]$upper__,
                       ce_hhsize[[1]]$upper__,
                       0))
  
  design <- "
   12333
   44555
"
  
  comb_plot <- 
    (plot_dow + 
     plot_hhsize +
     (plot_raceethwave & guides(fill=FALSE, color=FALSE)) + 
     plot_agesex + 
     plot_citywave & ylim(0,ceiling(comb_ylim[2]))) +
    plot_layout(design=design) +
    plot_annotation(tag_levels='A') +
    NULL
  
  return(list(comb = comb_plot,
              plot_dow = plot_dow,
              plot_hhsize = plot_hhsize,
              plot_agesex = plot_agesex,
              plot_raceethwave = plot_raceethwave,
              plot_citywave = plot_citywave))
  
}


insert_agegp_dash <- function(x) { paste0(str_sub(x, 1, 2), '-', str_sub(x, 3)) }

## race/ethnicity as one variable
## for coefficient tables
relabel_coefs_table <- function(df, varname) {
  df$.var <- df[[varname]]
  
  return(df %>%
           mutate(coef_type = case_when(str_detect(.var, 'agecat') ~ 'Age',
                                        str_detect(.var, 'gender') ~ 'Gender',
                                        # NB: ethnicity has to come before city; otherwise, this will
                                        # detect 'ethnicity' as containing 'city'
                                        str_detect(.var, 'race_ethnicity') ~ 'Race/Ethnicity',
                                        str_detect(.var, 'city') ~ 'City',
                                        str_detect(.var, 'wave') ~ 'Time',
                                        str_detect(.var, 'weekday') ~ 'Time',
                                        str_detect(.var, 'hhsize') ~ 'Household',
                                        TRUE ~ 'Other'),
                  coef_name = case_when(str_detect(.var, 'agecat') ~ insert_agegp_dash(str_replace(.var, 'agecat_w0', '')),
                                        str_detect(.var, 'race_ethnicityHispanic') ~   str_replace(.var, 'race_ethnicityHispanic', 'Hispanic'),
                                        str_detect(.var, 'race_ethnicityBlack') ~   str_replace(.var, 'race_ethnicityBlack', 'Black, non-Hispanic'),
                                        str_detect(.var, 'race_ethnicityOther') ~   str_replace(.var, 'race_ethnicityOther', 'Other, non-Hispanic'),
                                        str_detect(.var, 'race_ethnicityWhite') ~   str_replace(.var, 'race_ethnicityWhite', 'White, non-Hispanic'),
                                        str_detect(.var, 'race_ethnicityUnknown') ~   str_replace(.var, 'race_ethnicityUnknown', 'Unknown'),
                                        str_detect(.var, 'wave1:') ~   str_replace(.var, 'wave1:city(.*)', 'Wave 1 X \\1'),
                                        str_detect(.var, 'wave') ~   str_replace(.var, 'wave(\\d)', 'Wave \\1'),
                                        str_detect(.var, 'city') ~   str_replace(.var, 'city(.*)', '\\1'),
                                        str_detect(.var, 'genderMale') ~   str_replace(.var, 'genderMale', 'Male'),
                                        str_detect(.var, 'genderFemale') ~   str_replace(.var, 'genderFemale', 'Female'),
                                        #str_detect(.var, 'hhsize') ~   str_replace(.var, 'b_hhsize', 'HH Size'),
                                        str_detect(.var, 'hhsize') ~   str_replace(.var, 'w_hhsize(.*)', 'HH size: \\1'),
                                        str_detect(.var, 'Weekend') ~   str_replace(.var, 
                                                                                    'reference_weekdayWeekend', 
                                                                                    'Weekend'),
                                        str_detect(.var, 'Weekday') ~   str_replace(.var, 
                                                                                    'reference_weekdayWeekday', 
                                                                                    'Weekday'),
                                        TRUE ~ str_replace(.var, 'b_', ''))) %>%
           mutate(coef_name = case_when(str_detect(coef_name, "HH") ~ coef_name,
                                        str_detect(coef_name, ":") ~ str_replace(coef_name, ":", " X "),
                                        TRUE ~ coef_name)) %>%
           # special cases for interactions
           mutate(coef_name = case_when(str_detect(coef_name, "X gender") ~ str_replace(coef_name, "X gender", " X "),
                                        TRUE ~ coef_name)) %>%
           mutate(coef_name = case_when(str_detect(coef_name, "X wave") ~ str_replace(coef_name, "X wave", " X Wave "),
                                        TRUE ~ coef_name)) %>%
           mutate(coef_name = case_when(str_detect(coef_name, "X city") ~ str_replace(coef_name, "X city", " X "),
                                        TRUE ~ coef_name)) %>%
           select(-.var)
  )
}
