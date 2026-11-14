# Produce plots and tables for report

# Before: info.csv (data), m4700.rds, p1gen8.rds, p15gen1.rds, p3560.rds (model)
#         summary.csv (output)
# After:  comparison.png, desc.csv, each.png, summary.csv (report)

library(TAF)
library(ggplot2)
source("utilities.R")  # longform, themeReport

mkdir("report")

# Read data
info <- read.taf("data/info.csv")
m4700 <- readRDS("model/m4700.rds")
p1gen8 <- readRDS("model/p1gen8.rds")
p15gen1 <- readRDS("model/p15gen1.rds")
p3560 <- readRDS("model/p3560.rds")
summary <- read.taf("output/summary.csv")

# Prepare plot elements
iter <- seq(1:nrow(m4700$idle))
machines <- list(m4700=m4700, p15gen1=p15gen1, p3560=p3560, p1gen8=p1gen8)

# Smooth m4700
smooth_m4700 <- m4700
smooth_m4700$full$Watt <- mean(m4700$full$Watt)
smooth_m4700$main$Watt <- mean(m4700$main$Watt)
smooth_m4700$single$Watt <- mean(m4700$single$Watt)
smooth_m4700$idle$Watt <- mean(m4700$idle$Watt)

# Smooth p1gen8
smooth_p1gen8 <- p1gen8
smooth_p1gen8$full$Watt <- loess(Watt~iter, p1gen8$full, span=0.4)$fitted
smooth_p1gen8$main$Watt <- loess(Watt~iter, p1gen8$main, span=0.4)$fitted
smooth_p1gen8$single$Watt <- loess(Watt~iter, p1gen8$single, span=0.6)$fitted
smooth_p1gen8$idle$Watt <- mean(p1gen8$idle$Watt)

# Smooth p15gen1
smooth_p15gen1 <- p15gen1
smooth_p15gen1$full$Watt <- loess(Watt~iter, p15gen1$full, span=0.9)$fitted
smooth_p15gen1$main$Watt <- loess(Watt~iter, p15gen1$main, span=0.9)$fitted
smooth_p15gen1$single$Watt <- loess(Watt~iter, p15gen1$single, span=0.9)$fitted
mean(p15gen1$idle$Watt)

# Smooth p3560
smooth_p3560 <- p3560
smooth_p3560$full$Watt <- loess(Watt~iter, p3560$full, span=0.11)$fitted
smooth_p3560$main$Watt <- loess(Watt~iter, p3560$main, span=0.21)$fitted
stable <- replace(p3560$single$Watt, 120:300, mean(p3560$single$Watt[120:300]))
smooth_p3560$single$Watt <- loess(stable~iter, span=0.30)$fitted
smooth_p3560$idle <- mean(p3560$idle$Watt)

# Prepare for plotting
ids <- c("m4700", "p15gen1", "p3560", "p1gen8")  # chronological order
labels <- paste(info$name, paste("Intel", sub(" ", "-", info$processor)),
                sep="\n")[match(ids, info$machine)]
states <- c("idle", "single", "main", "full")
variables <- c(Freq="Frequency (MHz)", Temp="Temperature (\u00b0C)",
               Watt="Power (W)")
machine.cols <- setNames(c("#1F3A5F", "#D98E3F", "#2A9D8F", "#8E5EA2"), labels)
state.cols <- c(idle="grey55", single="#1F3A5F", main="#D98E3F", full="#B83A4B")
x <- longform(machines)
x$machine <- factor(x$machine, levels=ids, labels=labels)
x$state <- factor(x$state, levels=states)
x$variable <- factor(x$variable, levels=names(variables))
axes <- list(
  scale_x_continuous(breaks=c(0, 100, 200, 300), limits=c(0, 300)),
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))),
  expand_limits(y=0),
  labs(x="Iteration", y=NULL)
)

# Plot each machine
taf.png("each", 3600, 2400, res=300)
p <- ggplot(x, aes(x=iteration, y=value, colour=state)) +
  geom_point(size=0.8) +
  facet_grid(variable~machine, scales="free_y", switch="y",
             labeller=labeller(variable=variables)) +
  scale_colour_manual(values=state.cols, labels=tools::toTitleCase) +
  guides(colour=guide_legend(nrow=1, override.aes=list(size=3))) +
  axes +
  themeReport()
plot(p)
dev.off()

# Plot machine comparison
taf.png("comparison", 3600, 2400, res=300)
p <- ggplot(x, aes(x=iteration, y=value, colour=machine)) +
  geom_point(size=0.8) +
  facet_grid(variable~state, scales="free_y", switch="y",
             labeller=labeller(variable=variables, state=tools::toTitleCase)) +
  scale_colour_manual(values=machine.cols) +
  guides(colour=guide_legend(nrow=1, override.aes=list(size=3))) +
  axes +
  themeReport()
plot(p)
dev.off()

# Round and divide values
summary <- rnd(summary, grep("idle|single|main|full|spike", names(summary)), -2)
summary <- div(summary, grep("idle|single|main|full|spike", names(summary)))
summary <- rnd(summary, grep("watt", names(summary)))

# Compact description
desc <- data.frame(machine=summary$machine,
                   freq.idle=summary$idle,
                   freq.work=paste0(summary$full2, "-", summary$single2),
                   freq.spike=summary$spike,
                   watt.idle=paste0(summary$watt0, "W"),
                   watt.work=paste0(summary$watt2, "-", summary$watt1, "W"),
                   spec=paste0(info$base, "-", info$turbo),
                   tdp=paste0(info$watt, "W"))

# Write table
write.taf(desc, dir="report")
write.taf(summary, dir="report")
