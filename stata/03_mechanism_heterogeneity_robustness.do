****************************************************
* 03_mechanism_heterogeneity_robustness.do
* 机制、异质性与稳健性
****************************************************
clear all
set more off

global ROOT "."
cd "$ROOT"

use "data/processed/city_panel_2000_2023.dta", clear
xtset citycode year
spmatrix use Wdist using "data/processed/W_distance_300km.stswm"

*-------------------------
* A. 机制分析
*-------------------------
foreach m in residential_energy_intensity ac_per100hh motor_density {
    reghdfe `m' small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, absorb(citycode year) vce(cluster citycode)
    est store m_`m'

    spxtregress ln_co2_intensity small_hh `m' ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, ///
        fe dvarlag(Wdist) ivarlag(Wdist: small_hh `m' ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent)
    est store y_`m'
}

esttab m_residential_energy_intensity y_residential_energy_intensity ///
       m_ac_per100hh y_ac_per100hh ///
       m_motor_density y_motor_density ///
       using "output/mechanism_results.rtf", replace se star(* 0.1 ** 0.05 *** 0.01)

*-------------------------
* B. 异质性分析
*-------------------------
* 例：北方采暖城市（north_heat=1）
forvalues g = 0/1 {
    preserve
    keep if north_heat==`g'
    spxtregress ln_co2_intensity small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, ///
        fe dvarlag(Wdist) ivarlag(Wdist: small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent)
    est store het_heat_`g'
    restore
}

* 例：资源型城市（resource_city=1）
forvalues g = 0/1 {
    preserve
    keep if resource_city==`g'
    spxtregress ln_co2_intensity small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, ///
        fe dvarlag(Wdist) ivarlag(Wdist: small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent)
    est store het_res_`g'
    restore
}

esttab het_heat_0 het_heat_1 het_res_0 het_res_1 using "output/heterogeneity_results.rtf", replace se star(* 0.1 ** 0.05 *** 0.01)

*-------------------------
* C. 稳健性分析
*-------------------------
* C1: 替换被解释变量
spxtregress ln_co2_total small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, ///
    fe dvarlag(Wdist) ivarlag(Wdist: small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent)
est store rb_dep

* C2: 排除疫情年份
preserve
keep if year<=2019
spxtregress ln_co2_intensity small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, ///
    fe dvarlag(Wdist) ivarlag(Wdist: small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent)
est store rb_pre2020
restore

* C3: 剔除直辖市（示例代码）
preserve
drop if inlist(citycode,110000,120000,310000,500000)
spxtregress ln_co2_intensity small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, ///
    fe dvarlag(Wdist) ivarlag(Wdist: small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent)
est store rb_nomu
restore

esttab rb_dep rb_pre2020 rb_nomu using "output/robustness_results.rtf", replace se star(* 0.1 ** 0.05 *** 0.01)

display "[OK] Mechanism/Heterogeneity/Robustness completed."
