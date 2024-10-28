/**************************************
*This code replicates exhibits and numbers in text from "Clinical decision support 
for high-cost imaging: a randomized clinical trial" (Doyle et al. 2019).

It runs on Stata 13.

Exhibits replicated are:
    Table 1: Provider Characteristics
    Table 2: Impact of CDS on Scans
    Table 3: Subgroup Analysis of Impact of CDS on Targeted Scans
    Table S1: Distributional Statistics on Orders Placed by Control Providers
    Table S2: Types of Imaging Orders Placed by Control Providers
    Table S5: Impact of CDS on Scores of Imaging Orders
    Table S6: Sensitivity Analysis for Impact of CDS on Primary Outcome (Targeted Scans)
    Table S7: Analysis of Potential CDS Avoidance

The code also replicates some numbers reported in text that are not in any of the tables. 
These are the percent of control group study period high-cost scans scored 1-9 for which
the BPA was shut off, the percent of orders by control providers that don't result in a
scan performed at health system, and the F-statistic to test the change in indication distribution.

Estimates that use scan order records directly cannot be replicated because these data are not public.

Exhibits that cannot be replicated are:
    Table S3: Top 20 Most Frequent Indication-Imaging Pairs Ordered by Control Providers
    Table S4: Top 20 Most Frequent Targeted Indication-Imaging Pairs Ordered by Control Providers

Numbers in the text that cannot be replicated are the percent of scans with a higher-scoring 
alternative that is high-cost, the percent of scans with appropriateness scores affected by 
contrast-generic scoring, and the chi-squared test for equality.

The table-generating code is divided among several .do files: this is the master file that 
calls all of them. 

F-tests in provider_characteristics and potential_avoidance.do take a while. Be sure to
use Stata 13 to replicate the p-values.

To run this file, make sure that the following folder structure is intact, with 
the following do-files and datasets in each folder. Dashes represent the subfolder level

-[Your folder]
--CDS_Data
---prov_all_stats_qp.dta
---prov_scan_sp.dta
---prov_ind_gaming_sp.dta
---controls.dta
---prov_enc_sp.dta
---prov_scan_sp_quarters.dta
--CDS_Replication_Code
---cds_replication.do
---Programs
----prepare_data.do
----provider_characteristics.do
----impact_of_cds_scans.do
----subgroup_analysis.do
----control_order_distribution.do
----control_order_type.do
----impact_of_cds_scores.do
----sensitivity_analysis.do
----potential_avoidance.do
----numbers_in_text.do
---Output
----cds_tables.xlsx

Currently the code will generate all tables and figures listed above. Add an "*" in front of the 
code in program "tables_and_figures" below to choose which tables to skip. For example, leaving the 
code as "do Programs/subgroup_analysis.do" will run Table 3, and changing it to 
"*do Programs/subgroup_analysis.do" will skip Table 3.

The full log file outputs to cds_replication.log. In addition, a 
txt file with each generated table outputs to the subfolder named "Output".

**************************************/
clear all
program drop _all
set more off
cap log close
cap cd Programs
cap mkdir ../Output
adopath + SubPrograms/

log using ../cds_replication.log, text replace

program master_main
    prepare_data
    tables_and_figures
end

program prepare_data
    do prepare_data.do
end

program tables_and_figures
    *Table 1: Provider Characteristics
    do provider_characteristics.do

    *Table 2: Impact of CDS on Scans
    do impact_of_cds_scans.do

    *Table 3: Subgroup Analysis of Impact of CDS on Targeted Scans
    do subgroup_analysis.do

    *Table S1: Distributional Statistics on Orders Placed by Control Providers
    do control_order_distribution.do

    *Table S2: Types of Imaging Orders Placed by Control Providers
    do control_order_type.do

    *Table S5: Impact of CDS on Scores of Imaging Orders
    do impact_of_cds_scores.do

    *Table S6: Sensitivity analysis for Impact of CDS on Primary Outcome (Targeted Scans)
    do sensitivity_analysis.do

    *Table S7: Analysis of Potential CDS Avoidance
    do potential_avoidance.do

    *numbers_in_text
    do numbers_in_text.do
end

*Execute
master_main

log close
