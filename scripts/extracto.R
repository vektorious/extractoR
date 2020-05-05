##################################
# Alexander Kutschera 2020/04/21 #
# alexander.kutschera@gmail.com  #
#     §§  CC-BY-SA 4.0  §§       #
         Version = 0.8          
##################################

# Settings 
file = "data/test.dat" # only required if read_folder is "FALSE", reads single file
read_folder = FALSE # scans folder and analyses all files
folder_path = "/Volumes/GNASTICK" # path to the folder which should be scanned
filter_files = "_filteredpcameasurements.dat" # pattern in the files which should be analysed
folder_input = "input"
folder_results = "output_results" # write results into new folder
folder_plots = "output_plots" # write plots into new folder

thresh = 0.1  # set and change the thresh
use_samplename = TRUE # use sample names to get info about the treatment
remove_Cy5 = TRUE # remove the Cy5 channel
move_all_file = FALSE
move_to = "old_input"
remove_old = TRUE
plot_colors = c("#33a02c", "#e31a1c", "#1f78b4", "#b2df8a", "#ff7f00", "#fb9a99", "#fdbf6f", "#a6cee3")

# libraries
library(dplyr)
library(lubridate)
library(reshape)
library(ggsci)
library(gridExtra)
library(grid)
library(ggplot2)
library(ggpubr)
library(stringr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# functions
source("fun_extracto.R")

# Script #############################

if (read_folder == TRUE) {
  all_filenames <- list.files(paste0(folder_path, "/", folder_input), pattern = filter_files)
  for (filename in all_filenames) {
    print(paste0("analysing ", paste0(folder_path, "/", folder_input, "/", filename), " ..."))
    data <- read_dat_neo(paste0(folder_path, "/", folder_input, "/", filename))
    
    results <- extract_info(data$no_temp, thresh, filename, use_samplename, remove_Cy5)
    
    plot <- create.plot(data, results, filename, thresh, remove_Cy5 = TRUE)
    write.pdf(results, plot, filename, into_folder = paste0(folder_path, "/", folder_plots))
    
    dir.create(paste0(folder_path, "/", folder_results))
    write.csv2(results, paste0(folder_path, "/", folder_results, "/", gsub(".dat", ".csv", filename)))
  }
} else {
  data <- read_dat_neo(file)
  results <- extract_info(data$no_temp, thresh, file, use_samplename, remove_Cy5)
  write.csv2(results, gsub(".dat", ".csv", file))
  plot <- create.plot(data, results, file, thresh, remove_Cy5 = TRUE)
  write.pdf(results, plot, file)
}

if (move_all_file == TRUE) {
  print(paste0("removing files from ", folder_input, " ..."))
  dir.create(paste0(folder_path, "/", move_to))
  filenames <- list.files(paste0(folder_path, "/", folder_input))
  for (filename in filenames) {
    file.copy(paste0(folder_path, "/", folder_input, "/", filename), paste0(folder_path, "/", move_to))
    if (remove_old == TRUE) {
      file.remove(paste0(folder_path, "/", folder_input, "/", filename), paste0(folder_path, "/", move_to))
    }
  }
}


