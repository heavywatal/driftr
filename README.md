Shiny app for genetic drift simulation
================================================================================

Run `driftr` on ShinyApps.io server
--------------------------------------------------------------------------------

1. Go to http://heavywatal.shinyapps.io/driftr


Run `driftr` on your computer
--------------------------------------------------------------------------------

1. Launch [R](http://cran.rstudio.com/)

1. Install prerequisite packages.

  ```r
  install.packages('shiny')
  install.packages('plyr')
  install.packages('dplyr')
  install.packages('ggplot2')
  install.packages('pipeR')
  ```

1. Load `shiny` package.

  ```r
  library(shiny)
  ```

1. Download and launch a Shiny application.

  ```r
  runGitHub('driftr', 'heavywatal')
  ```

  Or specify manually downloaded folder.

  ```r
  runApp('~/Downloads/driftr')
  ```
