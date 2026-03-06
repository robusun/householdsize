# 原始数据清单（2000–2023，中国城市层面）

> 说明：本仓库提供可复现的数据结构、字段规范与Stata脚本。由于当前执行环境无法直连外网下载数据库，请按以下真实公开/商业数据库来源手工下载后放入本目录。

## 1) 家庭规模（核心解释变量）
- 文件建议名：`household_size_city_year.xlsx`
- 建议来源：
  1. 《中国城市统计年鉴》（各年，城市“平均每户家庭人口”）
  2. 第五、六、七次人口普查城市口径资料（用于校准）
- 关键字段：
  - `city_code`（6位行政代码）
  - `city_name`
  - `year`
  - `hh_size`（人/户）

## 2) 城市碳排放（被解释变量）
- 文件建议名：`co2_city_year.xlsx`
- 建议来源（择一或交叉核对）：
  1. CEADs 中国城市二氧化碳排放清单（地级市）
  2. 中国碳核算数据库（高校团队公开数据）
- 关键字段：
  - `city_code`
  - `year`
  - `co2_total`（万吨）
  - `co2_per_capita`（吨/人，可选）

## 3) 经济与控制变量
- 文件建议名：`city_controls_2000_2023.xlsx`
- 建议来源：
  1. 《中国城市统计年鉴》
  2. 各省统计年鉴（缺失补充）
- 关键字段：
  - `gdp_real`（不变价）
  - `pop_resident`
  - `ind2_share`
  - `urban_rate`
  - `fdi_gdp`
  - `fiscal_exp_gdp`
  - `green_patent`

## 4) 机制变量
- 文件建议名：`mechanism_vars_city_year.xlsx`
- 建议来源：
  1. 城市年鉴“居民家庭每百户耐用品拥有量”
  2. 交通运输年鉴（机动车、公交客运量）
  3. 能源统计年鉴（居民生活能源消费）
- 关键字段：
  - `residential_energy_intensity`
  - `ac_per100hh`
  - `car_per100hh`
  - `motor_density`
  - `pt_share`

## 5) 空间矩阵所需地理数据
- 文件建议名：`city_centroid.csv`
- 建议来源：
  1. 国家基础地理信息中心公开边界（自行求质心）
  2. 民政部行政区划代码 + GIS边界匹配
- 关键字段：
  - `city_code`
  - `lon`
  - `lat`

## 目录放置规范
将原始文件放入 `data/raw/`：
- `household_size_city_year.xlsx`
- `co2_city_year.xlsx`
- `city_controls_2000_2023.xlsx`
- `mechanism_vars_city_year.xlsx`
- `city_centroid.csv`

脚本将输出：
- `data/processed/city_panel_2000_2023.dta`
- `data/processed/W_distance_300km.dta`


## 自动化抓取辅助（新增）
- 脚本：`scripts/fetch_raw_data.py`
- 作用：尝试下载可直链资源；对需登录/订阅资源写入日志并给出官方入口。
- 运行：`python scripts/fetch_raw_data.py`
- 日志：`data/raw/logs/download_log_*.csv`
- 详细说明：`data/raw/RAW_DATA_COLLECTION.md`
