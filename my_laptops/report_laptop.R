# Plot laptop variables

# Before: specs.csv (output)
# After:  laptop_display.png, laptop_memory.png, laptop_power.png,
#         laptop_storage.png, laptop_thick.png, laptop_weight.png,
#         screen_density.png, screen_pixels.png, specs.csv, specs.md,
#         storage_memory_prop.png, storage_memory_text.png (report)

library(TAF)
library(ggplot2)
library(knitr)
source("utilities.R")  # dateAxis, formPoints, themeReport

mkdir("report")

# Read data
specs <- read.taf("output/specs.csv", colClasses=c(Date="Date"))

# Prepare for plotting
specs$Form <- factor(specs$Form,
                     levels=c("Workstation", "Intermediate", "Ultraportable"))
specs$Percentage <- specs$RAM / (1000*specs$Storage)

# Plot laptop variables
taf.png("laptop_display")
p <- ggplot(specs, aes(x=Date, y=Disp)) +
  formPoints() +
  dateAxis() +
  scale_y_continuous(limits=c(13, 16.2), breaks=13:16, expand=expansion(0)) +
  labs(title="Laptop: Display", x=NULL, y="Screen size (in)") +
  themeReport()
plot(p)
dev.off()

taf.png("laptop_memory")
values <- c("0.5", "1", "2", "4", "8", "16", "32", "64")
p <- ggplot(specs, aes(x=Date, y=RAM)) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(0.4, 75), breaks=as.numeric(values), labels=values,
                expand=expansion(0)) +
  labs(title="Laptop: Memory", x=NULL, y="Memory (GB)") +
  themeReport()
plot(p)
dev.off()

taf.png("laptop_power")
p <- ggplot(specs, aes(x=Date, y=Power)) +
  formPoints() +
  dateAxis() +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  expand_limits(y=0) +
  labs(title="Laptop: Power adapter", x=NULL, y="Power (W)") +
  themeReport()
plot(p)
dev.off()

taf.png("laptop_storage")
values <- c("0.05", "0.1", "0.2", "0.5", "1", "2", "4")
p <- ggplot(specs, aes(x=Date, y=Storage)) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(0.03, 4), breaks=as.numeric(values), labels=values,
                expand=expansion(0)) +
  labs(title="Laptop: Storage drive", x=NULL, y="Storage (TB)") +
  themeReport()
plot(p)
dev.off()

taf.png("laptop_thick")
p <- ggplot(specs, aes(x=Date, y=Height)) +
  formPoints() +
  dateAxis() +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  expand_limits(y=0) +
  labs(title="Laptop: Thickness", x=NULL, y="Height (cm)") +
  themeReport()
plot(p)
dev.off()

taf.png("laptop_weight")
p <- ggplot(specs, aes(x=Date, y=Weight)) +
  formPoints() +
  dateAxis() +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  expand_limits(y=0) +
  labs(title="Laptop: Weight", x=NULL, y="Weight (kg)") +
  themeReport()
plot(p)
dev.off()

# Plot screen variables
taf.png("screen_density")
p <- ggplot(specs, aes(x=Date, y=ppi)) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(80, 300), breaks=c(100, 150, 200, 250, 300),
                expand=expansion(0)) +
  labs(title="Laptop: Pixel density", x=NULL, y="Density (PPI)") +
  themeReport()
plot(p)
dev.off()

taf.png("screen_pixels")
p <- ggplot(specs, aes(x=Date, y=h)) +
  formPoints() +
  dateAxis() +
  scale_y_log10(limits=c(720, 2550), breaks=c(768, 1080, 1440, 2400),
                expand=expansion(0)) +
  labs(title="Laptop: Screen resolution", x=NULL, y="Vertical pixels") +
  themeReport()
plot(p)
dev.off()

# Relationship between variables
taf.png("storage_memory_prop")
p <- ggplot(specs, aes(x=Date, y=Percentage)) +
  formPoints() +
  dateAxis() +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  expand_limits(y=0) +
  labs(title="Memory tends to be around 2% of storage", x=NULL,
       y="Memory / Storage") +
  themeReport()
plot(p)
dev.off()

taf.png("storage_memory_text")
n <- nrow(specs)
notes <- data.frame(
  Date=c(specs$Date[1]+130, specs$Date[1]+120, specs$Date[2], specs$Date[2],
         specs$Date[n]-80, specs$Date[n]-30),
  Percentage=c(specs$Percentage[1]+0.004, specs$Percentage[1]-0.004,
               specs$Percentage[2]+0.004, specs$Percentage[2]-0.004,
               specs$Percentage[n]+0.004, specs$Percentage[n]-0.004),
  label=c("512 MB\nRAM", "40 GB\nHDD", "4 GB\nRAM", "100 GB\nHDD",
          "64 GB\nRAM", "2 TB\nSSD"))
p <- ggplot(specs, aes(x=Date, y=Percentage)) +
  geom_hline(yintercept=0.02, linetype=3, colour="grey35") +
  formPoints() +
  geom_text(data=notes, aes(label=label), size=3.3, colour="grey45",
            lineheight=0.9) +
  dateAxis() +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1))) +
  expand_limits(y=0) +
  labs(title="Memory tends to be around 2% of storage", x=NULL,
       y="Memory / Storage") +
  themeReport()
plot(p)
dev.off()

taf.png("thick_watt")
fm <- lm(W~Height, specs)
p1gen8 <- specs[specs$Laptop == "Lenovo-P1-Gen8",]
t61 <- specs[specs$Laptop == "Lenovo-ThinkPad-T61",]
notes <- data.frame(Height=c(p1gen8$Height, t61$Height),
                    W=c(p1gen8$W+6, t61$W-6),
                    label=c("new\npremium\naluminium",
                            "old\nworkstation\nplastic"))
p <- ggplot(specs, aes(x=Height, y=W)) +
  geom_abline(intercept=coef(fm)[[1]], slope=coef(fm)[[2]], colour="#1F3A5F",
              linewidth=0.7) +
  formPoints() +
  geom_text(data=notes, aes(label=label), size=3.3, colour="grey45",
            lineheight=0.9) +
  labs(title="Processor power and laptop thickness", x="Thickness (cm)",
       y="Thermal design power (W)") +
  themeReport()
plot(p)
dev.off()

# Format specs
specs$Hybrid[specs$Hybrid == "-"] <- ""
specs$Cores <- paste0(specs$Cores, specs$Hybrid)
cols <- c("Date", "Laptop", "Model", "Cores", "Turbo", "RAM", "Storage","W")
specs <- specs[cols]
names(specs)[names(specs) == "Date"] <- "Year"
names(specs)[names(specs) == "Model"] <- "Processor"
names(specs)[names(specs) == "RAM"] <- "Memory"
specs$Year <- as.integer(format(specs$Year, "%Y"))
specs$Turbo <- format(round(specs$Turbo / 1000, 1))
specs$Memory <- formatC(specs$Memory)
specs$Storage <- formatC(specs$Storage)

# Write to Markdown format
specs.md <- kable(specs, "pipe", align="lllrrrrr")
writeLines(specs.md, "report/specs.md")

# Write tables
write.taf(specs, dir="report")
