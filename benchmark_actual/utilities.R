themeReport <- function(base_size=12)
{
  # Legend in bottom right corner of plot area (syntax depends on version)
  if(packageVersion("ggplot2") >= "3.5.0")
    legend <- theme(legend.position="inside",
                    legend.position.inside=c(0.95, 0.04))
  else
    legend <- theme(legend.position=c(0.95, 0.04))

  # Clean theme for presentation plots
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
          legend.justification=c(1, 0),
          legend.title=element_blank(),
          legend.background=element_rect(fill="white", colour=NA),
          legend.text=element_text(size=rel(0.9)),
          legend.key.size=unit(1, "lines"),
          plot.margin=margin(15, 20, 12, 15)) +
    legend
}
