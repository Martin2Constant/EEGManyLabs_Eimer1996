setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(groundhog)
pkgs = c("tidyverse", "meta")
groundhog.library(pkgs, "2024-02-20") 

data = read.csv("./effect_sizes_Original.csv")  
meta_colors = metagen(TE = ES_colors,
                 seTE = SE_colors,
                 studlab = Lab,
                 data = data,
                 sm = "SMD",
                 common = FALSE,
                 random = TRUE,
                 method.tau = "REML",
                 hakn = TRUE,
                 prediction = TRUE,
                 title = "Colors Contra vs. Ipsi")

meta_letters = metagen(TE = ES_letters,
                 seTE = SE_letters,
                 studlab = Lab,
                 data = data,
                 sm = "SMD",
                 common = FALSE,
                 random = TRUE,
                 method.tau = "REML",
                 hakn = TRUE,
                 prediction = TRUE,
                 title = "Letters Contra vs. Ipsi")

meta_interaction = metagen(TE = ES_interaction,
                          seTE = SE_interaction,
                          studlab = Lab,
                          data = data,
                          sm = "SMD",
                          common = FALSE,
                          random = TRUE,
                          method.tau = "REML",
                          hakn = TRUE,
                          prediction = TRUE,
                          title = "Letters vs. Colors")

summary(meta_colors)
summary(meta_letters)
summary(meta_interaction)


forest(meta_colors, 
            prediction = TRUE, 
            print.tau2 = FALSE,
            leftcols = c("studlab", "TE", "seTE", "ci"),
            leftlabs = c("Study – Colors Contra vs. Ipsi", expression(italic("g")["z"]), "SE", "95% CI"),
            rightcols = c("w.random"))

forest(meta_letters, 
            prediction = TRUE, 
            print.tau2 = FALSE,
            leftcols = c("studlab", "TE", "seTE", "ci"),
            leftlabs = c("Study – Letters Contra vs. Ipsi", expression(italic("g")["z"]), "SE", "95% CI"),
            rightcols = c("w.random"))

forest(meta_interaction, 
            prediction = TRUE, 
            print.tau2 = FALSE,
            leftcols = c("studlab", "TE", "seTE", "ci"),
            leftlabs = c("Study – Letters vs. Colors", expression(italic("g")["z"]), "SE", "95% CI"),
            rightcols = c("w.random"))
