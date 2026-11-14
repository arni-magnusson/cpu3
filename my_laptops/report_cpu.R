# Plot CPU variables

# Before: specs.csv, speed_fit.csv (output)
# After:  cpu_cache.png, cpu_cores.png, cpu_efficiency.png, cpu_freq.png,
#         cpu_nm.png, cpu_speed_data.png, cpu_speed_fit.png, cpu_speed_freq.png,
#         cpu_speed_nm.png, cpu_speed_watt.png, cpu_threads.png,
#         cpu_watt.png (report)

library(TAF)
library(ggplot2)
source("utilities.R")  # dateAxis, formPoints, themeReport

mkdir("report")

# Read data
specs <- read.taf("output/specs.csv", colClasses=c(Date="Date"))
speed.fit <- read.taf("output/speed_fit.csv", colClasses=c(Date="Date"))

# Prepare for plotting
score <- "Score (PassMark single thread)"
specs$Form <- factor(specs$Form,
                     levels=c("Workstation", "Intermediate", "Ultraportable"))

# Univariate time series
taf.png("cpu_cache")
values <- c("0.5", "1", "2", "4", "8", "16", "32")
p <- ggplot(specs, aes(x=Date, y=Cache)) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(0.4, 32), breaks=as.numeric(values), labels=values,
                expand=expansion(0)) +
  labs(title="CPU: On-chip memory", x=NULL, y="Cache (MB)") +
  themeReport()
plot(p)
dev.off()

taf.png("cpu_cores")
p <- ggplot(specs, aes(x=Date, y=Cores)) +
  formPoints() +
  dateAxis() +
  scale_y_continuous(limits=c(0.5, 8.5), breaks=c(1, 2, 4, 6, 8),
                     expand=expansion(0)) +
  labs(title="CPU: Processing units", x=NULL, y="Number of cores") +
  themeReport()
plot(p)
dev.off()

taf.png("cpu_efficiency")
p <- ggplot(specs, aes(x=Date, y=Speed/W)) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(4.4, 160), breaks=c(5, 10, 20, 50, 100),
                expand=expansion(0)) +
  labs(title="CPU: Efficiency", x=NULL,
       y="Single-thread performance per watt") +
  themeReport()
plot(p)
dev.off()

taf.png("cpu_freq")
p <- ggplot(specs, aes(x=Date, y=Turbo/1000)) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(2, 6), breaks=2:6, expand=expansion(0)) +
  labs(title="CPU: Maximum frequency", x=NULL, y="Turbo (GHz)") +
  themeReport()
plot(p)
dev.off()

taf.png("cpu_nm")
p <- ggplot(specs, aes(x=Date, y=nm)) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(2.5, 150), breaks=c(5, 10, 20, 50, 100),
                expand=expansion(0)) +
  labs(title="CPU: Semiconductor technology", x=NULL,
       y="Process node (nm)") +
  themeReport()
plot(p)
dev.off()

taf.png("cpu_speed_data")
p <- ggplot(specs, aes(x=Date, y=Speed)) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(350, 5000), breaks=c(500, 1000, 2000, 5000),
                expand=expansion(0)) +
  labs(title="CPU: Benchmark performance", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

taf.png("cpu_speed_fit")
p <- ggplot(specs, aes(x=Date, y=Speed)) +
  geom_line(data=speed.fit, colour="#1F3A5F", linewidth=0.8) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(350, 5000), breaks=c(500, 1000, 2000, 5000),
                expand=expansion(0)) +
  labs(title="CPU: Performance trend", x=NULL, y=score) +
  themeReport()
plot(p)
dev.off()

taf.png("cpu_threads")
p <- ggplot(specs, aes(x=Date, y=Threads)) +
  formPoints() +
  dateAxis() +
  scale_y_continuous(limits=c(0.5, 16.5), breaks=c(1, 2, 4, 6, 8, 10, 12, 14, 16),
                     expand=expansion(0)) +
  labs(title="CPU: Parallel processing capacity", x=NULL,
       y="Number of threads") +
  themeReport()
plot(p)
dev.off()

taf.png("cpu_watt")
p <- ggplot(specs, aes(x=Date, y=W)) +
  formPoints() +
  dateAxis() +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  expand_limits(y=0) +
  labs(title="CPU: Processor power", x=NULL, y="Thermal design power (W)") +
  themeReport()
plot(p)
dev.off()

# Relationships between variables
taf.png("cpu_speed_freq")
p <- ggplot(specs, aes(x=Turbo/1000, y=Speed)) +
  formPoints() +
  scale_x_log10(breaks=seq(2.5, 5.5, 0.5), expand=expansion(mult=0.05)) +
  scale_y_log10(limits=c(350, 5000), breaks=c(500, 1000, 2000, 5000),
                expand=expansion(0)) +
  labs(title="CPU: Frequency and performance", x="Turbo (GHz)", y=score) +
  themeReport()
plot(p)
dev.off()

taf.png("cpu_speed_nm")
p <- ggplot(specs, aes(x=sqrt(nm), y=Speed)) +
  formPoints() +
  scale_x_continuous(breaks=seq(2, 10, 2), expand=expansion(mult=0.05)) +
  scale_y_log10(limits=c(350, 5000), breaks=c(500, 1000, 2000, 5000),
                expand=expansion(0)) +
  labs(title="CPU: Performance and semiconductor technology",
       x="sqrt(Process node)", y=score) +
  themeReport()
plot(p)
dev.off()
