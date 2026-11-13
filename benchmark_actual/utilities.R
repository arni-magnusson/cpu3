themeReport <- function(base_size=14)
{
  # Clean theme for presentation plots
  theme_minimal(base_size=base_size) +
    theme(plot.title=element_text(face="bold", size=rel(1.3)),
          plot.subtitle=element_text(colour="grey35", margin=margin(b=12)),
          plot.title.position="plot",
          panel.grid.major.y=element_blank(),
          panel.grid.minor=element_blank(),
          panel.grid.major.x=element_line(colour="grey88"),
          axis.title.x=element_text(colour="grey35", margin=margin(t=10)),
          axis.title.y=element_blank(),
          axis.text.y=element_text(colour="black", size=rel(1.05)),
          legend.position="top",
          legend.justification="left",
          legend.title=element_blank(),
          legend.margin=margin(l=0, b=0),
          legend.box.spacing=unit(4, "pt"),
          legend.text=element_text(size=rel(1.1)),
          plot.margin=margin(15, 20, 12, 15))
}