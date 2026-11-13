# Produce plots and tables for report
#
# Before: info.csv (data), catage.csv, passmark.csv, regression.csv (output)
# After:  benchmark.png, catage.csv, passmark.csv, regression.csv,
#         regression.png, speed.png (report)

library(TAF)
library(ggplot2)
source("utilities.R")  # themeReport

mkdir("report")

# Read data
info <- read.taf("data/info.csv")
catage <- read.taf("output/catage.csv")
passmark <- read.taf("output/passmark.csv")
regression <- read.taf("output/regression.csv")

# Establish processor order
ord <- catage$processor[order(catage$speed)]
catage <- catage[match(ord, catage$processor),]
passmark <- passmark[match(ord, passmark$processor),]
regression <- regression[match(ord, regression$processor),]
catage$processor <- ordered(catage$processor, catage$processor)
passmark$processor <- ordered(passmark$processor, passmark$processor)
regression$processor <- ordered(regression$processor, regression$processor)

# Machine labels in chronological order (info.csv lists oldest first)
info$key <- sub(" ", "-", info$processor)
info <- info[info$key %in% catage$processor,]
labels <- paste(info$name, paste("Intel", info$key), sep="\n")
label <- function(processor)
  factor(labels[match(as.character(processor), info$key)], levels=labels)

# Prepare for plotting
bar <- "#1F3A5F"
mark <- "#D98E3F"
tick <- 0.4  # half-height of marker, bars have half-height 0.35
bench <- data.frame(label=label(passmark$processor), local=passmark$local,
                    online=passmark$online)
speed <- data.frame(label=label(catage$processor), speed=catage$speed,
                    expected=catage$expected)

# Plot benchmark results
taf.png("benchmark")
p <- ggplot(bench, aes(y=label)) +
  geom_col(aes(x=local, fill="Local laptop"), width=0.7) +
  geom_segment(aes(x=online, xend=online, y=as.numeric(label)-tick,
                   yend=as.numeric(label)+tick, colour="Online average"),
               linewidth=1.5) +
  scale_fill_manual(values=c("Local laptop"=bar)) +
  scale_colour_manual(values=c("Online average"=mark)) +
  scale_x_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title="Synthetic benchmark results\n",
       x="Score (PassMark single thread)", y=NULL) +
  guides(fill=guide_legend(order=1), colour=guide_legend(order=2)) +
  themeReport(legend="bottomright", grid="x")
plot(p)
dev.off()

# Plot regression results
xlim <- c(0.9, 1.1) * range(regression$passmark)
ylim <- c(0.95, 1.05) * range(regression$actual)
taf.png("regression")
p <- ggplot(regression, aes(x=passmark, y=actual)) +
  geom_abline(slope=regression$slope[1], intercept=0, linetype=2,
              colour="grey35") +
  geom_point(size=2.5, colour=bar) +
  geom_text(aes(label=processor), vjust=-1, size=3.5, colour="grey20") +
  coord_cartesian(xlim=xlim, ylim=ylim, expand=FALSE) +
  labs(title="Actual speed vs. expectation\nbased on synthetic benchmark",
       x="Synthetic benchmark score",
       y="Actual speed (model iterations / sec)") +
  themeReport()
plot(p)
dev.off()

# Plot speed results
taf.png("speed")
p <- ggplot(speed, aes(y=label)) +
  geom_col(aes(x=speed, fill="Actual"), width=0.7) +
  geom_segment(aes(x=expected, xend=expected, y=as.numeric(label)-tick,
                   yend=as.numeric(label)+tick, colour="Expected"),
               linewidth=1.5) +
  scale_fill_manual(values=c(Actual=bar)) +
  scale_colour_manual(values=c(Expected=mark)) +
  scale_x_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title="Actual speed vs. expectation\nbased on synthetic benchmark",
       x="Speed (model iterations / sec)", y=NULL) +
  guides(fill=guide_legend(order=1), colour=guide_legend(order=2)) +
  themeReport(legend="bottomright", grid="x")
plot(p)
dev.off()

# Round tables
catage <- rnd(catage, 2:4, c(1,1,2))
catage$difference <- paste0(100 * catage$difference, "%")
passmark <- rnd(passmark, "difference", 2)
passmark$difference <- paste0(100 * passmark$difference, "%")
regression <- rnd(regression, c(2,4,5), c(1, 5, 1))

# Write tables
write.taf(catage, dir="report")
write.taf(passmark, dir="report")
write.taf(regression, dir="report")
