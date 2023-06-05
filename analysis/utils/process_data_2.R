process_data_2 <- function(df, col) {
    df[col] <- df[col] %>% mutate_all(~replace(., is.na(.), 0)) 
    df$total_ab_6w <- rowSums(df[col])
    df$ab_6w <- ifelse(df$total_ab_6w > 0, 1, 0)
    df[col] <- ifelse(df[col] > 0, 1, 0)
    df$ab_types_6w <- rowSums(df[col] > 0)
    df <- df[!names(df) %in% col]
    df$ab_types_6w <- ifelse(is.na(df$ab_types_6w), 0, df$ab_types_6w)

    df$ab_frequency = case_when(
        df$ab_prescriptions == 0 ~ "0",
        df$ab_prescriptions == 1 ~ "1",
        df$ab_prescriptions >1 & df$ab_prescriptions <4 ~ "2-3",
        df$ab_prescriptions > 3 ~ ">3",)

    df$ab_type_num = case_when(
        df$ab_types_6w == 0 ~ "0",
        df$ab_types_6w == 1 ~ "1",
        df$ab_types_6w >1 & df$ab_types_6w <4 ~ "2-3",
        df$ab_types_6w > 3 ~ ">3",)

    ## processing the comor conditions
    comor_conditions <- c("cancer", "cardiovascular", "chronic_obstructive_pulmonary",
                          "heart_failure", "connective_tissue", "dementia", "diabetes",
                          "diabetes_complications", "hemiplegia", "hiv", "metastatic_cancer",
                          "mild_liver", "mod_severe_liver", "mod_severe_renal", "mi",
                          "peptic_ulcer", "peripheral_vascular")

    for(condition in comor_conditions){
        col_name <- paste0(condition, "_comor")
        replace_value <- ifelse(condition %in% c("cancer", "diabetes_complications", "hemiplegia", 
                                                 "hiv", "metastatic_cancer", "mod_severe_liver",
                                                 "mod_severe_renal"), 2, 1)
        df[col_name] <- ifelse(df[col_name] == 1L, replace_value, 0L)
    }
    ## total charlson for each patient 
    charlson=c("cancer_comor","cardiovascular_comor","chronic_obstructive_pulmonary_comor",
                "heart_failure_comor","connective_tissue_comor", "dementia_comor",
                "diabetes_comor","diabetes_complications_comor","hemiplegia_comor",
                "hiv_comor","metastatic_cancer_comor" ,"mild_liver_comor",
                "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor",
                "peptic_ulcer_comor" , "peripheral_vascular_comor" )

    df$charlson_score=rowSums(df[charlson])

    ## Charlson - as a categorical group variable
    df <- df %>%
        mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
                                       charlson_score >2 & charlson_score <=4 ~ 3,
                                       charlson_score >4 & charlson_score <=6 ~ 4,
                                       charlson_score >=7 ~ 5,
                                       charlson_score == 0 ~ 1))

    df$charlsonGrp <- as.factor(df$charlsonGrp)
    df$charlsonGrp <- factor(df$charlsonGrp, 
                             labels = c("zero", "low", "medium", "high", "very high"))
    
    return(df)
}