
#*************************************************************************
#                            Chapter 5: Toolbox                          *
#*************************************************************************

# Non-exhaustive examples in this chapter about common plotting challenges

# 1. Basic plot types
# 2. distributions
# 3. overplotting
# 4. surface plots
# 5. statistical summaries
# 6. drawing maps
# 7. revealing uncertainty and error
# 8. annotating a plot
# 9. weighted data

#*************************************************************************
#                   Chapter 5.2: Overall Layering Strategy               *
#*************************************************************************
# 3 purposes of a layer
# 1. display the data
# 2. display a stat summary
# 3. add metadata, context, and annotations
# other metadata is used to highlight important features of the data. You may 
# want to render those last so they pop out to the reader

#*************************************************************************
#                   Chapter 5.3: Basic Plot Types                        *
#*************************************************************************
# fundamental building blocks of ggplot2
# each of following require x and y
# all understand colour and size
# filled geoms (bar, tile, and polygon) also understand fill
# point geom uses shape and line and path geoms understand linetype
geom_area()
geom_bar()
geom_line()
geom_point()
geom_polygon()
geom_text() # see appendix B for more
geom_tile()
require(ggplot2)
data(diamonds)
p <- ggplot(diamonds, aes(carat, depth)) 
p + geom_area()
p + geom_line()
p + geom_polygon()
p + geom_text()
p + geom_tile()

# Illustration of each of the above
df <- data.frame(
     x = c(3, 1, 5), 
     y = c(2, 4, 6),
     label = c('a', 'b', 'c')
     )
p <- ggplot(df, aes(x, y, label = label)) + xlab(NULL) + ylab(NULL)
p + geom_point() + opts(title = 'geom_point')
p + geom_bar(stat = 'identity') + opts(title = 'geom_bar(stat=\"identity\")')
p + geom_line() + opts(title = 'geom_line')
p + geom_area() + opts(title = 'geom_area')
p + geom_path() + opts(title = 'geom_path')
p + geom_text() + opts(title = 'geom_text')
p + geom_tile() + opts(title = 'geom_tile')
p + geom_polygon() + opts(title = 'geom_polygon')

#*************************************************************************
#                   Chapter 5.4: Displaying Distributions                *
#*************************************************************************
# There are a number of geoms that can be used to display distributions, 
# depending on the dimensionality of the distribution, whether it is continuous
# or discrete, and whether you are interested in contidional or joint
# distribution.
# examples of displaying a distribution
depth_dist <- ggplot(diamonds, aes(depth)) + xlim(58, 68)
depth_dist + geom_histogram(aes(y = ..density..), binwidth = 0.1) +
    facet_grid(cut ~ .)
depth_dist + geom_histogram(aes(fill = cut), binwidth = 0.1, position = 'dodge')
depth_dist + geom_histogram(aes(fill = cut), binwidth = 0.1, position = 'fill')
depth_dist + geom_histogram(aes(fill = cut), binwidth = 0.1, position =
                            'identity')
depth_dist + geom_histogram(aes(fill = cut), binwidth = 0.1, position = 'jitter')
depth_dist + geom_histogram(aes(fill = cut), binwidth = 0.1, position = 'stack')

p <- depth_dist + geom_freqpoly(aes(y = ..density.., colour = cut), binwidth = 0.1)

# both geom_histogram and geom_freqploy use the stat_bin. stat_bin produces two
# output variables: count and density. 

# geom_boxplot = stat_boxplot + geom_boxplot ???
# box and whisker plot, for a continuous variable conditioned by a categorical
# variable. This is a useful display when the categorical display has many
# distinct values. When there are a few values, the distributions give better
# plots. This technique can also be used for continuous variables, if they are
# first finely binned. 
qplot(cut, depth, data = diamonds, geom = 'boxplot')
p <- qplot(carat, depth, data = diamonds, geom = 'boxplot', 
      group = round_any(carat, 0.1, floor), xlim = c(0, 3))

# geom_jitter = position_jitter + geom_point
# a crude way of looking at discrete distributions by adding random noise to the
# discrete values to that they don't overplot
qplot(class, cty, data = mpg, geom = 'jitter')
qplot(class, drv, data = mpg, geom = 'jitter')

# geom_density = stat_density + geom_area
# a smoother version of the frequency polygon based on kernel smoothers. Also
# described in Section 2.5.3. Use a density plot when you know that the
# underlying density is smooth, continuous, and unbounded. You can use the
# adjust parameter to make the density more of less smooth.  
qplot(depth, data = diamonds, geom = 'density', xlim = c(54, 70))
qplot(depth, data = diamonds, geom = 'density', xlim = c(54, 70), fill = cut,
      alpha = I(0.2))

#*************************************************************************
#                   Chapter 5.5: Dealing with Overplotting               *
#*************************************************************************
df <- data.frame(x = rnorm(2000), y = rnorm(2000))
norm <- ggplot(df, aes(x, y))
norm + geom_point()
norm + geom_point(shape = 1)
norm + geom_point(shape = '.')
norm + geom_point(colour = alpha('black', 1/3))
norm + geom_point(colour = alpha('black', 1/5))
norm + geom_point(colour = alpha('black', 1/10))

#*************************************************************************
#                   Chapter 5.9: Statistical Summaries                   *
#*************************************************************************
# It's often useful to be able to summarize the y values for each unique x value
# in ggplot2, this role performed by stat_summary(), which provides a way of
# summarizing the conditional distribution of y with the aesthetics ymin, y and
# y max. 

# over my head for now

#*************************************************************************
#                   Chapter 5.10: Annotating a Plot                      *
#*************************************************************************

# When annotating your plot with additional labels, the important thing to
# remember is that these annotations are just extra data. You can add
# annotations one at a time, or many at once

data(economics)
unemp <- (qplot(date, unemploy, data = economics, geom = 'line', xlab = '',
            ylab = 'No. unemployed (1000s)'))
president <- presidential[-(1:3), ]

# range returns min to max
yrng <- range(economics$unemploy)
xrng <- range(economics$date)
unemp + geom_vline(aes(xintercept = start), data = president)

g <- unemp + geom_rect(aes(NULL, NULL, xmin = start, xmax = end, fill = party), 
                  ymin = yrng[1], ymax = yrng[2], data = presidential) +
                  scale_fill_manual(values = alpha(c('blue', 'red'), 0.2))

h <- geom_text(aes(x = start, y = yrng[1], label = name), 
                data = president, size = 3, hjust = 0, vjust = 0)
caption <- paste(strwrap("Unemployment rates in the US have varied a lot over
                         the years", 40), collapse = '\n')
unemp + geom_text(aes(x, y, label = caption), 
      data = data.frame(x = xrng[2], y = yrng[2]),
      hjust = 1, vjust = 1, size = 4)

highest <- subset(economics, unemploy == max(unemploy))
unemp + geom_point(data = highest, size = 3, colour = alpha('red', 0.5))

#*************************************************************************
#                   Chapter 5.11: Weighted Data                          *
#*************************************************************************

qplot(percwhite, percbelowpoverty, data = midwest)
qplot(percwhite, percbelowpoverty, data = midwest, size = poptotal / 1e6) + 
    scale_area('Population\n(millions)', breaks = c(0.5, 1, 2, 4))
qplot(percwhite, percbelowpoverty, data = midwest, size = area) + scale_area()

lm_smooth <- geom_smooth(method = lm, size = 1)
qplot(percwhite, percbelowpoverty, data = midwest) + lm_smooth
qplot(percwhite, percbelowpoverty, data = midwest, weight = popdensity, size =
      popdensity, size = popdensity) + lm_smooth

# number of counties
qplot(percbelowpoverty, data = midwest, binwidth = 1)

# number of people
qplot(percbelowpoverty, data = midwest, weight = poptotal, binwidth = 1) +
    ylab('population')
