### **Cyber Intrusion Analysis, Detection and Classification**

A machine learning and statistical analysis project investigating network intrusion detection using the UNSW-NB15 Dataset. The project explores how network behaviour features influence the presence of cyber-attacks using data analysis, statistical testing, and predictive modelling in R.



#### **About the Author**

Choolwe Bright Chisengele

Bachelor of Computer Science (Hons) in Artificial Intelligence

Asia Pacific University of Technology and Innovation



Certified Artificial Intelligence Engineer

(Rocheston \& APU)

###### **Technologies Used**

Programming Language:



* R



###### **Libraries**

dplyr

tidyr

ggplot2

pROC

randomForest

caret



#### **Repository Structure**

cyber-intrusion-analysis/

│

├── data/

│   └── UNSW-NB15\_uncleaned.csv

│

├── analysis.R

│

├── Report.pdf

│

├── README.md

└── .gitignore



#### **Project Overview**



The increasing reliance on digital networks has significantly expanded the attack surface for cyber threats, making intrusion detection systems critical for maintaining network security. This project analyses network traffic patterns to identify indicators associated with malicious activity.



The analysis focuses on behavioural network features such as service type and destination download rate (dload) to determine their relationship with cyber-attack activity. The project follows a structured pipeline including data preprocessing, exploratory data analysis, statistical hypothesis testing, and machine learning modelling.



Feature engineering techniques such as log transformations and anomaly flags were introduced to capture abnormal network behaviour and potential attack signatures. Predictive models were then used to evaluate the significance and detection capability of these features.



#### **Dataset**



This project uses the UNSW-NB15 dataset, a modern intrusion detection benchmark created using the IXIA PerfectStorm traffic generator.



Report



The dataset contains both benign network traffic and multiple cyber-attack types.



Key variables analysed in this project:



dload (Destination Load):



Numeric variable representing the rate of data transferred to the destination.



service:



Categorical variable representing the network service used (e.g. HTTP, FTP, DNS).



label: (Target Variable)



Binary classification variable



0 = normal traffic



1 = attack



These variables act as behavioural indicators for distinguishing malicious traffic from benign network activity.



#### **Project Workflow**



The analysis follows the pipeline below.



1\. Data Import



The dataset is imported into R using read.csv() and stored in a dataframe.



2\. Data Cleaning



Several preprocessing steps were applied:



* conversion of character variables to appropriate data types



* grouping rare service categories into "other"



* handling missing values in dload



* creation of anomaly indicators



Engineered features include:



* dload\_missing\_flag – identifies originally missing download values



* dload\_zero\_flag – identifies zero download activity



* dload\_log – log transformation of download rate to reduce skew



3\. Data Validation



Validation ensured:



* categorical variables were properly encoded



* missing values were handled



* transformed variables reduced skew and improved distribution for modelling



4\. Exploratory Data Analysis (EDA)



EDA included:



* service distribution analysis



* download rate distribution



* relationships between service type and attack presence



* analysis of download rate anomalies



Key observations include:



* unknown and DNS services show high attack proportions



* attack traffic tends to exhibit very low download activity



Statistical Analysis



Two hypothesis tests were performed.



Chi-Square Test



Tested whether service type is associated with cyber-attack presence.



Result: p-value < 0.05



Service type is significantly associated with attack activity.



Wilcoxon Rank-Sum Test



Tested whether download rate differs between normal and attack sessions.



Result: p-value < 0.05



Download behaviour significantly differs between attack and benign traffic.



## **Machine Learning Models**

##### **Logistic Regression**



A logistic regression model was trained using:



* service



* dload\_log



* dload\_zero\_flag



* dload\_missing\_flag



Dataset split:



* 70% training



* 30% testing



Model evaluation using ROC-AUC:



AUC = 0.8618



This indicates strong ability to distinguish between benign and attack traffic.



##### **Random Forest**



A Random Forest classifier was trained with:



* 1000 trees



* mtry = 2 predictors per split



Performance on test set:



Accuracy

**84.13%**



Specificity

**98.17%**



Sensitivity

**54.15%**



Variable importance analysis showed:



dload\_log is the most influential feature for detecting cyber-attacks.



##### **Key Findings**



* Network behaviour indicators strongly influence cyber-attack detection



* Download rate behaviour (dload\_log) is the most important predictive feature



* Attack traffic typically exhibits lower and more irregular download activity



* Certain service categories show higher proportions of malicious traffic



These findings demonstrate that behavioural traffic characteristics can effectively support intrusion detection systems.



##### **Limitations**



Several limitations affected this study:



* Only a small subset of features from the dataset was analysed



* the Random Forest model was trained without hyperparameter tuning



* the dataset is imbalanced and simulated, which may limit real-world generalization



##### **Future Work**



Future improvements could include:



* incorporating additional network traffic features



* addressing dataset imbalance using SMOTE or resampling



* exploring advanced models such as Gradient Boosting or Deep Learning



* testing models on real-time network traffic datasets
