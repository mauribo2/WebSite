library(fs)

# pull all .Rmd files from my blog
dirs_to_create <- dir_ls("~/Projects/Webpage/content/post",
                         type = "directory",
                         recurse = 0)

# there are a few folders that sohuld not be there
dirs_to_create <- dirs_to_create[!stringr::str_detect(dirs_to_create, pattern = "_files")]
# convert the dirs using basename
dirs_to_create <- basename(dirs_to_create)

files_rmd <- list.files("~/Projects/Webpage/content/post", 
                        pattern = "Rmarkdown",
                        full.names = TRUE,
                        recursive = TRUE)
files_md <- list.files("~/Projects/Webpage/content/post", 
                       pattern = "md",
                       full.names = TRUE,
                       recursive = TRUE)

# we need to sort this list to match the folders
full_files <- sort(c(files_rmd, files_md))
# check with
tibble(dir = dirs_to_create, file = full_files) %>% View()

# create folders
dir_create(glue::glue("posts/{dirs_to_create}"))

# copy the files into a new folder, named according to the old file name
purrr::walk2(
  full_files, 
  dirs_to_create, 
  ~file_copy(.x, glue::glue("posts/{.y}/index.qmd"), 
             overwrite =  TRUE))

# convert the headers if needed
to_fix_header <- fs::dir_ls(path = "posts", recurse = 1, regex = "index.qmd")
purrr::walk(
  to_fix_header,
  ~knitr::convert_chunk_header(.x, output = identity)
)
