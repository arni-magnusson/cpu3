# Produce plots and tables for report

# Before: info.csv (data), catage.csv (output)
# After:  speed.csv, speed.png (report)

library(TAF)
library(ggplot2)
source("utilities.R")

mkdir("report")

# Read data
info <- read.taf("data/info.csv")
catage <- read.taf("output/catage.csv")

# Chronological order of machines (info.csv lists oldest first)
info <- info[info$machine %in% catage$machine,]
catage$machine <- factor(catage$machine, levels=info$machine)

# Prepare plot
cpu <- paste("Intel", sub(" ", "-", info$processor))
catage$label <- factor(catage$machine, levels=info$machine,
                       labels=paste(info$name, cpu, sep="\n"))
catage$job <- factor(catage$job, levels=c("sustained", "short"),
                     labels=c("Sustained", "Short"))

# Barplot
p <- ggplot(catage, aes(x=speed, y=label, fill=job)) +
  geom_col(position=position_dodge(width=0.75), width=0.7) +
  scale_fill_manual(values=c(Short="#8FB8DE", Sustained="#1F3A5F"),
                    guide=guide_legend(reverse=TRUE)) +
  scale_x_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title="Speed measurements", x="Speed (model iterations / sec)") +
  themeReport()

taf.png("speed")
print(p)
dev.off()

# Prepare summary table
speed <- aggregate(speed~machine, catage, mean)
speed$relative <- speed$speed / min(speed$speed)
speed <- rnd(speed, 2:3, 1:2)

# Write table
write.taf(speed, dir="report")
