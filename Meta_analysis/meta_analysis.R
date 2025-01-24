setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(groundhog)
pkgs = c("tidyverse", "meta", "readr", "grid")
groundhog.library(pkgs, "2024-06-25") 

pipelines = c("Original", "OriginalWithEimer", "ICA", "Resample", "ICA+Resample")
for (pipeline in pipelines){
  if (pipeline == "OriginalWithEimer") {
    data = read.csv("./effect_sizes_Original.csv")
    results = read.csv("results_R_Original.csv")
  } else {
    data = read.csv(sprintf("./effect_sizes_%s.csv", pipeline))
    results = read.csv(sprintf("results_R_%s.csv", pipeline))
  }
  conditions = c("colors", "forms", "interaction")
  if (pipeline == "Resample"){
    pipe = "Collapsed Localizer"
  } else if (pipeline == "ICA+Resample"){
    pipe = "ICA & Collapsed Localizer"
  } else if (pipeline == "Original") {
    data = data[data$Lab != "Eimer", ] 
    pipe = pipeline
  }  else if (pipeline == "OriginalWithEimer") {
    pipe = "Original"
  } else {
    pipe = pipeline
  }
  
  if (pipeline == "OriginalWithEimer"){
    teams = c("Auckland", "Essex", "GenevaKerzel", "GenevaKliegel", "Gent", "ZJU", "Hildesheim", "ItierLab", "KHas", "Krakow", "LSU", "Magdeburg", "Malaga", "Munich", "NCC_UGR", "Neuruppin", "Onera", "TrierCogPsy", "TrierKamp", "UNIMORE", "UniversityofVienna", "Verona", "Eimer")
  } else {
    teams = c("Auckland", "Essex", "GenevaKerzel", "GenevaKliegel", "Gent", "ZJU", "Hildesheim", "ItierLab", "KHas", "Krakow", "LSU", "Magdeburg", "Malaga", "Munich", "NCC_UGR", "Neuruppin", "Onera", "TrierCogPsy", "TrierKamp", "UNIMORE", "UniversityofVienna", "Verona")
  }
  
  df = data$df
  
  for (condition in conditions){
    
    if (condition == "colors"){
      es = data$ES_colors
      se = data$SE_colors
      low_ci = data$lower_color
      high_ci = data$upper_color
      title = "Colors Contra vs. Ipsi"
      leftlab = sprintf("''%s'' pipeline \U2012 Colors Contra vs. Ipsi", pipe)
    } else if (condition == "forms"){
      es = data$ES_forms
      low_ci = data$lower_forms
      high_ci = data$upper_forms
      se = data$SE_forms
      title = "Forms Contra vs. Ipsi"
      leftlab = sprintf("''%s'' pipeline \U2012 Forms Contra vs. Ipsi", pipe)
    } else if (condition == "interaction"){
      es = data$ES_interaction
      low_ci = data$lower_interaction
      high_ci = data$upper_interaction
      se = data$SE_interaction
      title = "Forms vs. Colors"
      leftlab = sprintf("''%s'' pipeline \U2012 Forms vs. Colors", pipe)
    }
    meta_cond = metagen(TE = es,
                        seTE = se,
                        df = df,
                        lower=low_ci,
                        upper=high_ci,
                        level.ci=0.98,
                        studlab = Lab,
                        data = data,
                        sm = "SMD",
                        common = FALSE,
                        random = TRUE,
                        method.tau = "REML",
                        hakn = TRUE,
                        prediction = TRUE,
                        title = title,
                        level = 0.98,
                        level.ma=0.98,
                        level.predict=0.98,
                        level.comb=0.98,
    )
    
    weighted_ES = meta_cond$TE * (meta_cond$w.random / sum(meta_cond$w.random))
    df_ES = data.frame(teams, weighted_ES)
    for (team in teams){
      if (team != "Eimer") {
        results[results$Lab == team & results$Condition == condition, ]$wgz = sprintf("%.3f", df_ES[df_ES$teams == team, ]$weighted_ES)
        results[results$Lab == team & results$Condition == condition, ]$pval_meta = meta_cond$pval.random
        results[results$Lab == team & results$Condition == condition, ]$tval_meta = meta_cond$statistic.random
      }
    }
    meta_cond$weighted_ES = weighted_ES
    meta_cond$lower = low_ci
    meta_cond$upper = high_ci
    summary(meta_cond)
    pdf(width=9.5, height=6.6, file=sprintf("./forest_%s_%s.pdf", condition, pipeline))
    forest(meta_cond,
           sortvar=-TE,
           title=leftlab,
           prediction = TRUE, 
           print.tau2 = TRUE,
           header.line="",
           leftcols = c("studlab", "weighted_ES"),
           leftlabs = c("Lab", expression("Weighted"~italic("g")["z"])),
           rightlabs = c(expression(italic("g")["z"]), expression("98%"~italic("CI")), "Weight"),
    )
    grid.text(leftlab, .5, .975, gp=gpar(cex=1, fontface="bold"))
    dev.off()
  }
  write_csv(results, sprintf("results_R_%s.csv", pipeline))
}
