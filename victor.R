library(dplyr)
library(openxlsx)
library(plyr) 
df = read.xlsx("userdata.xlsx")
df$Type <- as.factor(df$Type)
df$User <- as.factor(df$User)
df$Time <- as.POSIXct(df$Time*(60*60*24), origin="1899-12-30", tz="GMT")


length(df$Type)
summary(df$Type)
df_without_hour=df
df_without_hour$Time <- as.Date(df_without_hour$Time) #Removing the hour
last_seven = df[FALSE,]

for (i in 1 : nrow(df) ){  #Take the last 7 days
  if (as.numeric(difftime(max(df_without_hour$Time) ,df_without_hour$Time[i] ,
                          units = c("days"))) < 6.999 ){
      last_seven=rbind(last_seven,df_without_hour[i,])
  }
}

seven= data.frame(table(last_seven$Time)) #Count the freq for each date
seven
sum(seven$Freq)#Count the total number of cigarettes smoked the last seven days
plot (seven)

#question statistic on modes
summary(df$Type)
stat.mode <- function(x) {cbind(freq = table(x), percentage = prop.table(table(x))*100)}
stat.mode(df$Type)


#question percentage of improvement
df_without_friend_mode=df_without_hour[FALSE,]
df_without_friend_mode <- df_without_hour[df_without_hour$Type!='Friend',] #not taking rows with friend
nrow(df_without_friend_mode) ##65006

rownames(df_without_friend_mode) <- 1:nrow(df_without_friend_mode)  #index : 1,2,3 ...

nbuser=nrow(unique(df_without_friend_mode[1])) #number of user = 32
userid=unique(df_without_friend_mode[1]) ##the first new row id for each new us

user_id=as.numeric(rownames(userid))
user_id <- c(user_id, nrow(df_without_friend_mode)) #add a line with the number of rows
user_id

min_date=unique(df_without_friend_mode %>% group_by(User) %>% top_n(-1, Time)) #get the first
                                                                              # dat of activiry for   
                                                                              #each user
min_date$Type=NULL #delete the column about the type

min_date=ddply(min_date, .(User), head, n = 1) #remove the duplicate
min_date
question=setNames(data.frame(matrix(ncol = 3, nrow = nbuser)), #dataframe for receiving the count of
                  c("Week_observation", "Week1", "Week2"))    #week observation, week1 and week2
for (i in 1:3) question[i]=0 #fill it with 0
question

for (j in 1:nbuser){ #for each user
  
  for (i in user_id[j] : user_id[j+1]){ #for each user we get over the rows associate to this user
    
    if (df_without_hour$Type[i]=='Observation week'){
      question$Week_observation[j]=question$Week_observation[j]+1 #+1 for observation week column
    }
    if (round(as.numeric(difftime(df_without_hour$Time[i],min_date$Time[j]  ,
                                 units = c("days"))),0) < 7.0){
      question$Week1[j]=question$Week1[j]+1        #+1 for week1 column
    }
    else if ((round(as.numeric(difftime(df_without_hour$Time[i],min_date$Time[j]  ,
                                       units = c("days"))),0) >= 7.0) &&(
      (round(as.numeric(difftime(df_without_hour$Time[i],min_date$Time[j]  ,
                                 units = c("days"))),0) < 14.0))){
      
      question$Week2[j]=question$Week2[j]+1 #+1 for week2 column
      }
  }
}

question
