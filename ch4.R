require(ggplot2)
data(diamonds)


#*************************************************************************
#                            4.2 Creating a Plot                         *
#*************************************************************************
# when you use qplot(), it does a lot of things automatically for you. 
# to create the plot objects themselves, use ggplot(). It has two arguments:
# data and aesthetic mapping.  
p <- ggplot(diamonds, aes(carat, price, colour = cut))

#*************************************************************************
#                            4.3 LAYERS                                  *
#*************************************************************************
# a minimal layer may do nothing more than specify a geom
p <- p + layer(geom = 'point')

# no layers currently
p <- ggplot(diamonds, aes(carat, price, colour = cut))
p <- p + layer(geom = 'point')
# layer can take any of these arguments
layer(geom, geom_params, stats, stat_params, data, mapping, position)

# a more complicated ggplot call
p <- ggplot(diamonds, aes(x = carat))
p <- p + layer(
    geom = 'bar',
    geom_params = list(fill = 'steelblue'),
    stat = 'bin',
    stat_params = list(binwidth = 0.5)
)
p
# it's specific but verbose
# Can simplify it by using shortcuts that rely on the fact that every geom
# is associated wiht a default statistic and position, and every statistic with
# a default geom. 
# This means you that you only need to specify one of stat or geom to get a 
# completely specificied layer, with parameters passed on to the geom or stat

# this is the same thing
p <- p + geom_histogram(binwidth = 2, fill = 'steelblue')
p

# All the shortcut functions have the same basic form, beginning with geom_ or 
# stat_
geom_XXX(mapping, data, ... , geom, position)
stat_XXX(mapping, data, ... , stat, position)

Their common parameters:

mapping (optional): a set or aesthetic mappings, specified using the aes()
function and combined with the plot defaults as described in 4.5

data(optional): a dataset which overrides the default plot dataset. It is most
commonly omitted, in which case the layer will use the default plot data. See
Section 4.4

...: parameters for the geom or stat, such as bin width in the histogram or
bandwidth for a loess smoother. You can also use aesthetic properties as
parameters. When you do this you set the property to a fixed value, not map it
to a variable in the dataset. The example above showed setting the fill colour
of the histogram to 'steelblue'. See section 4.5.2 for more examples

geom or stat (optional): You can override the default stat for a geom, or the
default geom for a stat. This is a text string containing the name of the geom
to use. Using the default will give you a standard plot; overriding the default
allows you to achieve something more exotic; as shown in section 4.9.1

position (optional): Choose a method for adjusting overlapping objects, as shown
described in section 4.8

# The order of data and mapping arguments is switched between ggplot() and the
# layer functions. THis is because you almost always specify data for the plot,
# and almost always specify aesthetics - but not data - for the layers. 
# Explicitly name all other arguments for readability

# Equivalents
# scatter plot, msleep is data, % of sleep on x, awake on y
ggplot(msleep, aes(sleep_rem / sleep_total, awake)) + geom_point()
qplot(sleep_rem / sleep_total, awake, data = msleep)

qplot(sleep_rem / sleep_total, awake, data = msleep) + geom_smooth()
qplot(sleep_rem / sleep_total, awake, data = msleep, geom = c('point','smooth'))
ggplot(msleep, aes(sleep_rem / sleep_total, awake)) + geom_point() +
    geom_smooth()

# To explore a plot do summary(plot_object)
p <- ggplot(msleep, aes(sleep_rem / sleep_total, awake))
summary(p)
p <- p + geom_point()

# Layers are regular R objects that can be stored as variables, so you can write
# clean code. Create the layer once, add it many times.
bestfit <- geom_smooth(method = 'lm', se = T, colour = alpha('steelblue', 0.5),
                       size = 2)
qplot(sleep_rem, sleep_total, data=msleep) + bestfit
q <- qplot(awake, brainwt, data = msleep, log = 'y') + bestfit
q <- qplot(bodywt, brainwt, colour = genus, data = msleep, log = 'xy') + bestfit


#*************************************************************************
#                            4.4 DATA                                    *
#*************************************************************************
# The data must be a dataframe. That's the only restriction

p <- ggplot(mtcars, aes(mpg, wt, colour = cyl)) + geom_point()
mtcars <- transform(mtcars, mpg = mpg ^ 2)
# can change the data and update p
p %+% mtcars
# the data is stored in the plot object as a copy, not as a reference. 
# If your data changes, the plot will not. Also plots are entirely 
# self-contained so they can be save()d to disk and later load()ed and plotted 
# without needing anyting else from that session

#*****************************************************************************
#                            4.5 Aestetic Mappings                           *
#*****************************************************************************

aes(x = weigth, y = height, colour = age)
# dont refer to variables outside of dataset by like diamonds$carat
aes(x = weight, y = height, colour = sqrt(age))
# functions of variables can be used
# any varibale in aes() must be contained in plot or layer data


#********************** 4.5.1 Plots and Layers *****************************
# can add the aesthetics after creating plot
data(mtcars)
p  <- ggplot(mtcars)
p <- p + aes(wt, hp)
# or at same time
p <- ggplot(mtcars, aes(wt, hp))

p <- ggplot(mtcars, aes(x = mpg, y = wt))
p + geom_point()
p + geom_point(aes(colour = factor(cyl)))
p + geom_point(aes(y = disp))

# Aesthetic mappings specified in a layer affect only that layer. For that reason,
# unless you modify the default scales, axis labels and legend titles will be
# based on the plot defaults. See section 6.5 to see how to change these.

#********************** 4.5.2 Setting v Mapping ******************************
# Instead of mapping an aesthetic property to a variable, you can set it to a 
# single value by specifying it in the layer parameters.
# Aesthetics can vary for each observation being plotted, while parameters do
# not.  We map an aesthetic to a variable (eg (aes(colour=cut))) or set it to a
# constant (eg colour='red'). 
p <- ggplot(mtcars, aes(mpg, wt))
p + geom_point(colour = 'darkblue') # This sets the point colour to be dark blue
# instead of black. This is quite different than
p + geom_point(aes(colour = 'darkblue')) # This maps (not sets) the colour to
# the value 'darkblue'. This effectively creates a new variable containing only
# the value 'darkblue' and then maps colour to that new variable. 

# You can map with qplot by doing colour = I('darkblue') 
 
#*********************** 4.5.3 Grouping *************************************
# in ggplot2, geoms can be roughly divided into invidual and collective geoms.
# point geoms has a single object for each observation
# polygons have multile
# lines and paths fall somewhere in between

# By default gropu is set to the interaction of all discrete variables in the
# plot. This often partitions the data correctly, but when it does not, or when 
# no discrete variable is used in the plot, you will need to explicitly define 
# the grouping structure, by mapping group to a variable that has a different 
# value for each group. The intersection() function is a useful if a single 
# pre-existing variable doesn't cleanly separate groups, but a combination does.

require(nlme)
data(Oxboys)

# There are three common cases where the default is not enough.

# 1. Multiple Groups, one aesthetic
# You want to separate your data into groups, but render them in the same way.
# When looking at the data in aggregate you want to be able to distinguish
# individual subjects, but not identify them. This is common in longitudinal
# studies with many subjects, where the plots are often descriptively called
# spaghetti plots. 
p <- ggplot(Oxboys, aes(age, height)); p # this is gibberish
p <- ggplot(Oxboys, aes(age, height, group = Subject)) + geom_line()

# 2. Different groups on different layers
p + geom_smooth(aes(group = Subject), method = 'lm', se = F) #smooths each line
p + geom_smooth(aes(group = 1), method = 'lm', se = F, size =2)#one smoothing
# line

# 3. Overriding the default grouping
# The plot has a discrete scale but you want to draw lines that connect across
# groups. This is a strategy used in interaction plots, profile plots, and
# parallel coordinate plots, among others. For example, we draw boxplots of
# height at each measurement occasion, as shown in the first figure in 4.5.
boysbox <- ggplot(Oxboys, aes(Occasion, height)) + geom_boxplot()
boysbox + geom_line(aes(group = Subject), colour = '#3366FF')

#*********************** 4.5.4 Matching aesthetics to graphic objects *******
# Another important issue with collective geom is how the aesthetics of the
# individual observations are mapped to the aesthetics of the complete entity.
# For individual geoms, this isn't a problem. However, high data densities can
# make it difficult or impossible to distinguish between individual points and
# in some sense the point geom becomes a collective geom, a single blob of
# points 

xgrid <- with(df, seq(min(x), max(x), length = 50))
data(diamonds)
ggplot(diamonds, aes(color)) + geom_histogram()
ggplot(diamonds, aes(color, fill = cut)) + geom_histogram()
#Nice!

#*****************************************************************************
#                            4.6 Geoms
#*****************************************************************************
# Geoms perform the actual rendering of the layer, controlling the type of plot
# you create. For example, using a point_geom will create a scatter plot, while
# using a line geom will create a line plot. 

#*****************************************************************************
#                            4.7 Stat
#*****************************************************************************

# A statistical transformation, or stat, transforms the data, typically by
# summarising it in some manner. For example, a useful stat is the smoother,
# which calculates the mean of y, conditional on x, subject to some restriction
# that ensures smoothness.
# To make sense in a graphic context a stat must be location-scale invariant.
# f(x+a) = f(x) + a and f(b * x) = b * f(x). This ensures that the
# transformation stays the same when you change the scales of the plot.

# A stat takes a dataset as input and returns a dataset as output, and so a stat
# can add new variables to the original dataset.

# like here where we map the new stat aesthetic ..density..
# the names of the generated variable must be surrounded with .. which prevents
# confusion in case the original dataset has the same name, and makes it clear
# to anyone else reading the code
ggplot(diamonds, aes(carat)) + geom_histogram(aes(y = ..density..), binwidth =
                                              0.1)

# same thing in qplot
qplot(x = carat, y = ..density.., data = diamonds,  geom='histogram', binwidth = 0.1)

#*****************************************************************************
#                            4.8 Position Adjustments
#*****************************************************************************

# Position adjustments apply minor tweaks to the position of elements within a
# layer

# dodge - Adjust position by dodging overlaps to the side
# fill - stack overlapping objects and standardize have equal height
# identity - Don't adjust position
# jitter - jitter points to avoid overplotting
# stack - Stack overlapping objects on top of one another

#*****************************************************************************
#                            4.9 Putting it all together
#*****************************************************************************

data(diamonds)
fig4.8a <- ggplot(diamonds, aes(clarity, fill = cut)) + geom_histogram()
fig4.8b <- ggplot(diamonds, aes(clarity, fill = cut)) + 
                geom_bar(position = 'fill')
fig4.8c <- ggplot(diamonds, aes(clarity, fill = cut)) + geom_bar(position =
                                                                 'dodge')

# nice!


############################ 4.9.1 Combining Geoms and Stats ###############
# by connecting geoms with different statistics, you can easily create new
# graphics. 

# variations on a histogram
d <- ggplot(diamonds, aes(carat)) + xlim(0, 3)
d + stat_bin(aes(ymax = ..count..), binwidth = 0.1, geom = 'area')
d + stat_bin(
  aes(size = ..density..), binwidth = 0.1, 
  geom = 'point', position = 'identity')
d + stat_bin(
  aes(y = 1, fill = ..count..), binwidth = 0.1, geom = 'tile', position =
        'identity')

############################ 4.9.2 Displaying precomputed statistics ########
# If you have data which has already been summarised, and you just want to use 
# it, you'll need to use stat_identity(), which leaves the data unchanged, and 
# then map the appropriate variables to the right aesthetics

############################ 4.9.3 Varying aesthetics and data ##############
# You can plot two different datasets on different layers. 
# One reason to do this: show actual values and predicted values
require(nlme, quiet = TRUE, warn.conflicts = FALSE)
model <- lme(height ~ age, data = Oxboys, random = ~1 + age | Subject)
oplot <- ggplot(Oxboys, aes(age, height, group = Subject)) + geom_line()

age_grid <- seq(-1, 1, length = 10)
subjects <- unique(Oxboys$Subject)
# expand.grid creates a dataframe from all combinations of supplied vectors or
# factors
preds <- expand.grid(age = age_grid, Subject = subjects)
preds$height <- predict(model, preds)

oplot + geom_line(data = preds, colour = '#3366FF', size = 0.4)

Oxboys$fitted <- predict(model)
Oxboys$resid <- with(Oxboys, fitted - height)

oplot %+% Oxboys + aes(y = resid) + geom_smooth(aes(greuup=1))
