# Produce plots and tables for report

# Before: catage.csv (output)
# After:  speed.csv, speed.png (report)

library(TAF)
library(ggplot2)
source("utilities.R")

mkdir("report")

# Read data
catage <- read.taf("output/catage.csv")

# Chronological order of machines
catage$machine <- factor(catage$machine,
                         levels=c("m4700", "p15gen1", "p3560", "p1gen8"))

# Prepare plot
catage$job <- factor(catage$job, levels=c("sustained", "short"),
                     labels=c("Sustained", "Short"))

# Barplot
p <- ggplot(catage, aes(x=speed, y=machine, fill=job)) +
  geom_col(position=position_dodge(width=0.75), width=0.7) +
  geom_text(aes(label=sprintf("%.1f", speed)),
            position=position_dodge(width=0.75), hjust=-0.2, size=4.2) +
  scale_fill_manual(values=c(Short="#8FB8DE", Sustained="#1F3A5F"),
                    guide=guide_legend(reverse=TRUE)) +
  scale_x_continuous(expand=expansion(mult=c(0, 0.1))) +
  scale_y_discrete(limits=rev) +
  labs(title="Speed measurements",
       subtitle="Catage benchmark, short and sustained runs",
       x="Speed (thousand MCMC iterations / sec)") +
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
