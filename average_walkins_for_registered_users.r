//getting records for registered users about their total walkins and non-walkins
SELECT uu.id as user_id, rr.is_walkin, count(user_ID)
from user_user as uu
inner join user_info as u on u.ID = uu.foreign_ID
inner JOIN reservation_bookreservation rr on rr.user_id = uu.id
where uu.foreign_type='resy_app'
and rr.CANCELLATION_ID is null
GROUP BY uu.id, rr.is_walkin
ORDER BY uu.id asc


#In R 

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
