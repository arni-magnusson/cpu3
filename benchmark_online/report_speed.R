# Plot speed (single thread) over time

# Before: i7_high.csv, i7_low.csv, i7_medium.csv, r7_high.csv,
#         r7_low.csv (output)
# After:  speed_all.png, speed_high.png, speed_low.png,
#         speed_medium.png (report)

library(TAF)
library(ggplot2)
source("utilities.R")  # themeReport

mkdir("report")

# Read tables
i7.high <- read.taf("output/i7_high.csv", colClasses=c(Date="Date"))
i7.medium <- read.taf("output/i7_medium.csv", colClasses=c(Date="Date"))
i7.low <- read.taf("output/i7_low.csv", colClasses=c(Date="Date"))
r7.high <- read.taf("output/r7_high.csv", colClasses=c(Date="Date"))
r7.low <- read.taf("output/r7_low.csv", colClasses=c(Date="Date"))

# Prepare for plotting
score <- "Score (PassMark single thread)"
cols <- c(Intel="#1F3A5F", AMD="#D98E3F")
series <- function(x, company, id)
  data.frame(Series=id, Company=factor(company, levels=names(cols)),
             Date=x$Date, Speed=x$Speed)
intel.high <- series(i7.high[-1,], "Intel", "Intel high")
intel.medium <- series(i7.medium, "Intel", "Intel medium")
intel.medium1 <- series(i7.medium[-1,], "Intel", "Intel medium")
intel.low <- series(i7.low[-1,], "Intel", "Intel low")
amd.high <- series(r7.high, "AMD", "AMD high")
amd.low <- series(r7.low, "AMD", "AMD low")

# Axes and colors shared by all plots
speed <- list(
  geom_line(linewidth=0.7), geom_point(size=2),
  scale_colour_manual(values=cols),
  scale_x_date(limits=as.Date(c("2010-01-01", "2027-01-01")),
               breaks=seq(as.Date("2010-01-01"), by="2 years", length.out=9),
               date_labels="%Y", expand=expansion(mult=0.02)),
  scale_y_log10(limits=c(700, 4400), breaks=c(1000, 1500, 2000, 3000, 4000))
)

# Plot speed over time
taf.png("speed_all", width=1200)
p <- ggplot(rbind(intel.high, amd.high, intel.medium, intel.low, amd.low),
            aes(x=Date, y=Speed, colour=Company, group=Series)) +
  speed +
  labs(title="Intel and AMD (high/medium/low power)", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

taf.png("speed_high", width=1200)
p <- ggplot(rbind(intel.high, amd.high),
            aes(x=Date, y=Speed, colour=Company, group=Series)) +
  speed +
  labs(title="Intel and AMD (high power)", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

taf.png("speed_low", width=1200)
p <- ggplot(rbind(intel.low, amd.low),
            aes(x=Date, y=Speed, colour=Company, group=Series)) +
  speed +
  labs(title="Intel and AMD (low power)", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

taf.png("speed_medium", width=1200)
p <- ggplot(intel.medium1, aes(x=Date, y=Speed, colour=Company, group=Series)) +
  speed +
  labs(title="Intel (medium power)", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()
