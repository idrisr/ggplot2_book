require(ggplot2)
require(splines)

set.seed(1410)

dsmall <- diamonds[sample(nrow(diamonds), 100), ]

#first two arguments to qplot are x and y
#optional 3rd argument that says where the data is.
qplot(carat, price, data=diamonds)

qplot(log(carat), log(price), data = diamonds)
qplot(carat, x*y*z, data=diamonds)

qplot(carat, price, data=dsmall, colour=color) 

#Sec 2.5.1
qplot(carat, price, data=dsmall, geom=c("point", "smooth"))
qplot(carat, price,  data=diamonds, geom=c("point", "smooth"))
qplot(carat, price, data=dsmall, geom=c("point", "smooth"), span=1)

#loess is O(n^2) so doesn't work well for large datasets
#alt smoothing algo used when n>1000

qplot(carat, price, data=dsmall, geom=c("point", "smooth"), method="lm")

#is related to

qplot(carat, price, data=dsmall, geom=c("point", "smooth"), method="lm", 
      formula = y ~ ns(x,5))

#Sec 2.5.2
qplot(color, price, data = diamonds, geom = "jitter", alpha = I(1 / 5))
qplot(color, price, data = diamonds, geom = "jitter", alpha = I(1 / 50))
qplot(color, price, data = diamonds, geom = "jitter", alpha = I(1 / 200))

#Sec 2.5.3
qplot(carat, data=diamonds, geom = "histogram")
qplot(carat, data=diamonds, geom = "density")

qplot(carat, data = diamonds, geom = "density", colour = color)
qplot(carat, data = diamonds, geom = "histogram", fill = color)

#Sec 2.5.4
qplot(color, data = diamonds, geom = "bar")
qplot(color, data = diamonds, gemo = "bar", weight = carat) +
scale_y_continuous("carat")

#Sec 2.5.5
qplot(date, unemploy / pop, data = economics, geom = 'line')
qplot(date, uempmed, data = economics, geom = 'line')

# To examine this relationship in greater detail, we could draw a scatterplot
# of unemployment vs length of employment, but then we'd lose the evolution
# over time

#setting year as a function, not an array
year  <- function(x) as.POSIXlt(x)$year + 1900
qplot(unemploy / pop, uempmed, data = economics, geom = c('point', 'path'))
qplot(unemploy / pop, uempmed, data = economics, geom = 'path', colour =
      year(date)) + scale_area()

# 2.6 Faceting
qplot(carat, data = diamonds, facets = color ~ ., geom = 'histogram', 
      binwidth = 0.1, xlim = c(0,3))

# density allows you to compare and ignore relative size differences by color
qplot(carat, ..density.. , data=diamonds, facets = color ~ .,
      geom = 'histogram', binwidth = 0.1, xlim = c(0, 3))
