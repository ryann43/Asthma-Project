## Packages
library(ggplot2)   # Plots
library(corrplot)  # Plots
library(dplyr)     # Data manipulation
library(broom)     # tidy()
library(survey)    # Complex survey design
library(tableone)  # Survey table
library(DescTools) # Cramer's V
library(caret)     # Model fitting
library(glmnet)    # Logit
library(randomForest) # Random forest
library(ROSE)         # Resampling
library(yardstick)    # Model evaluation

## Random seed
set.seed(42)

## Data
df.p <- read.csv("data/primary.csv", stringsAsFactors = TRUE)
df.v <- read.csv("data/weighted.csv", stringsAsFactors = TRUE)
df.p <- df.p %>% select(-c(id))

## Crosstabs
## By gender
byg <- CreateTableOne(data = df.p, includeNA = TRUE,
                      strata = "gender", test = FALSE,
                      var = c("age", "ethnicity", "poverty",
                              "education", "bmi", "smoke",
                              "asthma"))

bygv <- CreateTableOne(data = df.v, includeNA = TRUE,
                       strata = "gender", test = FALSE,
                       var = c("age", "ethnicity", "poverty",
                               "education", "bmi", "smoke",
                               "asthma"))

## By year
df.p$year <- as.factor(df.p$year)
byy <- CreateTableOne(data = df.p, includeNA = TRUE,
                      strata = c("asthma", "gender"), test = FALSE,
                      var = c("year"), addOverall = TRUE)

df.v$year <- as.factor(df.v$year)
byyv <- CreateTableOne(data = df.v, includeNA = TRUE,
                       strata = c("asthma", "gender"), test = FALSE,
                       var = c("year"), addOverall = TRUE)

bygv <- CreateTableOne(data = df.v,
                       includeNA = TRUE,
                       test = FALSE,
                       var = c("age", "gender", "ethnicity", "poverty",
                               "education", "bmi", "smoke",
                               "asthma"))

## By asthma
bya <- CreateTableOne(data = df.p, includeNA = TRUE, 
                      strata = "asthma", test = FALSE,
                      var = c("gender", "age", "ethnicity", "poverty",
                              "education", "bmi", "smoke"))

byav <- CreateTableOne(data = df.v, includeNA = FALSE,
                       strata = "asthma", test = FALSE,
                       var = c("gender", "age", "ethnicity", "poverty",
                               "education", "bmi", "smoke"))

## Asthma prevalence by gender and poverty
ggplot(df.p, aes(x = factor(poverty),
                 fill = asthma)) +
    geom_bar(stat = "count",
             position = "fill") +
    facet_wrap(df.p$gender) +
    labs(x = "poverty", y = "proportion")

## Asthma prevalence by gender and education
## Reorder levels for presentation
df.p$education <- factor(df.p$education,
                         levels = c("Below high school",
                                    "High school",
                                    "Above high school"))

ggplot(df.p, aes(x = factor(education),
                 fill = asthma)) +
    geom_bar(stat = "count",
             position = "fill") +
    facet_wrap(df.p$gender, nrow = 2) +
    labs(x = "education", y = "proportion") +
    coord_flip()

## Asthma prevalence by gender and smoking status
ggplot(df.p, aes(x = factor(smoke),
                 fill = asthma)) +
    geom_bar(stat = "count",
             position = "fill") +
    facet_wrap(df.p$gender) +
    labs(x = "smoking", y = "proportion")

## Asthma prevalence by gender and ethnicity
ggplot(df.p, aes(x = factor(ethnicity),
                 fill = asthma)) +
    geom_bar(stat = "count",
             position = "fill") +
    facet_wrap(df.p$gender, nrow = 2) +
    labs(x = "education", y = "proportion") +
    coord_flip()
a
df_comb = expand.grid(names(df), names(df),  stringsAsFactors = F) %>% set_names("X1", "X2")

## BMI by gender and asthma
ggplot(df.p, aes(x = gender,
                 y = bmi,
                 color = asthma)) +
    geom_boxplot(outlier.shape = NA) +
    geom_point(position = position_jitterdodge(),
               size = 1,
               alpha = 0.5)

## Age by gender and asthma
ggplot(df.p, aes(x = gender,
                 y = age,
                 fill = asthma)) +
    geom_boxplot()

## Standardise continuous variables
df <- df.p %>% mutate_at(c("bmi", "age"),
                         ~(scale(.) %>% as.vector))

## Year as factor
df$year <- factor(df$year)

## One-hot encode nominal variables
x <- df %>% select(-c(asthma))
x <- dummyVars("~ .", x, fullRank = TRUE)
x <- data.frame(predict(x, newdata = df))

## Recode response as binary
y <- ifelse(df.p$asthma == "Yes", 1, 0)

## Baseline logit
baseline <- glm(y ~ ., cbind(x, y),
                family = "binomial")

## No year
x <- df %>% select(-c(asthma, year))
x <- dummyVars("~ .", x, fullRank = TRUE)
x <- data.frame(predict(x, newdata = df))

baseline.noy <- glm(y ~ ., cbind(x, y),
                    family = "binomial")

## Year-noyear comparison
anova(baseline, baseline.noy)

## Male
df <- df.p %>% mutate_at(c("bmi", "age"),
                         ~(scale(.) %>% as.vector))

df <- df %>%
    filter(gender == "Male") %>%
    select(-c(year, gender))

x <- df %>% select(-c(asthma))
x <- dummyVars("~ .", x, fullRank = TRUE)
x <- data.frame(predict(x, newdata = df))

y <- ifelse(df$asthma == "Yes", 1, 0)

baseline.m <- glm(y ~ ., cbind(x, y),
                  family = "binomial")

## Female
df <- df.p %>% mutate_at(c("bmi", "age"),
                         ~(scale(.) %>% as.vector))

df <- df %>%
    filter(gender == "Male") %>%
    select(-c(year, gender))

x <- df %>% select(-c(asthma))
x <- dummyVars("~ .", x, fullRank = TRUE)
x <- data.frame(predict(x, newdata = df))

y <- ifelse(df$asthma == "Yes", 1, 0)

baseline.f <- glm(y ~ ., cbind(x, y),
                  family = "binomial")

## Scores
df <- df.p %>% mutate_at(c("bmi", "age"),
                         ~(scale(.) %>% as.vector))

x <- df %>% select(-c(asthma, year))
x <- dummyVars("~ .", x, fullRank = TRUE)
x <- data.frame(predict(x, newdata = df))

y <- ifelse(df.p$asthma == "Yes", 1, 0)

baseline.noy <- glm(y ~ ., cbind(x, y),
                    family = "binomial")

df$prob <- predict(baseline.noy,
                   newdata = cbind(x, y),
                   type = "response")
df$class <- ifelse(df$prob < 0.2, 0, 1)
df$class <- factor(df$class,
                   levels = c(0, 1),
                   labels = c("Never", "Yes"))

roc.curve(df$asthma, df$prob)

confm <- df.noy %>%
    conf_mat(truth = asthma, class)

## ROSE logit
df <- df.p %>% mutate_at(c("bmi", "age"),
                         ~(scale(.) %>% as.vector))

x <- df %>% select(-c(asthma, year))
x <- dummyVars("~ .", x, fullRank = TRUE)
x <- data.frame(predict(x, newdata = df))
y <- df$asthma
df <- cbind(x, y)

inTraining <- createDataPartition(df$y, p = .75, list = FALSE)
training <- df[ inTraining,]
testing  <- df[-inTraining,]

trc <- trainControl(method = "repeatedcv",
                    number = 10,
                    repeats = 10,
                    classProbs = TRUE,
                    summaryFunction = twoClassSummary,
                    search = "random")

tr.bal <- ROSE(y ~., data = training)$data

log.ROSE <- train(y ~ .,
                  data = tr.bal,
                  method = "glm",
                  metric = "ROC",
                  trControl = trc,
                  family = "binomial")

## Scores
tr.bal$prob <- predict(log.ROSE,
                       newdata = tr.bal,
                       type = "prob")
tr.bal$prob <- tr.bal$prob$Yes
tr.bal$class <- predict(log.ROSE,
                        newdata = tr.bal)
tr.bal$data <- "train"

testing$prob <- predict(log.ROSE,
                        newdata = testing,
                        type = "prob")
testing$prob <- testing$prob$Yes
testing$class <- predict(log.ROSE,
                         newdata = testing)
testing$data <- "test"

roc.curve(tr.bal$y, tr.bal$prob)
roc.curve(testing$y, testing$prob)

confm <- training %>%
    conf_mat(truth = y, class)

confm <- testing %>%
    conf_mat(truth = y, class)

## Random forest
## If possible, enable parallel computing
## library(doParallel)
## cores <- makeCluster(detectCores()-1)
## registerDoParallel(cores = cores)

df <- df.p %>% mutate_at(c("bmi", "age"),
                         ~(scale(.) %>% as.vector))

x <- df %>% select(-c(asthma, year))
x <- dummyVars("~ .", x, fullRank = FALSE)
x <- data.frame(predict(x, newdata = df))
y <- df$asthma
df <- cbind(x, y)

inTraining <- createDataPartition(df$y, p = .75, list = FALSE)
training <- df[ inTraining,]
testing  <- df[-inTraining,]

trc <- trainControl(method = "cv",
                    number = 10,
                    classProbs = TRUE,
                    summaryFunction = twoClassSummary,
                    search = "grid")

tune.grid <- expand.grid(mtry = c(2:10))

rf.fit <- train(y ~ .,
                data = training,
                method = "rf",
                metric = "ROC",
                trControl = trc,
                tuneGrid = tune.grid)

training$prob <- predict(rf.fit,
                       newdata = training,
                       type = "prob")
training$prob <- training$prob$Yes
training$class <- predict(rf.fit,
                        newdata = training)
training$data <- "train"

testing$prob <- predict(rf.fit,
                        newdata = testing,
                        type = "prob")
testing$prob <- testing$prob$Yes
testing$class <- predict(rf.fit,
                         newdata = testing)
testing$data <- "test"

roc.curve(training$y, training$prob)
roc.curve(testing$y, testing$prob)

confm <- training %>%
    conf_mat(truth = y, class)

confm <- testing %>%
    conf_mat(truth = y, class)

## ROSE RF
df <- df.p %>% mutate_at(c("bmi", "age"),
                         ~(scale(.) %>% as.vector))

x <- df %>% select(-c(asthma, year))
x <- dummyVars("~ .", x, fullRank = FALSE)
x <- data.frame(predict(x, newdata = df))
y <- df$asthma
df <- cbind(x, y)

inTraining <- createDataPartition(df$y, p = .75, list = FALSE)
training <- df[ inTraining,]
testing  <- df[-inTraining,]

trc <- trainControl(method = "cv",
                    number = 10,
                    classProbs = TRUE,
                    summaryFunction = twoClassSummary,
                    search = "grid")

tune.grid <- expand.grid(mtry = c(2:10))
training <- ROSE(y ~., data = training)$data

rf.ROSE <- train(y ~ .,
                data = training,
                method = "rf",
                metric = "ROC",
                trControl = trc,
                tuneGrid = tune.grid)

training$prob <- predict(rf.ROSE,
                       newdata = training,
                       type = "prob")
training$prob <- training$prob$Yes
training$class <- predict(rf.ROSE,
                        newdata = training)
training$data <- "train"

testing$prob <- predict(rf.ROSE,
                        newdata = testing,
                        type = "prob")
testing$prob <- testing$prob$Yes
testing$class <- predict(rf.ROSE,
                         newdata = testing)
testing$data <- "test"

roc.curve(training$y, training$prob)
roc.curve(testing$y, testing$prob)

confm <- training %>%
    conf_mat(truth = y, class)

confm <- testing %>%
    conf_mat(truth = y, class)

## stopCluster(cores)
