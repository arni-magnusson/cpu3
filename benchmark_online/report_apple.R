# Plot comparison plots for Apple, Intel, and AMD

# Before: apple.csv, companies.csv (data)
#         companies_fit.csv, companies_lag.csv, i7_high.csv,
#         r7_high.csv (output)
# After:  companies_data.png, companies_fit.png, companies_lag.png,
#         companies_macbook.png (report)

library(TAF)
library(ggplot2)
source("utilities.R")  # themeReport

mkdir("report")

# Read tables
apple <- read.taf("data/apple.csv", colClasses=c(Date="Date"))
companies <- read.taf("data/companies.csv", colClasses=c(Date="Date"))
companies.fit <- read.taf("output/companies_fit.csv", colClasses=c(Date="Date"))
companies.lag <- read.taf("output/companies_lag.csv")
i7.high <- read.taf("output/i7_high.csv", colClasses=c(Date="Date"))
r7.high <- read.taf("output/r7_high.csv", colClasses=c(Date="Date"))

# Prepare for plotting
score <- "Score (PassMark single thread)"
cols <- c(Apple="#B83A4B", Intel="#1F3A5F", AMD="#D98E3F")
companies$Company <- factor(companies$Company, levels=names(cols))
companies.fit$Company <- factor(companies.fit$Company, levels=names(cols))
speed.y <- scale_y_log10(breaks=c(1000, 2000, 3000, 4000, 6000))

# Companies: Apple vs Intel vs AMD
taf.png("companies_data", width=1200)
p <- ggplot(companies, aes(x=Date, y=Speed, colour=Company)) +
  geom_point(size=2) +
  scale_colour_manual(values=cols) +
  speed.y +
  labs(title="Processor performance by company", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

# Companies with fitted regression lines
taf.png("companies_fit", width=1200)
p <- ggplot(companies, aes(x=Date, y=Speed, colour=Company)) +
  geom_point(size=2) +
  geom_line(data=companies.fit, linewidth=0.9) +
  scale_colour_manual(values=cols) +
  speed.y +
  labs(title="Processor performance by company", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

# Lag between companies
taf.png("companies_lag")
companies.lag$Company <- reorder(companies.lag$Company, companies.lag$Lag)
p <- ggplot(companies.lag, aes(x=Company, y=Lag, fill=Company)) +
  geom_col(width=0.7) +
  scale_fill_manual(values=cols, guide="none") +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title="Lag until company reaches the CPU performance\nof the best company",
       x=NULL, y="Lag (yrs)") +
  themeReport(grid="y")
plot(p)
dev.off()

# MacBook Air vs Pro
apple$Type <- factor(ifelse(grepl("Pro", apple$Model), "Pro", "Air"),
                     levels=c("Pro", "Air"))
taf.png("companies_macbook", width=1200)
p <- ggplot(apple, aes(x=Date, y=Speed, shape=Type)) +
  geom_point(size=2.5, colour=cols[["Apple"]]) +
  scale_shape_manual(values=c(Pro=19, Air=1)) +
  scale_y_log10(breaks=c(3500, 4000, 4500, 5000, 6000)) +
  labs(title="Apple MacBook", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()
