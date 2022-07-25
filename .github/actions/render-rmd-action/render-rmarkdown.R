library(rmarkdown)
library(devtools)

if (!require("emo",character.only = TRUE)) {
    devtools::install_github("hadley/emo")
}

for (rmd_file in list.files(pattern = "/*.Rmd")) {render(input = rmd_file, output_format = md_document(preserve_yaml = TRUE))}
