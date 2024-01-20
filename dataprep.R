library(nhanesA) # Data access
library(dplyr)   # Data manipulation

## Download and translate tables from 2009 to 2017
## Extra columns are dropped in nhanesTranslate()
## except for the BMXBMI table that does not need translation
demo.vars <- c("SEQN", "RIAGENDR", "RIDAGEYR", "RIDRETH1",
               "INDFMPIR", "DMDEDUC2", "WTINT2YR",
               "WTMEC2YR", "SDMVPSU", "SDMVSTRA")
demo.names <- c("id", "gender", "age", "ethnicity",
                "poverty", "education", "wt.int",
                "wt.mec", "PSU", "strata")

ast.vars <- c("SEQN", "MCQ010", "MCQ035")
ast.names <- c("id", "asthma", "asthma.now")

bmi.vars <- c("SEQN", "BMXBMI")
bmi.names <- c("id", "bmi")

smk.vars <- c("SEQN", "SMQ040")
smk.names <- c("id", "smoke")
dd9 <- nhanes("DEMO_F")
dd9 <- nhanesTranslate("DEMO_F", colnames = demo.vars,
                       data = dd9[,demo.vars])
names(dd9) <- demo.names
dd11 <- nhanes("DEMO_G")
dd11 <- nhanesTranslate("DEMO_G", colnames = demo.vars,
                        data = dd11[,demo.vars])
names(dd11) <- demo.names
dd13 <- nhanes("DEMO_H")
dd13 <- nhanesTranslate("DEMO_H", colnames = demo.vars,
                        data = dd13[,demo.vars])
names(dd13) <- demo.names
dd15 <- nhanes("DEMO_I")
dd15 <- nhanesTranslate("DEMO_I", colnames = demo.vars,
                        data = dd15[,demo.vars])
names(dd15) <- demo.names
dd17 <- nhanes("DEMO_J")
dd17 <- nhanesTranslate("DEMO_J", colnames = demo.vars,
                        data = dd17[,demo.vars])
names(dd17) <- demo.names

ad9 <- nhanes("MCQ_F")
ad9 <- nhanesTranslate("MCQ_F", colnames = ast.vars,
                       data = ad9[,ast.vars])
names(ad9) <- ast.names
ad11 <- nhanes("MCQ_G")
ad11 <- nhanesTranslate("MCQ_G", colnames = ast.vars,
                        data = ad11[,ast.vars])
names(ad11) <- ast.names
ad13 <- nhanes("MCQ_H")
ad13 <- nhanesTranslate("MCQ_H", colnames = ast.vars,
                        data = ad13[,ast.vars])
names(ad13) <- ast.names
ad15 <- nhanes("MCQ_I")
ad15 <- nhanesTranslate("MCQ_I", colnames = ast.vars,
                        data = ad15[,ast.vars])
names(ad15) <- ast.names
ad17 <- nhanes("MCQ_J")
ad17 <- nhanesTranslate("MCQ_J", colnames = ast.vars,
                        data = ad17[,ast.vars])
names(ad17) <- ast.names

ed9 <- nhanes("BMX_F")
ed9 <- ed9 %>% select(all_of(bmi.vars))
names(ed9) <- bmi.names
ed11 <- nhanes("BMX_G")
ed11 <- ed11 %>% select(all_of(bmi.vars))
names(ed11) <- bmi.names
ed13 <- nhanes("BMX_H")
ed13 <- ed13 %>% select(all_of(bmi.vars))
names(ed13) <- bmi.names
ed15 <- nhanes("BMX_I")
ed15 <- ed15 %>% select(all_of(bmi.vars))
names(ed15) <- bmi.names
ed17 <- nhanes("BMX_J")
ed17 <- ed17 %>% select(all_of(bmi.vars))
names(ed17) <- bmi.names

sd9 <- nhanes("SMQ_F")
sd9 <- nhanesTranslate("SMQ_F", colnames = smk.vars,
                       data = sd9[,smk.vars])
names(sd9) <- smk.names
sd11 <- nhanes("SMQ_G")
sd11 <- nhanesTranslate("SMQ_G", colnames = smk.vars,
                        data = sd11[,smk.vars])
names(sd11) <- smk.names
sd13 <- nhanes("SMQ_H")
sd13 <- nhanesTranslate("SMQ_H", colnames = smk.vars,
                        data = sd13[,smk.vars])
names(sd13) <- smk.names
sd15 <- nhanes("SMQ_I")
sd15 <- nhanesTranslate("SMQ_I", colnames = smk.vars,
                        data = sd15[,smk.vars])
names(sd15) <- smk.names
sd17 <- nhanes("SMQ_J")
sd17 <- nhanesTranslate("SMQ_J", colnames = smk.vars,
                        data = sd17[,smk.vars])
names(sd17) <- smk.names

## Merge within survey cycles
## Add year variable
df9 <- merge(dd9, ad9, by = c("id"), all = TRUE)
df9 <- merge(df9, ed9, by = c("id"), all = TRUE)
df9 <- merge(df9, sd9, by = c("id"), all = TRUE)
df9$year <- 2009

df11 <- merge(dd11, ad11, by = c("id"), all = TRUE)
df11 <- merge(df11, ed11, by = c("id"), all = TRUE)
df11 <- merge(df11, sd11, by = c("id"), all = TRUE)
df11$year <- 2011

df13 <- merge(dd13, ad13, by = c("id"), all = TRUE)
df13 <- merge(df13, ed13, by = c("id"), all = TRUE)
df13 <- merge(df13, sd13, by = c("id"), all = TRUE)
df13$year <- 2013

df15 <- merge(dd15, ad15, by = c("id"), all = TRUE)
df15 <- merge(df15, ed15, by = c("id"), all = TRUE)
df15 <- merge(df15, sd15, by = c("id"), all = TRUE)
df15$year <- 2015

df17 <- merge(dd17, ad17, by = c("id"), all = TRUE)
df17 <- merge(df17, ed17, by = c("id"), all = TRUE)
df17 <- merge(df17, sd17, by = c("id"), all = TRUE)
df17$year <- 2017

## Join cycles and adjust weights
## (see https://wwwn.cdc.gov/nchs/nhanes/tutorials/module3.aspx)
df <- rbind(df9, df11, df13, df15, df17)
df$wt.int <- df$wt.int / 5
df$wt.mec <- df$wt.mec / 5

## Separate data for primary analysis
## Can't subset survey with a complex design by dropping
df.p <- df %>% select(-c(wt.int, wt.mec, PSU, strata))
df.v <- df

## Filter by age
df.p <- df.p %>% filter(age >= 22)

## How many "Refused" and "I don't know"?
df.p %>% filter(asthma == "Refused" |
                asthma == "Don't know" |
                asthma.now == "Refused" |
                asthma.now == "Don't know" |
                smoke == "Refused" |
                education == "Refused" |
                education == "Don't Know") %>% count()

## Remove NA in bmi and poverty
df.p <- df.p %>% filter(!is.na(bmi))
df.p <- df.p %>% filter(!is.na(poverty))

## Drop "Don't know" and "Refused"
df.p <- df.p %>% filter(asthma != "Don't know")
df.p$asthma <- droplevels(df.p$asthma)

df.p <- df.p %>% filter(education != "Refused")
df.p <- df.p %>% filter(education != "Don't Know")
df.p$education <- droplevels(df.p$education)
levels(df.p$education) <- c("<9", "9-11", "high", "aa", "college",
                          "<9", "9-11", "high", "aa", "college")

df.p <- df.p %>% filter(smoke != "Refused")
df.p$smoke <- droplevels(df.p$smoke)

## Recode asthma
df.p$y <- ifelse(df.p$asthma == "Yes" & df.p$asthma.now == "Yes",
                 1, 0)
df.p$y <- factor(df.p$y, levels = c(0, 1),
                 labels = c("Never", "Yes"))
df.p <- df.p %>% select(-c(asthma, asthma.now))
df.p$asthma <- df.p$y
df.p <- df.p %>% select(-c(y))

## Recode poverty
df.p$poverty <- ifelse(df.p$poverty < 1, 1, 0)
df.p$poverty <- factor(df.p$poverty, levels = c(0, 1),
                       labels = c("Above poverty line",
                                  "Below poverty line"))

## Recode education
levels(df.p$education) <- c("Below high school",
                            "Below high school",
                            "High school",
                            "Above high school",
                            "Above high school")

## Recode smoke
levels(df.p$smoke) <- c("Yes", "Yes", "No")

## Recode ethnicity
levels(df.p$ethnicity) <- c("Hispanic",
                            "Hispanic",
                            "Non-Hispanic White",
                            "Non-Hispanic Black",
                            "Other")

## Recode "Refused" and "Don't know" to NA in weighted sample
## Weighted sample is used for comparison in exploratory analysis
df.v$education <- df.v$education %>%
    na_if("Refused") %>%
    na_if("Don't know") %>%
    na_if("Don't Know")
df.v$education <- droplevels(df.v$education, exclude = NA)
levels(df.v$education) <- c("<9", "9-11", "high", "aa", "college",
                            "<9", "9-11", "high", "aa", "college")

df.v$asthma.now <- df.v$asthma.now %>%
    na_if("Refused") %>%
    na_if("Don't know") %>%
    na_if("Don't Know")
df.v$asthma.now <- droplevels(df.v$asthma.now, exclude = NA)
levels(df.v$asthma.now) <- c("Yes", "No")

df.v$asthma <- df.v$asthma %>%
    na_if("Refused") %>%
    na_if("Don't know") %>%
    na_if("Don't Know")
df.v$asthma <- droplevels(df.v$asthma, exclude = NA)
levels(df.v$asthma) <- c("Yes", "No")

df.v$smoke <- df.v$smoke %>%
    na_if("Refused") %>%
    na_if("Don't know") %>%
    na_if("Don't Know")
df.v$smoke <- droplevels(df.v$smoke, exclude = NA)
levels(df.v$smoke) <- c("Every day",
                        "Some days",
                        "Not at all")

## Recode asthma
df.v$y <- ifelse(df.v$asthma == "Yes" & df.v$asthma.now == "Yes",
                 1, 0)
df.v$y <- factor(df.v$y, levels = c(0, 1),
                 labels = c("Never", "Yes"))
df.v <- df.v %>% select(-c(asthma, asthma.now))
df.v$asthma <- df.v$y
df.v <- df.v %>% select(-c(y))

## Recode poverty
df.v$poverty <- ifelse(df.v$poverty < 1, 1, 0)
df.v$poverty <- factor(df.v$poverty, levels = c(0, 1),
                       labels = c("Above poverty line",
                                  "Below poverty line"))

## Recode education
levels(df.v$education) <- c("Below high school",
                            "Below high school",
                            "High school",
                            "Above high school",
                            "Above high school")

## Recode smoke
levels(df.v$smoke) <- c("Yes", "Yes", "No")

## Recode ethnicity
levels(df.v$ethnicity) <- c("Hispanic",
                            "Hispanic",
                            "Non-Hispanic White",
                            "Non-Hispanic Black",
                            "Other")

## Export (to use in dissertation body)
write.csv(df.p, "data/primary.csv", row.names = FALSE)
write.csv(df.v, "data/weighted.csv", row.names = FALSE)
