#Made by: Choolwe Bright Chisengele

# Required packages
install.packages(c("dplyr","tidyr","ggplot2","pROC","randomForest","caret"))

#load necessary libraries
library(dplyr)
library(tidyr) 
library(ggplot2) #for plots
library(pROC) #auc roc evaluation
library(randomForest) #random forest 
library(caret) #confusion matrix # load every time


#data import 
fileUrl<-"data/UNSW-NB15_uncleaned.csv"
df<-read.csv(fileUrl)

#Data Inspection
class(df$service)
class(df$dload)
class(df$label)

summary(df$service)
summary (df$dload)

#-----------------------
#cleaning of service
#-----------------------
# Convert to character for manipulation
#df$service <- as.character(df$service)- is already a character

# Combine missing/unknown categories
df$service[df$service == "-" | is.na(df$service)] <- "unknown"


#group rare services (<1000) into 'other'
service_count <- table(df$service)
rare_services <- names(service_count[service_count < 1000 & names(service_count) != "unknown"])
df$service[df$service %in% rare_services] <- "other"

# Convert back to factor
df$service <- as.factor(df$service)
class(df$service)


#Cleaning of dload

#Imputing the dload with the median whilst maintaning the NA variables as new variable
df$dload<- as.numeric(df$dload)

df$dload_missing_flag <- ifelse(is.na(df$dload), 1, 0)
df$dload[is.na(df$dload)] <- median(df$dload, na.rm = TRUE)

summary(df$dload_missing_flag)

summary (df$dload)

#flag the 0 values
table(df$dload)
df$dload_zero_flag <- ifelse(df$dload == 0, 1, 0)

summary(df$dload_zero_flag)

#visualizing dload before log 

ggplot(df, aes(x=dload)) +
  geom_freqpoly()
summary(df$dload)

#log-transform the dload to avoid higher skew in visualization and makes it

df$dload_log <- log1p(df$dload)   # log(1 + x), safer for zeros


#--------------------
#cleaning of label   
#--------------------
df$label <- as.character(df$label)
table(df$label)
# Standardize normal label
df$label[df$label %in% c("0", "0_", "0?")] <- "0"

# Standardize attacks
df$label[df$label %in% c("1", "1_", "1?")] <- "1"

# Set missing/invalid to NA
df$label[df$label %in% c("NA?", "NA_")] <- NA

# Convert to factor with meaningful labels
df$label <- factor(df$label, levels = c("0", "1"), labels = c("normal", "attack"))
#drop na's
df<-df[!is.na(df$label),]

##Validation
# data validation
summary(df$service)
#dload 
summary(df$dload_log)

ggplot(df, aes(x=dload_log)) +
  geom_freqpoly()
ggplot(df, aes(x=dload_log)) +
  geom_boxplot()
#label
summary(df$label)
ggplot(df, aes(x = label, fill = label)) +
  geom_bar() +
  theme_minimal()

#--------------
#EDA
#--------------
# Check summary

## summary of variables together
summary(df[c("service","dload_log","label")])

summary(df[c("service","dload","dload_log","label")])
##Visualization and EDA 

#table showing the services linked to attacks

#Single Varaible Analysis 
ggplot(df,aes(x=service, fill=service))+
  geom_bar()+
  labs(title = "Distribution of Service Types", x="Service",y="Count")
table(df$service)
#dload_log
summary(df$dload_log)
ggplot(df, aes(x=dload_log))+
  geom_histogram(bins=100,fill="steelblue",color="black")+
  labs(title="Distribution of Log transformed downlaod rate",x="dload_log", y="count")

ggplot(df, aes(y=dload_log))+
    geom_boxplot(fill="lightgreen")+
    labs(title="Distribution of Log transformed downlaod rate",x="dload_log", y="count")
summary(dload_zero_flag)

#Bivariate and Multivariate analysis
# Cross-tabulation of Service and label
table(df$service, df$label)

# Proportional bar plot
ggplot(df, aes(x=service, fill=label)) +
  geom_bar(position="fill") +
  labs(title="Proportion of Attacks vs Normal by Service", x="Service", y="Proportion")

#Dload_zero flag and label
ggplot(df, aes(x = factor(dload_zero_flag), fill = label)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    x = "Zero Flag (1 = originally 0)",
    y = "Percentage",
    title = "Proportion of Attacks vs Normal by Dload Zero Flag"
  )

#dload_missing flag and label
ggplot(df, aes(x = factor(dload_missing_flag), fill = label)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    x = "Missing Flag (1 = originally NA)",
    y = "Percentage",
    title = "Proportion of Attacks vs Normal by Dload Missing Flag"
  )

#dload_log and label
table(df$dload_log,df$label)
ggplot(df, aes(x = label, y = dload_log, fill = label)) +
  geom_boxplot() +
  theme_minimal()+
  labs(
    x = "Label",
    y = "dload_log",
    title = "Distribution of dload_log by Label"
  )

#Main analysis
# Contingency table service vs label
service_label_table <- table(df$service, df$label)
# Chi-square test
chisq.test(service_label_table)

# Compare dload_log rates with label in wilcox test
wilcox.test(dload_log ~ label, data = df)

#Logistic regression
set.seed(123)   # ensures reproducibility

# split 70% train, 30% test
index <- sample(1:nrow(df), size = 0.7 * nrow(df))
train <- df[index, ]
test  <- df[-index, ]

#generalized logistic regression model encompassing all variables 
model <- glm(label ~ service + dload_log + dload_zero_flag + dload_missing_flag,
             data = train,
             family = binomial)

summary(model)
#predicting 
prob_test <- predict(model, newdata = test, type = "response")

#auc_(roc) test
roc_test <- roc(test$label, prob_test)
auc(roc_test)
#Procedure for plotting the AUC_ROC
# Compute ROC
roc_test <- roc(test$label, prob_test)

# Extract ROC data for ggplot
roc_df <- data.frame(
  fpr = rev(1 - roc_test$specificities),  # x-axis: 1 - specificity
  tpr = rev(roc_test$sensitivities)      # y-axis: sensitivity
)

# Get AUC
auc_value <- auc(roc_test)

# Plot ROC curve with ggplot
ggplot(roc_df, aes(x = fpr, y = tpr)) +
  geom_line(color = "black", size = 1.2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  annotate("text", x = 0.6, y = 0.2, label = paste("AUC =", round(auc_value, 4)), size = 7) +
  labs(
    title = "ROC Curve - Test Data",
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)"
  ) 


#Random Forest
set.seed(123)   # ensures reproducibility
rf_model <- randomForest(label ~ service + dload_log + dload_zero_flag + dload_missing_flag,
                         data = train,
                         ntree = 1000,          # number of trees
                         mtry = 2,             # number of variables considered at each split
                         importance = TRUE)    # allows us to see feature importance
print(rf_model)

#predictions on test set
rf_pred <- predict(rf_model, newdata = test)

#confusion matrix
conf_mat <- confusionMatrix(rf_pred, test$label)
print(conf_mat)

#variable importance
varImpPlot(rf_model, main = "Variable Importance - Random Forest")





