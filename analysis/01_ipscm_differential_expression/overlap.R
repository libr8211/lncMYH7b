## For all my R stuff I use this package called the "tidyverse" - which is basically a collection of R packages that play really well together. So you'll need to install that first. You only have to do this part once on your computer... once it's installed, all you have to do is attach it later (you don't have to install it every time)

install.packages("tidyverse")  

# To use the package, you have to attach it
library(tidyverse)

# Within the tidyverse you use read_csv to read in your data. Note that it will have to be saved as a .csv, not an excel file, so you'll have to "Save As" in Excel to get a .csv format.
# This step reads in your data as data frames, called 'data1' and 'data2'

data1 <- read_csv("../../ipscm_rnaseq/results/res_shrunken_spoe.csv")
data2 <- read_csv("../../ipscm_rnaseq/results/res_shrunken_asokd.csv")

# Now you should see that "data1" and "data2" pop up in your "environment" in the top right corner of RStudio. If you click on them, they'll pop up and you can look at them like they're regular tables, except in R, which I'm sure you've done before. Yay!

# Therea are also some easy basic ways to filter out/select data using tidyverse style commands.. like ways to say you only want these rows, or these columns, etc.... so if you need to do that, let me know. But for just seeing what matches, you'll use the "join" function from dplyr (which is another package but its included in the tidyverse collection so you already have it!)

#  There are a lot of different kinds of "joins" depending on what you're trying to do, which you can see by running the help command
?join

# If you're just trying to return what matches from each of your datasets, you'll use "inner_join", which will return all of the columns from both your data frames, but only the rows from data1 that have matches in data2. If you want to be specific about what needs to match, you'll add "by = variable" as an argument. Ex: if I wanted to see the matches from a specific column
data3 <- inner_join(data1, data2, by = "geneID")

# Note that line will store your new data as data3, so you'll need to call it to see it, or click on it. If you want to export it, you can write it as a csv...
write_csv(data3, "new_name_new_data.csv")
