****************************************************
* 01_build_panel.do
* 构建2000-2023城市面板：家庭规模与碳排放
****************************************************
clear all
set more off

* 修改为你的项目根目录
global ROOT "."
cd "$ROOT"

cap mkdir "data/processed"
cap mkdir "output"

*-----------------------------
* 1. 导入家庭规模
*-----------------------------
import excel "data/raw/household_size_city_year.xlsx", firstrow clear
rename (city_code city_name year hh_size) (citycode cityname year hh_size)
destring citycode year hh_size, replace force
tempfile hh
save `hh', replace

*-----------------------------
* 2. 导入城市碳排放
*-----------------------------
import excel "data/raw/co2_city_year.xlsx", firstrow clear
rename (city_code year co2_total) (citycode year co2_total)
destring citycode year co2_total, replace force
tempfile co2
save `co2', replace

*-----------------------------
* 3. 导入控制变量
*-----------------------------
import excel "data/raw/city_controls_2000_2023.xlsx", firstrow clear
rename city_code citycode
destring citycode year, replace force
foreach v in gdp_real pop_resident ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent {
    cap destring `v', replace force
}
tempfile ctrl
save `ctrl', replace

*-----------------------------
* 4. 导入机制变量
*-----------------------------
import excel "data/raw/mechanism_vars_city_year.xlsx", firstrow clear
rename city_code citycode
destring citycode year, replace force
foreach v in residential_energy_intensity ac_per100hh car_per100hh motor_density pt_share {
    cap destring `v', replace force
}
tempfile mech
save `mech', replace

*-----------------------------
* 5. 合并
*-----------------------------
use `hh', clear
merge 1:1 citycode year using `co2', nogen keep(1 3)
merge 1:1 citycode year using `ctrl', nogen keep(1 3)
merge 1:1 citycode year using `mech', nogen keep(1 3)

*-----------------------------
* 6. 构造变量
*-----------------------------
gen ln_co2_total = ln(co2_total + 1)
gen co2_intensity = co2_total / gdp_real * 10000 if gdp_real>0
gen ln_co2_intensity = ln(co2_intensity + 1)

gen small_hh = -ln(hh_size) if hh_size>0
gen ln_pgdp = ln(gdp_real/pop_resident) if pop_resident>0

winsor2 ln_co2_total ln_co2_intensity small_hh ln_pgdp ind2_share urban_rate fdi_gdp fiscal_exp_gdp green_patent, cuts(1 99) replace

*-----------------------------
* 7. 面板设定与保存
*-----------------------------
xtset citycode year
save "data/processed/city_panel_2000_2023.dta", replace

****************************************************
* 8. 构建距离空间矩阵（300km阈值）
****************************************************
preserve
import delimited "data/raw/city_centroid.csv", clear
rename city_code citycode
destring citycode lon lat, replace force

spset citycode, coord(lon lat)
spmatrix create idistance Wdist if _ID!=., dfunction(dhaversine) vtruncate(300) norm(row)
spmatrix save Wdist using "data/processed/W_distance_300km.stswm", replace
restore

display "[OK] Panel and spatial matrix saved."
