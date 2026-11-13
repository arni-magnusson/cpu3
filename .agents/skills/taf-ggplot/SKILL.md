---
name: taf-ggplot
description: Convert base-graphics plots in TAF workflow report scripts (report.R, report_*.R) to presentation-quality ggplot2 plots, or create new ggplot2 plots in a TAF workflow. Use this skill whenever the user mentions ggplot, ggplot2, converting or restyling plots, presentation-quality figures, or a plot theme in a repository with TAF workflows (data.R, model.R, output.R, report.R), even if they do not say TAF explicitly. Covers which files may be edited, the utilities.R theme pattern, label and ordering conventions, how to verify a change, and the visual style.
---

# TAF plots with ggplot2

This skill extends the general TAF workflow skill (`taf-workflows`). Read that one for how TAF workflows are structured and run. Invoking this skill means the developer has asked for ggplot2 in report scripts, which overrides the general "use base R" default for those scripts only.

The base graphics code in a TAF repository is often deliberately simple. The ggplot2 versions are a presentation layer on top: same data, same numbers, better looking figures. The conversion must never change what is computed.

## Scope

Generally, only these files should be edited in a workflow:

- `report.R` and `report_*.R`: the plotting code
- `utilities.R`: the plot theme (create it if the workflow has none)

Leave `model.R` and `output.R` alone. Each workflow is isolated, so put theme code in that workflow's own `utilities.R` and never share code between workflows.

Load ggplot2 with `library(ggplot2)` in the report script. Target the current release of ggplot2 only, with no backward-compatibility code.

## Workflow

1. Run the integrity check first (see "Verification") so you know the workflow runs before you touch it.
2. Read the existing report script and note what each plot shows, including any grouping, sorting, and calculations the script does after plotting (summary tables often reuse the same data frame).
3. Convert one plot, run the workflow, and look at the rendered PNG. If you cannot view images, say so and ask the developer to check.
4. Iterate on formatting with the developer. Make small, focused edits per round.
5. Run the verification again after each round and report what changed and what you checked.

Flag anything that disagrees between files instead of silently fixing it. For example, if an axis label says one unit and `model.R` computes another, tell the developer and let them decide.

## Output pattern

Keep TAF graphics device convention. Build the plot as an object, then print it between `taf.png()` and `dev.off()`:

```r
taf.png("biomass")
print(p)
dev.off()
```

`source.all()` also runs `utilities.R`, so that file should contain function definitions only, with no side effects.

## Verification

After every change, check that only the plots changed:

1. In R, from the workflow directory: `library(TAF)`, `clean.boot(force=TRUE)`, `clean()`, `taf.boot()`, `source.all()`.
2. Confirm all scripts ran without errors or warnings.
3. Compare the regenerated `data`, `output` and report CSV files with the committed versions, for example with `git diff` or `diff`. They should be identical. PNG may of course differ when converting plots or adjusting their format.
4. Look at the PNG.

If a CSV changed, the conversion altered the analysis. Find out why and fix it before continuing.

## Visual style

The following preferences may serve as a useful starting point when formatting a new ggplot. Start here, then adjust when asked.

- Title: bold, centered, no subtitle. Axis titles short. No axis title when the labels are self-explanatory.
- Base text size 12, with value labels sized to match (about 0.3 times the base size) if they are used. No numbers on bars.
- Light gridlines.
- Keep a 10 percent margin on the value axis so the highest values do not touch the edge: `scale_y_continuous(expand=expansion(mult=c(0, 0.1)))`.
- Legend inside the plot, top left if there is space. Use small text and a white background. If the top-left corner is occupied, choose another location and say so.

Theme function used for the first converted workflow:

## Working with the developer

The developer is an expert R and TAF programmer who is new to coding agents. Do not over-explain R, but do explain agent concepts in plain language. When you cannot edit files directly, present the finished code for the developer to paste in, and give complete files for short scripts so nothing is lost in copying.

## Not yet covered

This is a first version based on one workflow with a single bar chart. Add guidance here once scatter plots, line plots and multi-panel layouts have been converted: for example how to label points, line styles, how to combine panels, and which style choices generalize beyond bar charts.
