# Produce plots and tables for report

# Before: info.csv (data)
#         cores.rds, m4700.rds, p1gen8.rds, p15gen1.rds, p3560.rds (model)
#         summary.csv (output)
# After:  comparison.png, cores.png, desc.csv, each.png, summary.csv (report)

library(TAF)
library(ggplot2)
source("utilities.R")  # longform, themeReport

mkdir("report")

# Read data
info <- read.taf("data/info.csv")
cores <- readRDS("model/cores.rds")
m4700 <- readRDS("model/m4700.rds")
p1gen8 <- readRDS("model/p1gen8.rds")
p15gen1 <- readRDS("model/p15gen1.rds")
p3560 <- readRDS("model/p3560.rds")
summary <- read.taf("output/summary.csv")

# Machine labels in chronological order (info.csv lists oldest first)
ids <- c("m4700", "p15gen1", "p3560", "p1gen8")
labels <- paste(info$name, paste("Intel", sub(" ", "-", info$processor)),
                sep="\n")[match(ids, info$machine)]

# Prepare plot elements
machines <- list(m4700=m4700, p15gen1=p15gen1, p3560=p3560, p1gen8=p1gen8)
states <- c("idle", "single", "main", "full")
variables <- c(Freq="Frequency (GHz)", Temp="Temperature (\u00b0C)",
               Fan="Fan speed (RPM)")
machine.cols <- setNames(c("#1F3A5F", "#D98E3F", "#2A9D8F", "#8E5EA2"), labels)
state.cols <- c(idle="grey55", single="#1F3A5F", main="#D98E3F", full="#B83A4B")
x <- longform(machines)
x$value[x$variable == "Freq"] <- x$value[x$variable == "Freq"] / 1000  # GHz
x$machine <- factor(x$machine, levels=ids, labels=labels)
x$state <- factor(x$state, levels=states)
x$variable <- factor(x$variable, levels=names(variables))
# Temperature ticks every 25 degrees, other variables keep the default ticks
temp.top <- 1.1 * max(x$value[x$variable == "Temp"])  # incl. 10% margin
ybreaks <- function(lim)
{
  if(isTRUE(all.equal(lim[2], temp.top)))
    seq(0, 100, 25)
  else
    scales::extended_breaks()(lim)
}
axes <- list(
  scale_x_continuous(breaks=c(0, 100, 200, 300), limits=c(0, 300)),
  scale_y_continuous(breaks=ybreaks, expand=expansion(mult=c(0, 0.1))),
  expand_limits(y=0),
  labs(x="Iteration", y=NULL)
)

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

# Plot cores (MHz converted to GHz)
cores <- do.call(rbind, lapply(ids, function(m)
  data.frame(machine=m, core=seq_len(nrow(cores[[m]])),
             state=rep(names(cores[[m]]), each=nrow(cores[[m]])),
             freq=unlist(cores[[m]], use.names=FALSE)/1000)))
cores$machine <- factor(cores$machine, levels=ids, labels=labels)
cores$state <- factor(cores$state, levels=states)
taf.png("cores", 1600, 1600)
p <- ggplot(cores, aes(x=core, y=freq, colour=state)) +
  geom_line(linewidth=0.7) +
  geom_point(size=1.8) +
  facet_wrap(~machine, ncol=2, scales="free_x") +
  scale_colour_manual(values=state.cols, labels=tools::toTitleCase) +
  scale_x_continuous(breaks=function(lim) {b <- pretty(lim); b[b == round(b)]}) +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  expand_limits(y=0) +
  labs(x="Core", y="Frequency (GHz)") +
  themeReport(base_size=11) +
  theme(panel.spacing=unit(1.8, "lines"), strip.text.y.left=element_blank())
plot(p)
dev.off()

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

# Round and divide values
summary <- rnd(summary, grep("idle|single|main|full|spike", names(summary)), -2)
summary <- div(summary, grep("idle|single|main|full|spike", names(summary)))

# Compact description
desc <- data.frame(machine=summary$machine,
                   rest=paste0(format(summary$idle1), "-",
                               format(summary$idle2)),
                   work=paste0(format(summary$main2), "-",
                               format(summary$single2)),
                   spike=summary$spike,
                   spec=paste0(format(info$base), "-",
                               format(info$turbo)))

# Write tables
write.taf(desc, dir="report")
write.taf(summary, dir="report")
