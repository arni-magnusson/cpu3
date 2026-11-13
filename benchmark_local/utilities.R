readPass <- function(file)
{
  # Read text
  x <- readLines(file)

  # Trim
  x <- trimws(x)
  x <- x[grep("CPU Mark", x):length(x)]
  x <- x[x != ""]

  # Use comma separator
  x <- sub(":", "", x)
  x <- sub("  +", ",", x)

  # Read into data frame
  x <- read.table(text=x, sep=",", col.names=c("Variable", "Value"))

  # Simplify variable names
  x$Variable[x$Variable == "CPU Mark"] <- "cpu"
  x$Variable[x$Variable == "Integer Math"] <- "int"
  x$Variable[x$Variable == "Floating Point Math"] <- "float"
  x$Variable[x$Variable == "Prime Numbers"] <- "prime"
  x$Variable[x$Variable == "Sorting"] <- "sort"
  x$Variable[x$Variable == "Encryption"] <- "encrypt"
  x$Variable[x$Variable == "Compression"] <- "compress"
  x$Variable[x$Variable == "CPU Single Threaded"] <- "single"
  x$Variable[x$Variable == "Physics"] <- "physics"
  x$Variable[x$Variable == "Extended Instructions (SSE)"] <- "sse"
  x$Variable[x$Variable == "Memory Mark"] <- "memory"
  x$Variable[x$Variable == "Database Operations"] <- "database"
  x$Variable[x$Variable == "Memory Read Cached"] <- "readcache"
  x$Variable[x$Variable == "Memory Read Uncached"] <- "read"
  x$Variable[x$Variable == "Memory Write"] <- "write"
  x$Variable[x$Variable == "Available RAM"] <- "available"
  x$Variable[x$Variable == "Memory Latency"] <- "latency"
  x$Variable[x$Variable == "Memory Threaded"] <- "threaded"

  # Simplify values
  x$Value <- sub(" .*", "", x$Value)
  x$Value <- type.convert(x$Value, as.is=TRUE)

  x
}

themeReport <- function(base_size=12)
{
  # Clean theme for presentation plots, legend in bottom right corner
  theme_minimal(base_size=base_size) +
    theme(plot.title=element_text(face="bold", size=rel(1.3), hjust=0.5,
                                  margin=margin(b=12)),
          plot.title.position="plot",
          panel.grid.major.y=element_blank(),
          panel.grid.minor=element_blank(),
          panel.grid.major.x=element_line(colour="grey88"),
          axis.title.x=element_text(colour="grey35", margin=margin(t=10)),
          axis.title.y=element_blank(),
          axis.text.y=element_text(colour="black", size=rel(1.05),
                                   lineheight=1.2),
          strip.text=element_text(face="bold", size=rel(1.3), hjust=0.5,
                                  margin=margin(b=8)),
          panel.spacing.y=unit(2, "lines"),
          legend.position="inside",
          legend.position.inside=c(0.95, 0.04),
          legend.justification=c(1, 0),
          legend.title=element_blank(),
          legend.background=element_rect(fill="white", colour=NA),
          legend.text=element_text(size=rel(0.9)),
          legend.key.size=unit(1, "lines"),
          plot.margin=margin(15, 20, 12, 15))
}
