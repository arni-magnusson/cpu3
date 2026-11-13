# Produce plots and tables for report

# Before: passmark.csv (output)
# After:  cpu_benchmark.png, cpu_multicore.png, effective_cores.png,
#         memory_benchmark.png, memory_details.png (report)

library(TAF)
library(ggplot2)
source("utilities.R")

mkdir("report")

# Read data
info <- read.taf("data/info.csv")
memory.details <- read.taf("data/passmark.csv")
passmark <- read.taf("output/passmark.csv")

# Chronological order of machines (info.csv lists oldest first)
passmark <- passmark[match(info$machine, passmark$machine),]

# Machine labels (same as benchmark_actual)
cpu <- paste("Intel", sub(" ", "-", info$processor))
labels <- paste(info$name, cpu, sep="\n")
passmark$label <- factor(labels, levels=labels)

# Single thread
taf.png("cpu_benchmark")
p <- ggplot(passmark, aes(x=single, y=label)) +
  geom_col(fill="#1F3A5F", width=0.7) +
  scale_x_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title="Single-thread benchmark",
       x="Score (PassMark single thread)") +
  themeReport()
plot(p)
dev.off()

# Multithread
taf.png("cpu_multicore")
p <- ggplot(passmark, aes(x=multi, y=label)) +
  geom_col(fill="#1F3A5F", width=0.7) +
  scale_x_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title="Multithread benchmark",
       x="Score (PassMark multithread)") +
  themeReport()
plot(p)
dev.off()

# Effective cores
taf.png("effective_cores")
p <- ggplot(passmark, aes(y=label)) +
  geom_col(aes(x=physcores, fill="Physical cores"), width=0.7) +
  geom_col(aes(x=effcores, fill="Effective index"), width=0.7) +
  scale_fill_manual(values=c("Physical cores"="#8FB8DE",
                             "Effective index"="#1F3A5F"),
                    breaks=c("Physical cores", "Effective index")) +
  scale_x_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title="Effective core index = multithread score / single-thread score",
       x="Number of cores") +
  themeReport()
plot(p)
dev.off()

# Memory
memory <- merge(memory.details, info[c("machine", "name", "module", "year")])
memory <- memory[match(info$machine, memory$machine),]
memory <- memory[c("machine", "name", "memory", "database", "readcache", "read",
                   "write", "available", "latency", "threaded", "module",
                   "year")]
labels <- paste0(memory$name, "\n(", memory$module, ")\n", memory$year)
memory$label <- factor(labels, levels=labels)

taf.png("memory_benchmark")
p <- ggplot(memory, aes(x=memory, y=label)) +
  geom_col(fill="#1F3A5F", width=0.7) +
  scale_x_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(title="Memory benchmark", x="Score") +
  themeReport()
plot(p)
dev.off()

# Memory details, relative to best machine (latency inverted, lower is better)
# Bar labels show the actual values, units are in the legend
metrics <- c("Read (MB/s)", "Write (MB/s)", "Latency (ns)")
num <- function(x) formatC(x, format="d", big.mark=",")
details <- data.frame(label=rep(memory$label, 3),
                      metric=factor(rep(metrics, each=nrow(memory)),
                                    levels=metrics),
                      score=c(100 * memory$read / max(memory$read),
                              100 * memory$write / max(memory$write),
                              100 * min(memory$latency) / memory$latency),
                      value=c(num(memory$read), num(memory$write),
                              num(memory$latency)))
dodge <- position_dodge(width=0.8, reverse=TRUE)
taf.png("memory_details")
p <- ggplot(details, aes(x=score, y=label, fill=metric)) +
  geom_col(position=dodge, width=0.8) +
  geom_text(aes(label=value), position=dodge, hjust=-0.1, size=3.3,
            colour="grey20") +
  scale_fill_manual(values=c("#1F3A5F", "#8FB8DE", "#D98E3F")) +
  scale_x_continuous(breaks=seq(0, 100, 25),
                     expand=expansion(mult=c(0, 0.12))) +
  labs(title="Memory details", x="Score relative to best machine (%)") +
  themeReport() +
  theme(legend.position="top", legend.justification="center")
plot(p)
dev.off()
