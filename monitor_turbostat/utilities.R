library(ggplot2)  # outliers() and themeReport() draw with ggplot2

outliers <- function(x, span=0.75, dist=0.5, plot=FALSE, xlab="Iteration",
                     ylab="", main=NULL)
{
  # Fit loess model
  iter <- 1:length(x)
  trend <- loess(x~iter, span=span)$fitted

  # Calculate absolute residual
  absresid <- abs(x - trend)

  # Identify outliers
  index <- which(absresid > dist)
  values <- x[index]
  expected <- trend[index]

  # Repair outliers
  repaired <- replace(x, index, expected)

  # Plot
  if(plot)
  {
    cols <- c(Observed="grey55", Trend="#1F3A5F", Outlier="#B83A4B",
              Repaired="#2A9D8F")
    p <- ggplot(data.frame(iter=iter, x=x), aes(x=iter, y=x)) +
      geom_point(aes(colour="Observed"), shape=16, size=1.8) +
      geom_line(aes(y=trend, colour="Trend"), linewidth=1) +
      geom_point(data=data.frame(iter=index, x=values), aes(colour="Outlier"),
                 shape=4, size=3.5, stroke=1.2) +
      geom_point(data=data.frame(iter=index, x=expected),
                 aes(colour="Repaired"), shape=16, size=2.5) +
      scale_colour_manual(values=cols, breaks=names(cols)) +
      guides(colour=guide_legend(override.aes=list(
        shape=c(16, NA, 4, 16), linetype=c(0, 1, 0, 0)))) +
      labs(title=main, x=xlab, y=ylab) +
      themeReport()
    print(p)
  }

  out <- list(trend=trend, repaired=repaired, index=index, values=values,
              expected=expected)
  out
}

# Plot theme for report
themeReport <- function(base_size=12, legend="bottom", grid="both")
{
  # Legend below the plot (shared by all panels), or inside in a corner
  if(legend == "bottom")
  {
    pos <- "bottom"
    just <- "center"
  }
  else
  {
    pos <- switch(legend,
                  topleft=c(0.03, 0.97), topright=c(0.97, 0.97),
                  bottomleft=c(0.03, 0.03), bottomright=c(0.97, 0.03))
    just <- switch(legend,
                   topleft=c(0, 1), topright=c(1, 1),
                   bottomleft=c(0, 0), bottomright=c(1, 0))
  }

  # Light gridlines, either direction (or both) can be dropped
  line <- element_line(colour="grey88")
  grid.x <- if(grid %in% c("both", "x")) line else element_blank()
  grid.y <- if(grid %in% c("both", "y")) line else element_blank()

  # Clean theme for presentation plots
  theme_minimal(base_size=base_size) +
    theme(plot.title=element_text(face="bold", size=rel(1.3), hjust=0.5,
                                  margin=margin(b=12)),
          plot.title.position="plot",
          panel.grid.major.x=grid.x,
          panel.grid.major.y=grid.y,
          panel.grid.minor=element_blank(),
          panel.spacing=unit(1.2, "lines"),
          axis.title.x=element_text(colour="grey35", margin=margin(t=10)),
          axis.title.y=element_text(colour="grey35", margin=margin(r=10)),
          axis.text=element_text(colour="black", size=rel(0.9)),
          strip.text=element_text(face="bold", size=rel(0.95)),
          strip.text.y.left=element_text(face="plain", colour="grey35",
                                         angle=90, size=rel(1)),
          strip.placement="outside",
          legend.position=pos,
          legend.justification=just,
          legend.title=element_blank(),
          legend.background=element_rect(fill="white", colour=NA),
          legend.text=element_text(size=rel(0.9)),
          legend.key.size=unit(1, "lines"),
          plot.margin=margin(15, 20, 12, 15))
}

# Combine Freq, Temp, and Watt measurements of all machines and states
longform <- function(machines)
{
  out <- list()
  for(m in names(machines))
    for(s in names(machines[[m]]))
      for(v in c("Freq", "Temp", "Watt"))
      {
        y <- machines[[m]][[s]][[v]]
        out[[length(out) + 1]] <- data.frame(machine=m, state=s, variable=v,
                                             iteration=seq_along(y), value=y)
      }
  do.call(rbind, out)
}

read_turbostat <- function(file, n=300, burn=0)
{
  # Parse args
  if(length(burn) == 1)
    burn <- c(burn, 0)  # first and last rows to remove

  # Read file
  txt <- readLines(file)
  beg <- grep("^Avg_MHz", txt)
  out <- read.table(text=txt, header=TRUE, skip=beg-1)

  # Subset cols
  out <- out[c("Bzy_MHz", "PkgTmp", "PkgWatt")]
  names(out) <- c("Freq", "Temp", "Watt")

  # Subset rows
  if(burn[1] > 0)
    out <- tail(out, -burn[1])  # remove first rows
  if(burn[2] > 0)
    out <- head(out, -burn[2])  # remove last rows
  if(is.numeric(n) && n > 0 && is.finite(n))  # return n rows
    out <- out[1:n,]

  out
}
