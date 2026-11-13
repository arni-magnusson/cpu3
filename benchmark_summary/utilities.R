# Plot theme for report
themeReport <- function(base_size=12, legend="topleft", grid="both")
{
  # Legend inside plot area, in a corner
  pos <- switch(legend,
                topleft=c(0.03, 0.97), topright=c(0.97, 0.97),
                bottomleft=c(0.03, 0.03), bottomright=c(0.97, 0.03))
  just <- switch(legend,
                 topleft=c(0, 1), topright=c(1, 1),
                 bottomleft=c(0, 0), bottomright=c(1, 0))

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
          axis.title.x=element_text(colour="grey35", margin=margin(t=10)),
          axis.title.y=element_text(colour="grey35", margin=margin(r=10)),
          axis.text=element_text(colour="black", size=rel(1.05)),
          legend.position="inside",
          legend.position.inside=pos,
          legend.justification=just,
          legend.title=element_blank(),
          legend.background=element_rect(fill="white", colour=NA),
          legend.spacing.y=unit(2, "pt"),
          legend.text=element_text(size=rel(0.9)),
          legend.key.size=unit(1, "lines"),
          plot.margin=margin(15, 20, 12, 15))
}