# Desafio de Negócio
# Business Challenge

# Como todos (Departamentos de RH) já sabem, recontratar um funcionário requer um investimento 3x o valor do que mantê-lo na empresa. Caso realmente o funcionário queira sair, não em jeito mesmo.
# É um investimento muito melhor para a empresa manter um funcionário na empresa.
# As everyone (HR Departments) already knows, rehiring an employee requires an investment 3x the value of keeping him in the company. If the employee really wants to leave, let him/her go.
# It is a much better investment for the company to keep an employee in the company.


# Agora seguem algumas questões:
# Now here are some questions:

# 1) Existe alguma maneira de se prever a saída de um funcionário?
# 1) Is there any way to predict the departure of an employee?

# 2) Há como mapear algum tipo de informação que diga seo funcionário tende a continuar ou sair da empresa?
# 2) Is there a way to map some kind of information that tells if the employee tends to continue or leave the company?


# Respondendo às perguntas:
# Answering the questions:

# 1) Sim, com um trabalho de machine learning é possível obter uma probabilidade de tendência de saída ou não do funcionário da empresa.
# 1) Yes, with a machine learning job, it is possible to obtain a probability of exit trend or not of the employee.

# 2) Sim, é necessário que a empresa consiga juntar dados internos dos funcionários que estão e ainda dos que já saíram para se chegar a esteja probabilidade de tendência.
# 2) Yes, it is necessary that the company is able to gather internal data of employees who are and even those who have already left to reach this trend probability.


# Objetivo do Projeto: Prever a saída de colaborador baseado em informações hitóricas de desligamentos.
# Project objective: Predict employee departure based on historical information on dismissals.


# Definindo o diretório de trabalho
# Defining the working directory
setwd("C:/SJO/Portfolio/Hr_Analytics_Job")
getwd()


# Carregando os pacotes
# Loading packages
library(caret)
library(ROCR) 
library(e1071) 
library(dplyr)


# Abrindo e tendo as primeiras impressões dos dados
# Opening and getting first impressions of data
dfHR <- read.csv("data/HR_comma_sep.csv",header = TRUE, sep=",")
dim(dfHR)
head(dfHR)

# ↓↓ Tipos de dados R do dataframe
# ↓↓ Dataframe R datatypes
str(dfHR)

# Dicionário de dados
# Data dictionary

# satisfaction_level    => Nível de satisfação do colaborador
#                       => Employee satisfaction level

# last_evaluation       => Última avaliação do colaborador
#                       => Employee's last evaluation

# number_project        => Nº de projetos que o colaborador trabalhou
#                       => Number of projects the collaborator has worked on

# average_montly_hours  => Média de houras mensais trabalhadas pelo colaborador
#                       => Average monthly hours worked by the employee

# time_spend_company    => Tempo de empresa do colaborador
#                       => Employee company time

# Work_accident         => Nº de acidentes de trabalho com o trabalhador
#                       => Number of work accidents with the worker

# left                  => Status se já saiu da empresa ou não.
#                       => Status if you have already left the company or not.

# promotion_last_5years => Nº de promoções nos últimos 5 anos
#                       => Number of promotions in the last 5 years

# Department            => Departamento que o colaborador trabalha
#                       => Department the employee works

# salary                => Nível de salário do colaborador (baixo, médio e alto)
#                       => Employee salary level (low, medium and high)

# ↓↓ Alterando o nome das colunas para padrão minúsculo
# ↓↓ Changing column names to lowercase default
dfHR = rename(dfHR, department = Department)
dfHR = rename(dfHR, work_accident = Work_accident)

# Verificando se existem valores ausentes
# Checking for missing values
sum(is.na(dfHR))
# ↑↑ Não há valores ausentes
# ↑↑ There are no missing values

# Conhecendo um pouco da história do dados
# Knowing a bit of data history
hist(dfHR$left, breaks = 2, labels = c("Not Left","Left"), xlab = "Not Left or Left Company", ylab = " N# Employes")
# ↑↑ A variável target Left está desbalanceada para uso de modelos preditivos
# ↑↑ The target Left variable is unbalanced for use by predictive models

# ↑↑ HÁ NECESSIDADE DE BALANCEAMENTO
# ↑↑ THERE IS A NEED FOR BALANCING

hist(dfHR$last_evaluation, breaks = 5)
# ↑↑ A maioria dos empregados teve média de 5.5 e mais 2 grandes acima de 8.0 em suas últimas avaliações
# ↑↑ Most employees averaged 5.5 plus 2 big above 8.0 in their latest ratings

hist(dfHR$number_project)
# ↑↑ A maioria trabalhou entre 3 e 4 projetos
# ↑↑ Most worked between 3 and 4 projects

hist(dfHR$average_montly_hours)
# ↑↑ A maioria trabalha 155 horas mensais
# ↑↑ Most work 155 hours per month

hist(dfHR$time_spend_company)
# ↑↑ A maioria tem de 2 a 3,5 anos como empregado
# ↑↑ Most are 2 to 3.5 years old as an employee

hist(dfHR$promotion_last_5years)
# ↑↑ Um quantidade ínfima de pessoas recebeu propomoções nos últimos 5 anos.
# ↑↑ A tiny amount of people received promotions in the last 5 years.

barplot(table(dfHR$department), horiz = TRUE)
# ↑↑ O departamento que possui maior número de pessoas é sales.
# ↑↑ The department with the highest number of people is sales.

barplot(table(dfHR$salary))
# ↑↑ A maioria tem salário de nível baixo.
# ↑↑ Most are low-paid.

# Padronizando os valores numéricos, isto é, colocando na mesma escala
# Standardizing the numerical values, that is, putting them on the same scale

## Criando lista de nomes das colunas numéricas
## Creating list of numeric column names
numerical.columns = c ("satisfaction_level","last_evaluation","number_project","average_montly_hours","time_spend_company","work_accident","promotion_last_5years")

## Lista conteúdo da lista
## List list contents
numerical.columns

## Criando função para colocar os dados em scala usando a função scale do pacote base
## Creating function to scale data using scale function from base package
scale.features <- function(df, variables){
  for (variable in variables){
    df[[variable]] <- scale(df[[variable]], center = T, scale = T)
  }
  return(df)
}

## Aplicando a função de padronização, Scale nas colunas numéricas
## Applying the scale patterning function to numeric columns
dfHR_scaled <- scale.features(dfHR,numerical.columns)
head(dfHR_scaled)

# Verificando se classe target está balanceada
# Checking whether target class is balanced
table(dfHR_scaled["left"])
# ↑↑ A classe está disbalanceada, isto é, temos mais observações c/ valor 0 (11428) que valor 1 (3571).
# ↑↑ The class is unbalanced, that is, we have more observations with a value of 0 (11428) than a value of 1 (3571).


# ↑↑ Haverá necessidade de balanceamento de classes para o modelo preditivo!!!
# ↑↑ There will be a need for class balancing for the predictive model!!!

## Criando um dataframe com dados balanceados da variável Target Left (3571 registro de valor 0 e 3571 registro de valor 1)
## Creating a dataframe with balanced data from the Target Left variable (3571 register value 0 and 3571 register value 1)
df_zero = sample_n(dfHR_scaled[dfHR_scaled["left"]==0,],3571)
df_um = sample_n(dfHR_scaled[dfHR_scaled["left"]==1,],3571)
df_Balanced = rbind(df_zero,df_um)
dim(df_Balanced)
head(df_Balanced)

# Verificando novamente se classe target está balanceada
# Checking again if target class is balanced
table(df_Balanced["left"])
# ↑↑ Classe target (left) balanceada
# ↑↑ Balanced target (left) class


## Usando Random Forest para seleção de variáveis preditoras
## Using Random Forest for Predictor Variable Selection
library(randomForest)

rf_Feature_Importance <-randomForest(left~.,data=df_Balanced,importance=TRUE,ntree=500)

print(rf_Feature_Importance)
importance(rf_Feature_Importance)
varImpPlot(rf_Feature_Importance)


### Com o resultado do RandomForest para seleção de variáveis sugeridas
### With Random Forest result for selection of suggested variables
df_Featured = df_Balanced[c("satisfaction_level","number_project","time_spend_company","average_montly_hours","last_evaluation","department","salary","left")]
head(df_Featured)


## Separando os dados de treino e teste 70/30
## Separating 70/30 training and testing data
indexes <- sample(1:nrow(df_Featured), size = 0.7 * nrow(df_Featured))
train.data <- df_Featured[indexes,]
test.data <- df_Featured[-indexes,]

## Separando os atributos e as classes
## Separating Attributes and Classes
test.feature.vars <- test.data[,-1]
test.class.var <- test.data[,8]

### Construindo o modelo de regressão logística glm 
### Building the glm logistic regression model
formula.init <- "left ~ ."
formula.init <- as.formula(formula.init)
modelo_v1 <- glm(formula = formula.init, data = train.data, family = "binomial")

## Avaliando os parâmetros do modelo
## Evaluating model parameters
summary(modelo_v1)

# Fazendo previsões e analisando o resultado do modelo glm
# Making predictions and analyzing the result of the glm model

previsoes <- predict(modelo_v1, test.data, type = "response")
previsoes <- round(previsoes)
head(previsoes)

# Confusion Matrix
confusionMatrix(table(data = previsoes, reference = test.class.var), positive = '1')
# ↑↑ Listando a acurácia do modelo GLM
# ↑↑ Listing the accuracy of the GLM model


# Construindo o modelo de regressão logística Random Forest
# Building the Random Forest logistic regression model
modelo_v2 <- randomForest(left ~ .,data = train.data, importance=TRUE, ntree=1500)
print(modelo_v2)

# # Prevendo e Avaliando o modelo 
# # Predicting and Evaluating the Model
previsoes_new <- predict(modelo_v2, test.data, type = "response") 
previsoes_new <- round(previsoes_new)

# Motando as previsões com os dados de teste
# Building predictions with test data
previsoes_finais <- prediction(previsoes_new, test.class.var)
 
# # Confusion Matrix
confusionMatrix(table(data = previsoes_new, reference = test.class.var), positive = '1')

#Função para Plot ROC
#Function for Plot ROC
plot.roc.curve <- function(predictions, title.text){
   perf <- performance(predictions, "tpr", "fpr")
   plot(perf,col = "black",lty = 1, lwd = 2,
        main = title.text, cex.main = 0.6, cex.lab = 0.8,xaxs = "i", yaxs = "i")
   abline(0,1, col = "red")
   auc <- performance(predictions,"auc")
   auc <- unlist(slot(auc, "y.values"))
   auc <- round(auc,2)
   legend(0.4,0.4,legend = c(paste0("AUC: ",auc)), cex = 0.6, bty = "n", box.col = "white")

 }

# Plotando a Curva de ROC para visualizar a acurácia do modelo Final
# Plotting the ROC curve to visualize the accuracy of the Final model
par(mfrow = c(1, 2))
plot.roc.curve(previsoes_finais, title.text = "Final Model ROC Curve")

# Proposta de Conclusão:
# Baseando neste modelo, o departamento de RH pode receber a trimestre, um relatório de tendência de saída dos funcionários com 97% de probabilidade de ocorrer segundo o histórico da empresa.
# Em este em mãos, o departamento de RH pode buscar com os gestores dos respectivos departamentos ações para buscar manter os funcionários na empresa.
# Um plano de ação pro ativo, reconomiza muito recurso para empresa e a mantem em sua produtividade.

# Conclusion:
# Based on this model, the HR department can receive a quarterly, employee exit trend report with 97% probability of occurring based on company history.
# With this in hand, the HR department can seek with the managers of the respective departments actions to keep employees in the company.
# A proactive action plan, saves a lot of resources for the company and keeps it in its productivity.
