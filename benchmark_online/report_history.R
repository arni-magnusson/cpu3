# Plot long-term historical trends

# Before: history.csv (data)
#         history_analysis.csv, history_fit.csv, history_rate.csv (output)
# After:  history_companies_nm.png, history_companies_speed.png,
#         history_data.png, history_fit.png, history_rate.png,
#         history_time.png (report)

library(TAF)
library(ggplot2)
source("utilities.R")  # themeReport

mkdir("report")

# Read data
history <- read.taf("data/history.csv", colClasses=c(Date="Date"))
history.analysis <- read.taf("output/history_analysis.csv",
                             colClasses=c(Date="Date"))
history.fit <- read.taf("output/history_fit.csv", colClasses=c(Date="Date"))
history.rate <- read.taf("output/history_rate.csv")

# Prepare for plotting
score <- "Score (PassMark single thread)"
intel <- "History (Intel)"
cols <- c(Intel="#1F3A5F", AMD="#D98E3F")
history$Company <- factor(history$Company, levels=names(cols))
periods <- c(Early="#8FB8DE", Late="#1F3A5F")
history.analysis$Period <- factor(history.analysis$Period,
                                  levels=names(periods))
history.fit$Period <- factor(history.fit$Period, levels=names(periods))
history.rate$Period <- factor(history.rate$Period, levels=names(periods))
speed.y <- scale_y_log10(breaks=c(200, 500, 1000, 2000, 4000))

# Intel and AMD process
nm.values <- c(3, 4, 5.8, 7.2, 10, 14, 22, 28, 35, 45, 65, 90, 130, 180)
first <- rbind(
  data.frame(Company="AMD", aggregate(Date~nm, history, min,
                                      subset=Company=="AMD")),
  data.frame(Company="Intel", aggregate(Date~nm, history, min,
                                        subset=Company=="Intel")))
first$Company <- factor(first$Company, levels=names(cols))
taf.png("history_companies_nm", width=1200)
p <- ggplot(history, aes(x=Date, y=nm, colour=Company)) +
  geom_path(data=first, linewidth=0.9) +
  geom_point(size=2) +
  scale_colour_manual(values=cols) +
  scale_y_log10(limits=c(2.6, 200), breaks=nm.values,
                labels=round(nm.values)) +
  labs(title="Semiconductor technology over time", x=NULL,
       y="Process node (nm)") +
  themeReport(legend="topright")
plot(p)
dev.off()

# Intel and AMD speed
taf.png("history_companies_speed", width=1200)
p <- ggplot(history, aes(x=Date, y=Speed, colour=Company)) +
  geom_point(size=2) +
  scale_colour_manual(values=cols) +
  speed.y +
  labs(title="History (Intel and AMD)", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

# Intel observations
taf.png("history_data", width=1200)
p <- ggplot(history.analysis, aes(x=Date, y=Speed, shape=Period)) +
  geom_point(size=2, colour=cols[["Intel"]]) +
  scale_shape_manual(values=c(Early=1, Late=19)) +
  speed.y +
  labs(title=intel, x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

# Intel trends
taf.png("history_fit", width=1200)
p <- ggplot(history.analysis, aes(x=Date, y=Speed)) +
  geom_point(aes(shape=Period), size=2, colour=cols[["Intel"]]) +
  geom_line(data=history.fit, aes(group=Period), linewidth=0.9,
            colour=cols[["Intel"]]) +
  scale_shape_manual(values=c(Early=1, Late=19)) +
  speed.y +
  labs(title=intel, x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

# Intel annual improvement
taf.png("history_rate", width=1200)
p <- ggplot(history.rate, aes(x=Period, y=100*Annual, fill=Period)) +
  geom_col(width=0.6) +
  scale_fill_manual(values=periods, guide="none") +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title=intel, x=NULL, y="Annual improvement (%)") +
  themeReport(grid="y")
plot(p)
dev.off()

# Intel doubling time
taf.png("history_time", width=1200)
p <- ggplot(history.rate, aes(x=Period, y=Doubling, fill=Period)) +
  geom_col(width=0.6) +
  scale_fill_manual(values=periods, guide="none") +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title=intel, x=NULL, y="Doubling time (yr)") +
  themeReport(grid="y")
plot(p)
dev.off()
