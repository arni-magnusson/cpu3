means <- function(x)
{
  freq <- sapply(x[grep("Freq", names(x))], mean)
  temp <- sapply(x[grep("Temp", names(x))], mean)
  fan <- sapply(x[grep("Fan", names(x))], mean)
  c(freq, temp, fan)
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
          strip.text=element_text(face="bold", size=rel(1)),
          strip.text.y.left=element_text(face="plain", colour="grey35",
                                         angle=90),
          strip.placement="outside",
          legend.position=pos,
          legend.justification=just,
          legend.title=element_blank(),
          legend.background=element_rect(fill="white", colour=NA),
          legend.text=element_text(size=rel(0.9)),
          legend.key.size=unit(1, "lines"),
          plot.margin=margin(15, 20, 12, 15))
}

# Combine Freq1, Temp1, and Fan1 measurements of all machines and states
longform <- function(machines)
{
  out <- list()
  for(m in names(machines))
    for(s in names(machines[[m]]))
      for(v in c("Freq", "Temp", "Fan"))
      {
        y <- machines[[m]][[s]][[paste0(v, "1")]]
        out[[length(out) + 1]] <- data.frame(machine=m, state=s, variable=v,
                                             iteration=seq_along(y), value=y)
      }
  do.call(rbind, out)
}

remove_first <- function(x, burn=0, length=300)
{
  x <- x[(1:length)+burn,]
  x$Time <- x$Time - min(x$Time)
  row.names(x) <- NULL
  x
}

summary_machine <- function(x, machine=deparse(substitute(x)))
{
  peak <- function(y)
  {
    c(freq=mean(y$Freq1),
      temp=mean(y$Temp1),
      fan=mean(y$Fan1))
  }
  out <- sapply(x, peak)
  out <- xtab2taf(t(out), "state")
  out <- data.frame(machine=machine, out)
  out
}
