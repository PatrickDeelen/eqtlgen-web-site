library(rmarkdown)
for (rmd_file in list.files(pattern = "/*.Rmd")) {render(input = rmd_file, output_format = md_document(preserve_yaml = TRUE))}
