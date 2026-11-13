# Prepare data, write CSV data tables

# Before: catage.dat, info.csv (boot/data)
# After:  catage.csv, info.csv (data)

library(TAF)

mkdir("data")

# Read data
info <- read.taf("boot/data/info.csv")
catage <- read.table("boot/data/catage.dat", header=TRUE)

# Write table
write.taf(info, dir="data")
write.taf(catage, dir="data")
