# /usr/bin/r
#
# harvest winton leaderboard data...
#
# Created: 2016.05.06
# Copyright: Steven E. Pav, 2016
# Author: Steven E. Pav <steven@corecast.io>
# Comments: Steven E. Pav

library(dplyr)
library(rvest)

fname <- 'winton/public_leaderboard.html'
get_lb <- function(fname) {
	is <- read_html(fname)
	lbtab <- html_table(is)[[1]]
	colnames(lbtab) <- c('place','delta','team_name','score','num_entries','last_submission')
	lbtab <- lbtab %>% 
		mutate(team_name = gsub('\\n','',team_name)) %>%
		mutate(team_name = gsub('\\s+\\*','',team_name)) %>%
		select(-delta,-last_submission)
	return (lbtab)
}

lbis <- get_lb(fname='winton/public_leaderboard.html')
lbos <- get_lb(fname='winton/private_leaderboard.html')

# get the zero prediction value, in sample
zisval <- lbis %>% 
	filter(grepl('Zero pred',team_name)) %>%
	(function(.) { .$score })
zosval <- lbos %>% 
	filter(grepl('Zero pred',team_name)) %>%
	(function(.) { .$score })
frat <- zosval / zisval

zval <- zisval

fooz <- inner_join(lbis,lbos,by=c('team_name','num_entries')) %>%
	rename(score_is=score.x,score_os=score.y,place_is=place.x,place_os=place.y)

require(ggplot2)

ph <- ggplot(fooz %>% filter(score_is <= 1.1 * zval) %>% mutate(does_beat=score_is < zval),
						 aes(x=1/score_is,y=1/score_os,group=does_beat,size=num_entries)) + 
	geom_point() + 
	stat_smooth(method='lm') + 
	geom_vline(xintercept = 1/zval) + 
	scale_x_log10() + scale_y_log10() 

print(ph)


ph <- ggplot(fooz %>% filter(score_is <= 0.9995 * zval),aes(x=1/score_is,y=1/score_os,size=num_entries)) + 
	geom_point() + 
	stat_smooth(method='lm') + 
	scale_x_log10() + scale_y_log10() 

print(ph)

ph <- ggplot(fooz %>% filter(place_os <= 100),aes(x=1/score_is,y=1/score_os,size=num_entries)) + 
	geom_point() + 
	stat_smooth(method='lm') + 
	scale_x_log10() + scale_y_log10() 

print(ph)

ph <- ggplot(fooz %>% filter(place_is <= 100),aes(x=1/score_is,y=1/score_os,size=num_entries)) + 
	geom_point() + 
	stat_smooth(method='lm') + 
	scale_x_log10() + scale_y_log10() 

print(ph)

# overfit vs. number of tries:
ph <- ggplot(fooz %>% mutate(overfit = log((score_os / score_is) / frat)),aes(x=num_entries,y=overfit)) + 
	geom_point() + 
	scale_x_log10() 

print(ph)

ph <- ggplot(fooz %>% filter(place_is <= 300) %>% mutate(overfit = log((score_os / score_is) / frat)),aes(x=num_entries,group=round(log10(num_entries),1),y=overfit)) + 
	geom_boxplot() + 
	scale_x_log10() 

print(ph)

# OS quality vs. number of tries:
ph <- ggplot(fooz %>% filter(place_is <= 300),aes(x=num_entries,group=round(log10(num_entries),1),y=1/score_os)) + 
	geom_boxplot() + 
	scale_x_log10() 

print(ph)

ph <- ggplot(fooz %>% filter(place_is <= 300),aes(x=num_entries,y=1/score_os)) + 
	geom_point() + stat_smooth(method='lm') + 
	scale_x_log10() 

print(ph)




#for vim modeline: (do not edit)
# vim:fdm=marker:fmr=FOLDUP,UNFOLD:cms=#%s:syn=r:ft=r
