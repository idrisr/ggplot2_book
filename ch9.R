#*************************************************************************
#                       Chapter 9: Manipulating data                     *
#*************************************************************************

# Much of this book has assumed the data is clean. Oh, not so in real life. 
# This chapter is about plyr

#*************************************************************************
#                   Chapter 9.1: An Introduction to plyr                 *
#*************************************************************************

# Plyr provides a comprehensive suite of tools for breaking up complicated data
# structures into pieces, processing each piece and then joining the results
# back together. 
# The plyr package can do a lot with lists, arrays, and data frames. 
# ddply breaks up a data frame into subsets based on row values, applies a
# function to each subset and then joins the results back into a data frame. 
The basic syntax is ddply(.data, .variables, .fun, ...), where

# .data is the dataset to break up

# .variables is a description of the grouping variables used to break up the 
#       dataset. This is written like .(var1, var2), and to match the plot
#       should contain all the grouping and faceting variables that you've used
#       in the plot. 

# .fun is the summary function you want to use. The function can return a vector
#       data frame. The result does not need to contain the grouping variables:
#       these will be added on automatically if they're needed. The result can
#       be a much reduced aggregate dataset (maybe even one number), or the
#       original data modified or expanded in some way.

# Useful summary functions that solve common data manipulation problems

# ***************************** Subset ************************
# Using subset() allows you to select the top (or bottom) n (or x%) of
# observations in each group, or observations above (or below) some group
# specific threshold:
require(ggplot)
data(diamonds)
# Select the smallest diamond in each colour
ddply(diamonds, .(color), subset, carat == min(carat))

# Select the two smallest diamonds
ddply(diamonds, .(color), subset, order(carat) <= 2)

# Select the 1% largest diamonds in each group
ddply(diamonds, .(color), subset, carat > quantile(carat, 0.99))

# Select all diamonds bigger than the group average
ddply(diamonds, .(color), subset, price > mean(price))

# ***************************** Transform ************************
# Using transform() allows you to perform group-wise transformations with very
# little work. This is particularly useful if you want to add new variables that
# are calculated on a per-group level, such as per-group standardisation.
# Section 9.2.1 shows another use of this technique for standardising time
# series to a common scale. 

# Within each colour, scale price to mean 0 and variance 1
ddply(diamonds, .(color), transform, price = scale(price))

# Subtract off group mean
ddply(diamonds, .(color), transform, price = price - mean(price))

# If you want to apply a function to every column in the data frame, you might
# find the colwise() function handy. This function converts a function that
# operates on vectors to a function that operates column-wise on data frames.
# This is rather different than most functions: instead of returning a vector of
# numbers, colwise() returns a new function. The following example creates a
# function to count the number of missing values in a vector and then shows how
# we can use colwise() to apply it to every column in a data frame.

nmissing <- function(x) sum(is.na(x))
nmissing(msleep$name)
nmissing(msleep$brainwt)

nmissing_df <- colwise(nmissing)
nmissing_df(msleep)

# This is a shorthand for the last two steps
colwise(nmissing)(msleep)

# The specialised version numcolwise() does the same thing, but works only with
# numeric columns. For example, numcolwise(median) will calculate the median for
# every numeric column, or numcolwise(quantile) will calculate quantiles for
# every numeric column. Similarly, catcolwise() only works with categorical
# columns.

msleep2 <- msleep[, -6] # remove a column to save space
numcolwise(median)(msleep2, na.rm = T)
numcolwise(quantile)(msleep2, na.rm = T)
numcolwise(quantile)(msleep2, probs = c(0.25, 0.75), na.rm = T)

# Combined with ddply, this makes it easy to produce per-group summaries
ddply(msleep2, .(vore), numcolwise(median), na.rm = T)
ddply(msleep2, .(vore), numcolwise(mean), na.rm = T)

# If none of the previous shortcuts is appropriate, make you own summary
# function which takes a data frame as input and returns an appropriately
# summarised data frame as output. The following function calculates the rank
# correlation of price and carat and compares it to the regular correlation of
# the logged values.

my_summary <- function(df) {
    with(df, data.frame(
        pc_cor = cor(price, carat, method = 'spearman'),
        lpc_cor = cor(log(price), log(carat))
        ))
}
ddply(diamonds, .(cut), my_summary)
ddply(diamonds, .(color), my_summary)

# Note how our summary function did not need to output the group variables. This
# makes it much easier to aggregate over different groups.

# The common pattern of all these problems is that they are easy to solve if we
# have the right subset. Often the solution for a single case might be a single
# line of code. The difficulty comes when we want to apply the function to
# multiple subsets and then correctly join back up the results. This may take a
# lot of code, especially if you want to preserve group labels. ddply() takes
# care of all of this for, says Hadley.

# The following case study shows how you can use plyr to reproduce the
# statistical summaries produced by ggplot2. This is useful if you want to save
# them to disk of apply them to other datasets. It's also useful to be able to
# check that ggplot2 is doing exactly what you think! 

# ********************** 9.1.1 Fitting Multiple Models ***********************
# In this section we work through the process of generating the smoothed data
# produced by stat_smooth. this process will be the same for any other
# statistic, and should allow you to produce more complex summaries that ggplot2
# can't produce by itself. 

qplot(carat, price, data = diamonds, geom = 'smooth', colour = color)
dense <- subset(diamonds, carat < 2)
qplot(carat, price, data = dense, geom = 'smooth', colour = color, fullrange =
      TRUE)

# How can we recreate this by hand? First we read the stat_smooth()
# documentation to determine what the model is: 
# for large data it's gam(y ~ s(x, bs = 'cs')). 
# To get the same shape as stat_smooth, we need to fit the model, then predict
# it on an evenly spaced grip of points. This task is done by the smooth()
# function in the following code. Once we have written this function it is
# straightforward too apply it to each diamond colour using ddply. 

require(mgcv) #Multiple Smoothing Parameter Estimation by GCV or UBRE
smooth <- function(df) {
    # gam: Generalized additive models with integrated smoothness estimation
    mod <- gam(price ~ s(carat, bs = 'cs'), data = df) 
    grid <- data.frame(carat = seq(0.2, 2, length = 50))
    pred <- predict(mod, grid, se = T)

    grid$price <- pred$fit
    grid$se <- pred$se.fit
    grid
}
smoothes <- ddply(dense, .(color), smooth)
qplot(carat, price, data = smoothes, colour = color, geom = 'line')
qplot(carat, price, data = smoothes, colour = color, geom = 'smooth', 
      ymax = price + 2 * se, ymin = price - 2 * se)

# Doing the summary by hand gives much more flexibility to fit models where the
# grouping factor is explicitly included as covariate. For example, the
# following model models price as a non-linear function of carat, plut a
# constant term for each colour. It's not a very good model as it predicts
# negative prices for small, poor-quality diamonds, but it's a starting point
# for a better model. 

mod <- gam(price ~ s(carat, bs = 'cs') + color, data = dense)
grid <- with(diamonds, expand.grid(
    carat = seq(0.2, 2, length = 50), 
    color = levels(color)
    ))
grid$pred <- predict(mod, grid)
qplot(carat, pred, data = grid, colour = color, geom = 'line')

# See sections 4.9.3 and 5.8 for other ways of combining models and data

#*************************************************************************
#              Chapter 9.2: Converting data from wide to long            *
#*************************************************************************

# In ggplot2 graphics, groups are defined by row, not by columns. This makes it
# easy to draw a line for each group defined by the value of a variable (or set
# of variables) but difficult to draw a separate line for each variable.
