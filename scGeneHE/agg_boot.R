library(tidyverse)
library(optparse)

option_list = list(
  make_option("--boot_path", action='store', default=NA, type='character', 
              help="Output path of saigeqtl bootstrap results. "),
  make_option("--boot_out_str", action='store', default=NA, type='character', 
              help="The base file names of the output files. "),
  make_option("--n_boot", action='store', default=NA, type='integer', 
              help="Number of bootstraps. "),
  make_option("--gene", action='store', default=NA, type='character', 
              help="gene name. "),	   
  make_option("--out_path", action='store', default=NA, type='character', 
              help="Output path of aggregate bootstrap results. "),
  make_option("--out_str", action='store', default=NA, type='character', 
              help="Output file name of aggregate bootstrap results. ")            
)

opt = parse_args(OptionParser(option_list=option_list))
print(opt)
print("Read param finished ...")

# function to load data and extract theta values
extract_theta <- function(gene, base_name, path, i_boot) {
  # construct the file name
  file_name <- file.path(path, sprintf("boot%d/%s.rda", i_boot, base_name))
  print(file_name)  

  if (file.exists(file_name) && file.info(file_name)$size > 0) {
    # load the .rda file
    # print(file_name)
    load(file_name)
    
    # check if 'modglmm' is loaded and 'theta' exists
    if ("modglmm" %in% ls() && "theta" %in% names(modglmm)) {
      # Return a tibble with the theta values
      tibble(
        bootstrap = i_boot,
        phi = modglmm$theta[1],
        tau_1 = modglmm$theta[2],
        tau_2 = modglmm$theta[3]
      )
    } else {
      # NA if data not found or structure is incorrect
      tibble(
        bootstrap = i_boot,
        phi = NA_real_,
        tau_1 = NA_real_,
        tau_2 = NA_real_
      )
    }
  } else {
    # NA if file is empty
    tibble(
      bootstrap = i_boot,
      phi = NA_real_,
      tau_1 = NA_real_,
      tau_2 = NA_real_
    )
  }
}

bootstrap_numbers <- 0:opt$n_boot

print("Start extract theta ...")
# apply the function over all genes and bootstrap combinations and aggregate results
results_df <- expand.grid(bootstrap = bootstrap_numbers) %>%
  pmap_df(~extract_theta(opt$gene, opt$boot_out_str, opt$boot_path, ..1))

out_str <- paste(opt$out_path, opt$gene, opt$out_str, '.csv', sep='')
write_csv(results_df, out_str)
print("Done!")
