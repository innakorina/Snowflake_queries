(this is a markdown (.md) file. Use double space to go to a new line.   
Use "Preview" to check format is displaying as you want it before committing changes.)


## user_user u
user_user.id matches up to reservation_bookreservation.user_id  
user_user.id do not match with resy_info.user_id (They did match before 2017)
user_user.foreign_id matches up to resy_info_user_id  

## user_info ui  
user_info.id matches up to resy_info.user_id  




## venue_info v  
r.venue_id = v.id  
v.enable_for_app: identifies venues displayed in app


## reservation_bookreservation r  
r.venue_id = 1278 is a test venue. Should be excluded 
r.cancellation_id is null excludes cancelled reservations



## location_info li
li.show_in_app: identifies cities that are in-app
li.show_on_web: identifies cities listed in website


