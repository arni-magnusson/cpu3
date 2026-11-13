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
  geom_col(aes(x=physcores, fill="Physical"), width=0.7) +
  geom_col(aes(x=effcores, fill="Effective index"), width=0.7) +
  scale_fill_manual(values=c(Physical="#8FB8DE", "Effective index"="#1F3A5F"),
                    breaks=c("Physical", "Effective index")) +
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

# Memory details
details <- data.frame(label=rep(memory$label, 3),
                      metric=factor(rep(c("Memory (read)", "Memory (write)",
                                          "Memory (latency)"),
                                        each=nrow(memory)),
                                    levels=c("Memory (read)", "Memory (write)",
                                             "Memory (latency)")),
                      score=c(memory$read, memory$write, memory$latency))
taf.png("memory_details", 1600, 2800)
p <- ggplot(details, aes(x=score, y=label)) +
  geom_col(fill="#1F3A5F", width=0.7) +
  facet_wrap(~metric, ncol=1, scales="free_x") +
  scale_x_continuous(expand=expansion(mult=c(0, 0.1))) +
  labs(x="Score") +
  themeReport()
plot(p)
dev.off()
