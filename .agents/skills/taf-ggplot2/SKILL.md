---
name: taf-ggplot2
description: Convert base-graphics plots in TAF workflow report scripts (report.R, report_*.R) to presentation-quality ggplot2 plots, or create new ggplot2 plots in a TAF workflow. Use this skill whenever the user mentions ggplot, ggplot2, converting or restyling plots, presentation-quality figures, or a plot theme in a repository with TAF workflows (data.R, model.R, output.R, report.R), even if they do not say TAF explicitly. Covers which files may be edited, the utilities.R theme pattern, label and ordering conventions, how to verify a change, and the visual style.
---

# TAF plots with ggplot2

This skill extends the general TAF workflow skill (`taf-workflow-helper`). Read that one for how TAF workflows are structured and run. Invoking this skill means the developer has asked for ggplot2 in report scripts, which overrides the general "use base R" default for those scripts only.

The base graphics code in a TAF repository is often deliberately simple, written for the author's own use. The ggplot2 versions are a presentation layer on top: same data, same numbers, better looking figures. The conversion must never change what is computed.

## Scope

Edit only these files in a workflow:

- `report.R` and `report_*.R`: the plotting code
- `utilities.R`: the plot theme (create it if the workflow has none)
- `data.R` and `boot/DATA.bib`: only to bring in `info.csv` when plot labels need machine names (see "Labels and order")

Leave `model.R` and `output.R` alone. Each workflow is isolated, so put theme code in that workflow's own `utilities.R` and never share code between workflows. The one shared file is the root `info.csv`.

Load ggplot2 with `library(ggplot2)` in the report script. Target the current release of ggplot2 only, with no backward-compatibility code. ggplot2 changes between versions (the in-plot legend syntax changed in 3.5.0, for example), so keep version-sensitive details inside the theme function in `utilities.R` where they are easy to fix.

## Workflow

1. Run the integrity check first (see "Verification") so you know the workflow runs before you touch it.
2. Read the existing report script and note what each plot shows, including any grouping, sorting, and calculations the script does after plotting (summary tables often reuse the same data frame).
3. Convert one plot, run the workflow, and look at the rendered PNG. If you cannot view images, say so and ask the developer to check.
4. Iterate on formatting with the developer. Make small, focused edits per round.
5. Run the verification again after each round and report what changed and what you checked.

Flag anything that disagrees between files instead of silently fixing it. For example, if an axis label says one unit and `model.R` computes another, tell the developer and let them decide.

## Output pattern

Keep TAF's graphics device convention. Build the plot as an object, then print it between `taf.png()` and `dev.off()`:

```r
taf.png("speed")
print(p)
dev.off()
```

`source.all()` also runs `utilities.R`, so that file should contain function definitions only, with no side effects.

## Labels and order

Keep the original grouping variable intact and put display labels in a separate column. Later code in the same script (summary tables with `aggregate()`, for example) often uses the original column, and overwriting it silently changes the report tables. This mistake actually happened once, and only the CSV diff caught it.

```r
catage$label <- factor(catage$machine, levels=info$machine,
                       labels=paste(info$name, cpu, sep="\n"))
```

Machine order and names come from the root `info.csv`:

- Its rows are in chronological order, oldest first, with ties kept in file order. Use that order for every plot of machines, so the order is consistent across all workflows: `levels=info$machine`.
- For horizontal bars, ggplot draws the first level at the bottom, so the oldest machine is at the bottom and the newest on top. That is the developer's preference.
- Labels have two lines: laptop name, then full processor name, for example `Dell Precision 3560` and `Intel i7-1165G7`. `info.csv` stores `i7 1165G7`, so build the full name in the report script with `paste("Intel", sub(" ", "-", info$processor))` instead of editing the shared file.

If a workflow does not yet read `info.csv`, follow the pattern used in `benchmark_local`: add an `info.csv` entry to `boot/DATA.bib` with `source = {../../info.csv}`, read it in `data.R` from `boot/data/info.csv` and write it with `write.taf(info, dir="data")`, then read `data/info.csv` in the report script. Update the `# Before:` and `# After:` header comments. Run the workflow inside the repository, because the relative path to the root file only resolves there.

## Verification

After every change, check that only the plots changed:

1. In R, from the workflow directory: `library(TAF)`, `clean.boot(force=TRUE)`, `clean()`, `taf.boot()`, `source.all()`.
2. Confirm all scripts ran without errors or warnings.
3. Compare the regenerated `data`, `output` and report CSV files with the committed versions, for example with `git diff` or `diff`. They should be identical, apart from a new `data/info.csv` when you added it. PNG files will differ, of course.
4. Look at the PNG.

If a CSV changed, the conversion altered the analysis. Find out why and fix it before continuing.

## Visual style

These are the developer's preferences for this project, reached through iteration. Start here, then adjust when asked.

- Horizontal bars for comparisons across machines, with long labels on the left.
- Two-colour comparison: light blue `#8FB8DE` and navy `#1F3A5F`.
- Title: bold, centered, no subtitle. Axis titles short, for example "Speed (model iterations / sec)". No y-axis title when the labels are self-explanatory.
- Base text size 12, with value labels sized to match (about 0.3 times the base size) if they are used. No numbers on bars unless the developer asks.
- Light vertical gridlines only; no gridlines along the category axis.
- Keep a 10 percent margin on the value axis so the longest bar does not touch the edge: `scale_x_continuous(expand=expansion(mult=c(0, 0.1)))`.
- Legend inside the plot, bottom right, when that corner is empty (it is where the shortest bars are), with small text and a white background. If the corner is occupied, choose another spot and say so.

Theme function used for the first converted workflow:

```r
themeReport <- function(base_size=12)
{
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
          legend.position="inside",
          legend.position.inside=c(0.95, 0.04),
          legend.justification=c(1, 0),
          legend.title=element_blank(),
          legend.background=element_rect(fill="white", colour=NA),
          legend.text=element_text(size=rel(0.9)),
          legend.key.size=unit(1, "lines"),
          plot.margin=margin(15, 20, 12, 15))
}
```

## Working with the developer

The developer is an expert R programmer who is new to coding agents. Do not over-explain R, but do explain agent concepts in plain language. When you cannot edit files directly, present the finished code for the developer to paste in, and give complete files for short scripts so nothing is lost in copying.

## Not yet covered

This is a first version based on one workflow with one bar chart. Add guidance here once scatter plots, line plots and multi-panel layouts have been converted: for example how to label points, line styles, how to combine panels, and which style choices generalize beyond bar charts.
