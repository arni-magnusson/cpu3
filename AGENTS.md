# Convert base R plots to ggplot format

This project is about modifying existing R scripts that are part of reproducible
workflows in TAF format.

1. Clone https://github.com/arni-magnusson/cpu3 in your sandbox.

2. Set up R with newest ggplot2 package and install the TAF package from
   https://github.com/ices-tools-prod/TAF.

3. Read the taf-workflow and taf-ggplot skills.

4. Search R scripts inside https://github.com/arni-magnusson/cpu3 for existing
   ggplot code. If it exists, it means it has passed a human review and you
   should use similar style attributes when developing other ggplots: color
   palette, text size, text alignment, spacing around titles, etc.

5. Developer will instruct you which workflow to focus on. The work inside each
   workflow involves two steps. In the first step, you convert the plotting code
   from base R graphics to ggplot, checking TAF workflow integrity and also
   checking whether the resulting PNG files look good. In the second step, you
   work with the developer on incremental teaks to the format until the
   developer approved the final plot format.

6. When working in Claude chat, the AI agent can only work inside the sandbox
   and cannot modify the actual files. Therefore, changes in the report and
   utility scripts should be shown in the chat, either the whole files or
   selected snippets when the changes are small.
