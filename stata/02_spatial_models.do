****************************************************
* 02_spatial_models.do
* 基准空间计量回归
****************************************************
clear all
set more off

global ROOT "."
cd "$ROOT"

use "data/processed/city_panel_2000_2023.dta", clear
xtset citycode year

* 读取空间权重矩阵
spmatrix use Wdist using "data/processed/W_distance_300km.stswm"

* 1) 全局空间相关检验
spatgsa ln_co2_intensity, weights(Wdist) moran twotail

* 2) OLS-FE基准
reghdfe ln_co2_intensity small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, absorb(citycode year) vce(cluster citycode)
est store fe

* 3) 空间杜宾模型（城市和年份固定效应）
spxtregress ln_co2_intensity small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, ///
    fe dvarlag(Wdist) ivarlag(Wdist: small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent)
est store sdm

* 4) 直接/间接效应分解
estat impact, direct indirect total

* 5) 输出结果
esttab fe sdm using "output/baseline_results.rtf", replace se star(* 0.1 ** 0.05 *** 0.01) b(%9.4f) se(%9.4f)

log using "output/02_spatial_models.log", replace text
est replay sdm
log close

display "[OK] Baseline spatial models completed."
