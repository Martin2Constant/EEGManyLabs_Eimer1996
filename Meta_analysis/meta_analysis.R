library(tidyverse)  # version 1.3.2
library(meta)  # version 6.2.0

data = read.csv("./effect_sizes.csv")  
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

meta_forms = metagen(TE = ES_forms,
                 seTE = SE_forms,
                 studlab = Lab,
                 data = data,
                 sm = "SMD",
                 common = FALSE,
                 random = TRUE,
                 method.tau = "REML",
                 hakn = TRUE,
                 prediction = TRUE,
                 title = "Forms Contra vs. Ipsi")

meta_comparison = metagen(TE = ES_comparison,
                          seTE = SE_comparison,
                          studlab = Lab,
                          data = data,
                          sm = "SMD",
                          common = FALSE,
                          random = TRUE,
                          method.tau = "REML",
                          hakn = TRUE,
                          prediction = TRUE,
                          title = "Forms vs. Colors")

summary(meta_colors)
summary(meta_forms)
summary(meta_comparison)

forest.meta(meta_colors, 
            prediction = TRUE, 
            print.tau2 = FALSE,
            leftcols = c("studlab", "TE", "seTE", "ci"),
            leftlabs = c("Study – Colors Contra vs. Ipsi", expression(italic("g")["z"]), "SE", "95% CI"),
            rightcols = c("w.random"))

forest.meta(meta_forms, 
            prediction = TRUE, 
            print.tau2 = FALSE,
            leftcols = c("studlab", "TE", "seTE", "ci"),
            leftlabs = c("Study – Forms Contra vs. Ipsi", expression(italic("g")["z"]), "SE", "95% CI"),
            rightcols = c("w.random"))

forest.meta(meta_comparison, 
            prediction = TRUE, 
            print.tau2 = FALSE,
            leftcols = c("studlab", "TE", "seTE", "ci"),
            leftlabs = c("Study – Forms vs. Colors", expression(italic("g")["z"]), "SE", "95% CI"),
            rightcols = c("w.random"))
