


input_1<-fread("1.csv", stringsAsFactors=F)
input_2<-fread("2.csv", stringsAsFactors=F)

stat_df<-rbind(input_1,input_2)
colnames(stat_df)[4] <- "counter"

stat_df<-stat_df%>%
  arrange(USER_ID,IS_WALKIN)

stat_short<-stat_df%>%
  filter(USER_ID<1000)
stat_short<-stat_short%>%
  group_by(USER_ID)%>%
  mutate(average_walkins=counter[2]/(counter[1]+counter[2]))

stat_short$average_walkins[is.na(stat_short$average_walkins)] <- 0
stat_short<-stat_short%>%
  group_by(USER_ID)%>%
  slice(1:1)
mean(stat_short$average_walkins)
