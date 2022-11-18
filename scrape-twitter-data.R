# Setup ------------------------------------------------------------------------
library(tidyverse)
library(lubridate)
library(rtweet)
library(here)
library(fs)

if (!dir_exists("twitter-data")) dir_create("twitter-data")

if (interactive()) {
  auth <- auth_as("twitter-archive")
} else {
  auth <- rtweet_app(bearer_token = Sys.getenv("RTWEET_BEARER"))
  auth_as(auth)
}


# Get tweets -------------------------------------------------------------------
## Initial scrape
# my_tweets <- get_timeline(user = "wjakethompson", n = Inf,
#                           retryonratelimit = TRUE)
# write_csv(my_tweets, "twitter-data/my-tweets.csv")

## Check for new tweets
my_tweets <- read_csv("twitter-data/my-tweets.csv",
                      col_types = cols(id_str = col_character(),
                                       in_reply_to_status_id_str = col_character(),
                                       in_reply_to_user_id_str = col_character(),
                                       quoted_status_id_str = col_character()))

message("Checking for new tweets")

new_tweets <- get_timeline(user = "wjakethompson", n = 100, token = auth) %>% 
  anti_join(my_tweets, by = "id")

if (nrow(new_tweets) > 0) {
  bind_rows(new_tweets, my_tweets) %>% 
    write_csv("twitter-data/my-tweets.csv")
  
  system(paste0("git add twitter-data/my-tweets.csv"))
  system(paste0("git commit -m 'add new tweets ", today(), "'"))
}

# Get likes --------------------------------------------------------------------
## Initial scrape
# my_likes <- get_favorites(user = "wjakethompson", n = Inf,
#                           retryonratelimit = TRUE)
# write_csv(my_likes, "twitter-data/my-likes.csv")

## Check for new likes
my_likes <- read_csv("twitter-data/my-likes.csv",
                     col_types = cols(id_str = col_character(),
                                      in_reply_to_status_id_str = col_character(),
                                      in_reply_to_user_id_str = col_character(),
                                      quoted_status_id_str = col_character()))

message("Checking for new likes")

new_likes <- get_favorites(user = "wjakethompson", n = 100, token = auth) %>% 
  anti_join(my_likes, by = "id")

if (nrow(new_likes) > 0) {
  bind_rows(new_likes, my_likes) %>% 
    write_csv("twitter-data/my-likes.csv")
  
  system(paste0("git add twitter-data/my-likes.csv"))
  system(paste0("git commit -m 'add new likes ", today(), "'"))
}
