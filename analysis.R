library(ggplot2)
library(emIRT)
library(data.table)
library(ggrepel)
library(tidyr)
library(dplyr)
library(dtplyr)
library(mgcv)
library(fields)
library(sandwich)
library(lmtest)


### Read the an

all_data <- fread("data/anonymized_results.csv")
dim_cols <- colnames(all_data)[grepl("^d[0-9]+",colnames(all_data))]

# For the ideology model, results from the users with known and/or polarized ideologies
v <- fread("data/anonymized_svdv.csv")


# Plot dimensions against facebook's average alignment scores for the different news organizations
m <- (melt(all_data[muck_org !=""], 
           measure.vars = dim_cols,id=c("media_name","muck_org","avg_align"))
      [,list(avg_align=avg_align[1],value=mean(value)),by=.(muck_org,media_name,variable)])
m <- arrange(m, -value )
m$mlt <- factor(paste(m$media_name,m$variable, sep = "__"), 
                levels = rev(paste(m$media_name, m$variable, sep = "__")))
m <- data.table(m)

theme_set(theme_bw(20))
  
p = ggplot(m[variable=='d3'], aes(reorder(media_name,value),value,color=avg_align)) + geom_point(size=8)
p <- p + coord_flip() + scale_color_continuous("Facebook\nAlignment Score",low='blue',high='red',guide = guide_colorbar(direction = "horizontal",barwidth = 10)) + ylab("Outlet") + xlab("Latent Dimension Value")  
p <- p + theme(legend.position = c(0.4,.85))
ggsave("figure_1a.pdf",p, h=10,w=10)  


### FIGURE 1B involves ideology of Twitter users linked to voter registration records,
# which we cannot share.  We therefore do not include code to generate Figure 1B.

cor(m[variable == "d3"]$value, m[variable == "d3"]$avg_align,use="complete.obs")

# Build models that match DW Nominate scores to congresspeople
mod_v = paste(paste("d",0:(length(dim_cols)-1),sep=""),collapse="+")
mod_v_gam = paste0(paste(paste("s(d",0:(length(dim_cols)-1),sep=""),collapse=")+"),")")
ideology_mod <- gam(formula(paste0("ideology~",mod_v_gam)),data=v[!is.na(ideology)])
#ideology_mod_lm <- lm(formula(paste0("ideology~",mod_v)),data=v)

# How well does model fit?
ggplot(data.frame(x=predict(ideology_mod),y=v[!is.na(ideology)]$ideology), aes(x,y)) + geom_point()
#ggplot(data.frame(x=predict(ideology_mod_lm),y=v$ideology), aes(x,y)) + geom_point()

# Add to D
all_data$ideology_pred <- predict(ideology_mod,newdata = all_data)

# Compare to simply averaging over the congresspeople they follow
# Very similar split into two-ish camps, but gives us a way to measure for those who don't
# neccesarily follow traditional sources
ggplot(all_data, aes(ideology_pred, mean_ideology_following)) + geom_point(alpha=.2) + stat_smooth() 




# subset to people we have log-odds estimates of text bias fr
j <- all_data[!is.na(lo)]
j$id_scale <- (j$ideology_pred-mean(j$ideology_pred))/(2*sd(j$ideology_pred))
j$lo_scale <- (j$lo-mean(j$lo))/(2*sd(j$lo))
j$media_name <- relevel(factor(j$media_name),ref="Politico")



pk <- ggplot(j[,mean(lo),by=.(media_name,avg_align)], aes(reorder(media_name,V1),V1, color=avg_align)) + geom_point(size=8)
pk<- pk + coord_flip() + scale_color_continuous("Facebook\nAlignment Score",low='blue',high='red',guide = guide_colorbar(direction = "horizontal",barwidth = 10)) + xlab("Outlet") + ylab("Latent Dimension Value")  
pk <- pk + theme(legend.position = c(0.35,.85))
ggsave("figure_2.pdf",pk, h=10,w=10)  



# Figure 3
theme_set(theme_bw(12))
r <- all_data[muck_org != "" & !is.na(lo), list(tw_m=mean(ideology_pred),tw_v=var(ideology_pred),
                                   n_m=mean(lo),n_v=var(lo)),by=.(media_name)] 
p1 <- ggplot(r, aes(tw_m,n_m,label=media_name)) + geom_point(size=3) + geom_text_repel(family="Times New Roman") + xlab("Twitter Ideological Mean\n(Authors: John Wihbey, Thalita Coleman, Kenneth Joseph, David Lazer)") + ylab("Text Ideological Mean") + geom_hline(yintercept = 0,color='grey') + geom_vline(xintercept = 0,color='grey')
p1 <- p1 + theme(text=element_text(family="Times New Roman"))
p1 <- p1 + ggtitle("Exploring the Ideological Nature of Journalists’ Social Networks\non Twitter and Associations with News Story Content")
p1 <- p1+ scale_x_continuous(limits=c(-1.3,1.3), breaks=c(-1.,0,1.),labels=c("More Liberal","Neutral","More Conservative") )
p1 <- p1+ scale_y_continuous(limits=c(-1.5,1.5), breaks=c(-1.,0,1.),labels=c("More Liberal","Neutral","More Conservative") )
p1
ggsave("figure_3.jpeg",p1, h=6.5,w=8)  


# Figure 4
# id_scale is the twitter ideology variable
model <- lm(lo~id_scale+media_name,data=j)
coeftest(model,vcovHC(model,"HC0"))
c <- coeftest(model,vcovHC(model,"HC1"))
res_df <- data.table(name=sub("media_name","",rownames(c)),est=c[,1],lower=c[,1]-1.96*c[,2],upper=c[,1]+1.96*c[,2])[! "Intercept" %in% name & lower*upper > 0]
res_df[res_df$name == "id_scale"]$name <- "Twitter Ideology Score"
res_df <- res_df[!grepl("Intercept",name)]
p4 <- ggplot(res_df, aes(reorder(name,est), est,ymin=lower,ymax=upper,color=grepl("Twitter",name))) + geom_pointrange() + coord_flip() + geom_hline(yintercept = 0,color='red') + scale_color_manual(values=c("grey","black")) + theme(legend.position="none") + ylab("Predictors of Article Ideology") + xlab("Effect") 
ggsave("figure_4.pdf",p4, h=4.5,w=7) 



