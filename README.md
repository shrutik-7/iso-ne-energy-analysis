# ISO-NE Energy Market Analysis

**Author:** Shruti Khandelwal  
**Date:** October 2025  

This project analyzes bidding behavior in the **ISO New England (ISO-NE)** electricity markets, comparing **Day-Ahead (DA)** and **Real-Time (RT)** offers.  
The goal is to explore how firms price energy capacity, examine arbitrage opportunities, and visualize market differences.

## Project Structure

iso-ne-energy-analysis/
├── data/
│ ├── raw/ # Original CSVs (one per day)
│ └── processed/ # Cleaned datasets (wide & long formats)
│
├── docs/
│ ├── DA_RT_boxplot.png # DA vs RT price comparison
│ ├── Cap_Weighted.png # Capacity-weighted average price trends
│ └── Distribution_of_Bids.png # Bid distribution comparison
│
│_ ISO_NE_ENERGY_ANALYSIS.R
│
├── iso-ne-energy-analysis.Rproj
└── README.md

## Workflow Overview

### 1. Setup  
- Creates folder structure automatically (`data/`, `docs/`, etc.)  
- Initializes a reproducible environment using **renv**.  
- Loads all required libraries:  
  `tidyverse`, `data.table`, `dplyr`, `stringr`, `lubridate`, `ggplot2`

### 2. Data Cleaning  
- Reads multiple CSV files (one per day) using a custom `read_clean_data()` function.  
- Cleans column names, extracts date from filenames, and adds `Market_Type` (DA or RT).  
- Combines all cleaned data into one master dataset:
  - `master_data_wide.csv` → wide format (each segment as a column)
  - `master_data_long.csv` → long format (segments stacked for analysis)

### 3. Exploratory Analysis  
Includes three main analyses:
1. **Price Distribution:** Boxplots comparing DA vs RT offer prices.  
2. **Capacity-Weighted Averages:** Time trends showing weighted mean offer prices.  
3. **Bid Distributions:** Density plots showing overall bid behavior in both markets.  

All plots are saved to the `/docs/` folder.

## Outputs

| Output File | Description |
|--------------|-------------|
| `master_data_wide.csv` | Clean dataset with all original columns |
| `master_data_long.csv` | Long format dataset for plotting |
| `DA_RT_boxplot.png` | Distribution of DA vs RT offer prices |
| `Cap_Weighted.png` | Capacity-weighted price comparison |
| `Distribution_of_Bids.png` | Bid density plots (DA vs RT) |



## NOTES
This analysis uses open ISO-NE data provided for research purposes.

The focus is on exploring energy market bidding behavior and arbitrage patterns between DA and RT markets.

renv ensures a reproducible environment — all package versions are locked to the current setup.
