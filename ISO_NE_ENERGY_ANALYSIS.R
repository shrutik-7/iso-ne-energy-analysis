
############################################################
# ISO-NE Energy Market Analysis
# Author: Shruti Khandelwal
# Date: 2025-10-15
# Description: Data cleaning, reshaping, and exploratory analysis
#              for Day-Ahead (DA) vs Real-Time (RT) markets
############################################################


##############################
# 1. Project Setup
##############################

# Create directory structure if it doesn't exist

dirs <- c("data/raw", "data/processed", "notebooks", "src", "docs")
lapply(dirs, dir.create, recursive = TRUE)


# Initialize renv environment (for reproducibility)
install.packages("renv")
renv::init()

# Define days of interest for analysis
days <- c("2024-06-22", "2024-06-23", "2024-06-24", "2024-06-25", "2024-06-26")

##############################
# 2. Package Installation & Loading
##############################

# Install required packages (only first time)

install.packages("data.table")
install.packages("dplyr")
install.packages("stringr")
install.packages("tidyverse")
install.packages("lubridate")

# Load all libraries

library(lubridate)
library(dplyr)
library(stringr)
library(data.table)
library(tidyverse)


# Clear workspace to start fresh
rm(list = ls())

##############################
# 3. Data Import & Cleaning
##############################

# Function to read and clean each CSV file
read_clean_data <- function(path, market_type){
  df <- data.table::fread(path, skip = 4, fill = TRUE)
  df <- as.data.frame(df)
  
  df <- df %>%
    rename_with(~ str_replace_all(., "\\s+", "_")) %>%
    mutate(
      Date = lubridate::ymd(str_extract(basename(path), "\\d{8}")),
      
      Market_Type = market_type
    )
  return(df)
}

# Test reading a single file (Day-Ahead example)

test <- read_clean_data("data/raw/hbdayaheadenergyoffer_20250622.csv", "DA")
head(test)


# Read all available CSV files in raw folder

all_files <- list.files("data/raw", pattern = "*.csv", full.names = TRUE)


# Combine all files into one master dataframe

combined_data <- lapply(all_files, function(f) {
  market <- ifelse(str_detect(f, "dayahead"), "DA", "RT")
  read_clean_data(f, market)
}) %>%
  bind_rows()

# Save cleaned wide-format dataset

write.csv(combined_data, "data/processed/master_data_wide.csv", row.names = FALSE)

# Check column names

names(combined_data)

##############################
# 4. Transform to Long Format
##############################


library(tidyr)
library(dplyr)

# Convert segment columns to long format

master_long <- combined_data %>%
  pivot_longer(
    cols = matches("^Segment_[0-9]+_(Price|MW)$"),  # all segment columns
    names_to = c("Segment", ".value"),              # split name into two parts
    names_pattern = "Segment_([0-9]+)_(.*)"         # regex to capture number + variable
  )

# Save the long-format dataset
write.csv(master_long, "data/processed/master_data_long.csv", row.names = FALSE)

# Preview cleaned and reshaped data
head(master_long %>% select(Date, Market_Type, Segment, Price, MW))

##############################
# 5. Exploratory Analysis
##############################

library(dplyr)
library(ggplot2)
library(lubridate)


# Convert numeric fields safely
master_long <- master_long %>%
  mutate(
    Price = as.numeric(Price),
    MW = as.numeric(MW)
  )

########## 5.1 Compare DA vs RT Average Prices ##########

avg_prices <- master_long %>%
  group_by(Market_Type) %>%
  summarise(
    mean_price = mean(Price, na.rm = TRUE),
    sd_price = sd(Price, na.rm = TRUE)
  )

# Print summary stats
avg_prices

# Boxplot of offer prices by market type
ggplot(master_long, aes(x = Market_Type, y = Price, fill = Market_Type)) +
  geom_boxplot(alpha = 0.6) +
  labs(
    title = "Distribution of Offer Prices in DA vs RT Markets",
    x = "Market Type", y = "Price ($/MWh)"
  ) +
  theme_minimal()
p1

# Save plot
ggsave("docs/DA_RT_boxplot.png", width = 7, height = 5)


########## 5.2 Capacity-Weighted Average Offer Prices ##########

cw_prices <- master_long %>%
  group_by(Date, Market_Type) %>%
  summarise(
    capacity_weighted_price = weighted.mean(Price, MW, na.rm = TRUE),
    .groups = "drop"
  )

# Line chart for capacity-weighted prices
ggplot(cw_prices, aes(x = Date, y = capacity_weighted_price, color = Market_Type)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  labs(
    title = "Capacity-Weighted Average Offer Prices (DA vs RT)",
    x = "Date", y = "Weighted Price ($/MWh)"
  ) +
  theme_minimal()

# Save plot
ggsave("docs/Cap_Weighted.png", width = 7, height = 5)


########## 5.3 Distribution of Bids ##########

# Density plot comparing DA vs RT bid distributions
ggplot(master_long, aes(x = Price, fill = Market_Type)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Distribution of Offer Prices in DA vs RT Markets",
    x = "Price ($/MWh)", y = "Density"
  ) +
  theme_minimal()

# Save plot
ggsave("docs/Distribution__of_Bids.png", width = 7, height = 5)



