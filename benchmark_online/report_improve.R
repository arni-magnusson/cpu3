# Plot relative improvement for each processor generation

# Before: i7_high.csv, i7_low.csv, i7_medium.csv, r7_high.csv,
#         r7_low.csv (output)
# After:  improve_amd_high.png, improve_amd_low.png, improve_intel_high.png,
#         improve_intel_low.png, improve_intel_medium.png (report)

library(TAF)
library(ggplot2)
source("utilities.R")  # implot, themeReport

mkdir("report")

# Read tables
i7.high <- read.taf("output/i7_high.csv", colClasses=c(Date="Date"))
i7.medium <- read.taf("output/i7_medium.csv", colClasses=c(Date="Date"))
i7.low <- read.taf("output/i7_low.csv", colClasses=c(Date="Date"))
r7.high <- read.taf("output/r7_high.csv", colClasses=c(Date="Date"))
r7.low <- read.taf("output/r7_low.csv", colClasses=c(Date="Date"))

# Prepare for plotting
intel <- "#1F3A5F"
amd <- "#D98E3F"

# Plot improvement
taf.png("improve_amd_high")
p <- implot(r7.high[-1,], "AMD (high power)", amd)
plot(p)
dev.off()

taf.png("improve_amd_low")
p <- implot(r7.low, "AMD (low power)", amd)
plot(p)
dev.off()

taf.png("improve_intel_high")
p <- implot(i7.high[-1,], "Intel (high power)", intel)
plot(p)
dev.off()

taf.png("improve_intel_low")
p <- implot(i7.low[-1,], "Intel (low power)", intel)
plot(p)
dev.off()

taf.png("improve_intel_medium")
p <- implot(i7.medium, "Intel (medium power)", intel)
plot(p)
dev.off()
