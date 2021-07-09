# %>% functions  together (piped) rather than using multiple brackets

#Install Relevant package
install.packages("RODBC")
install.packages("viridis")
install.packages("ggplot2")
install.packages("gganimate")
install.packages("babynames")
install.packages("viridis")
install.packages("dplyr")
install.packages("gifski")

# libraries:
library("RODBC")
library(ggplot2)
library(gganimate)
library(babynames)
library(hrbrthemes)
library(viridis)
library(dplyr)
library(gifski)

#More info on pacakge
help(package = "RODBC")

#Test connection
bisqldev <- odbcConnect("Test")

#Write query into a data frame
MyQuery <- sqlQuery(bisqldev,
                    "SELECT T.name
	,SUM(T.N) AS n
	,T.year
FROM BI_Reporting_Dev.dbo.tbl_testhkappt AS T
WHERE T.name IS NOT NULL
GROUP BY T.year
,T.name
ORDER BY T.year ASC")

#Created a table for this query as too slow to run whole thing in R -- Test OX Appt Table

# View data
head(MyQuery)

# Plot
p <- MyQuery %>%
  ggplot( aes(x=year, y=n, group=name, color=name)) +
  geom_line() +
  geom_point() +
  scale_color_viridis(discrete = TRUE) +
  ggtitle("Oxleas Appointments") +
  theme_ipsum() +
  ylab("Number of Appts") +
  transition_reveal(year)

# Use the animate function to render as gives more flexibility in design
# print(p) # Animation variable - p


# Render Gif - this can be a bit slow
animate(p, duration = 10, fps = 20, width = 800, height = 489, renderer = gifski_renderer())

# Save Gif - Reccommend opening in browser to see full animation
anim_save(filename = "H:/R/ox-appts.gif", animation = last_animation())
