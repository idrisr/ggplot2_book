##############################################################################
# 3. Mastering the Grammar
##############################################################################

require(ggplot2)
data(mpg)

# How are engine size and fuel economy related?
# Do certain manufacturers care more about economy than others?
# Has fuel economy improved in the last ten years?

##############################################################################
# 3.3 Building a Scatterplot
##############################################################################

qplot(displ, hwy, data = mpg, colour = factor(cyl))

# Mapping aesthetics to data
# What is a scatterplot? It represents each observation as a point, positioned
# according to the value of two variables. Each point also has a size, colour,
# and a shape. These attributes are called aesthetics, and are the properties
# that can be perceived on the graphic. 
# Each aesthetic can be mapped to a variable, or set to a constant value. 
# In the above plot, displ is mapped to horizontal position, hwy to a vertical
# position and cyl to colour. Size and shape are not mapped to variables, but
# remain at their (constant) defaults. 

# Points, lines, and bars are all examples of geometric objects, or geoms. Geoms
# determine the 'type' of plot. Plots that use a single geom are often given a
# special name like:

# Named Plots               Geom                 Other Features
# --------------            -----------------    ------------------------
# scatterplot               point
# bubbleplot                point                size mapped to variable
# barchart                  bar            
# box-and-whisker           boxplot
# line chart                line 

# Scaling
# Process of converting units (like mpg, cms, $, etc) to physical units like
# pixels and colors.
# In the above example, we have three aesthetics that need to be scaled:
# horizontal position(x)
# vertical position(y)
# colour

# scaling uses the default linear scales
# many ways to scale colour, but in this example and by default, the factor
# levels of cyl are mapped to evenly spaced values on the color wheel.

# Finally, we need to render this data to create the graphical objects that are
# displayed on the screen. To create a complete plot we need to combine
# graphical objects from three sources: 
# 1. the data, represented by the point geom
# 2. the scales and the coordinate system. 
# 3. the plot annotations, such as the background and plot title

##############################################################################
# 3.4 A More Complex Plot
##############################################################################
# let's add more components
# facets, multiple layers, and statistics
# The facets and layers expand the data structure described above
# Each facet panel in each layer has its own dataset
qplot(displ, hwy, data = mpg, facets = . ~ year) + geom_smooth()
# The smooth layer is different to the point layer because it doesn't display
# the raw data, but instead displays a statistical transformation of the data.
# Specifically, the smooth layers fits a smooth line through the middle of the
# data. This requries an additional step in the process described above: after
# mapping the data to aethetics, the data is passed to a statistical
# transformation, or stat, which manipulates the data in some useful way. In
# this example, the stat fits the data to a loess smoother, and then returns
# predictions from evenly spaced points within the range of the data. 
# Other useful stats include 1d and 2d binning, group means, quantile regression,
# and contouring

# Scale transformation occurs before stats transformation so that stats are
# computed on the scale-transformed data. This ensures that a plot of log(x) vs.
# log(y) on linear scales looks the same as x vs. y on log scales. 
# Other transformations: taking square roots, logarithms, and reciprocals. 

# Together, the data, mappings, stat, geom and position adjustment form a layer.
# A plot may have multiple layers, as in the example where we overlaid a 
# smoothed line on a scatter plot.

# all together, the layered grammer defines a plot as the combination of:
# 1. A default dataset and a set of mappings from variables to aesthetics
# 2. One or more layers, each composed of a geometric object, a statistical
#    tranformatioon, and a position adjustment, and optionally, a dataset and
#    aesthetic mappings 
# 3. One scale for each aesthetic mapping 
# 4. A coordinate system
# 5. The faceting specification

######################### 3.5.1 Layers ######################################
# Layers are responsible for creating the objects that we perceive on the plot. 
# A layer is composed of four parts:
# 1. data and aesthetic mapping
# 2. a statistical transformation (the tranform can be just to ..identity..)
# 3. a geometric object (geom)
# 4. and a position adjustment.
# The properties of a layer are described in Ch 4 and how they can be used to
# visualize data in Ch 5.

######################### 3.5.2 Scales ######################################
# A scale controls the mapping from data to aesthetic attributes, and we need a
# scale for every aesthetic used on a plot. Each scale operates across all the
# data in the plot, ensuring a consistent mapping from data to aesthetics. 
# 
# A scale is a function, and its inverse, along with a set of parameters. For
# example, the colour gradient scale maps a segment of the real line to a path
# through a color space. The parameters of the function define whether the path
# is linear or curved, which colour space to use (eg LUV or RGB), and the
# colours at the start and end.

# The inverse function is used to draw a guide so that you can read values from
# the graph. Guides are either axes (for position scales) or legends(for
# everything else). Most mappings have a unique inverse (ie, the mapping
# function is one-to-one), but many do not. A unique inverse makes it possible
# to recover the original data, but this is not always desirable if we want to
# focus attention on a single object. 
# Ch 6 describes scales in more detail

######################### 3.5.3 Coordinate System ##########################
# A coordinate system, or coord for short, maps the position of objects onto the
# plane of the plot. Position is ofen specified by two coordinates (x, y).
# Coordinate systems affect all position variables simultaneously and differ
# from scales in that they also change the appearance of the geometric objects. 
# Scaling is performed before statistical transformation, while coordinate
# transformations occur afterward. 
# Coordinate systems control how the axes and grid lines are drawn.  
# examples of coord: Cartesian, loglog, polar

######################### 3.5.4 Faceting ####################################
# Faceting is a general case of the contioned or trellised plots. This makes it
# easy to create small multiples each showing a different subset of the whole
# dataset. This is a powerful tool when investigating whether patters hold
# across all conditions.

##############################################################################
# 3.6 Data Structures
##############################################################################
# a plot object is a list with components: data, mapping (the default aesthetic
# mappings), layers, scales, coordinates, and facet. 

# The plot object has one more very important component: options
# This is used to store the plot-specific them options described in chapter 8.
# Once the plot is created, several ways to print it:
# print()
# ggsave()
# describe its summary with summary()
# save a cached copy to disk with save(). This saves a complete copy of the plot
# object, so you can easily re-create that exact plot with load(). Note that
# data is stored inside the plot, so that if you change the data outside of the
# plot, and the redraw the saved plot, it will not be updated. 

