# 真实原始数据联网查找与下载整理说明

本文件给出本研究所需“完整原始数据”的**真实来源、下载方式、落盘文件名与整理口径**。

> 重要：当前执行环境外网访问受限，自动脚本会尽量下载可直链资源；对需要登录/订阅/人工导出的来源，脚本会记录为 `manual`，并保留官方入口链接。

## 目标文件（放在 `data/raw/`）

1. `household_size_city_year.xlsx`
2. `co2_city_year.xlsx`
3. `city_controls_2000_2023.xlsx`
4. `mechanism_vars_city_year.xlsx`
5. `city_centroid.csv`（已在仓库内）

## 来源与口径（真实来源）

### 1) 家庭规模（`household_size_city_year.xlsx`）
- 主来源：`中国城市统计年鉴`（城市“平均每户家庭人口”）
- 补充校准：第5/6/7次人口普查城市口径资料
- 常见入口：CNKI年鉴数据库（通常需机构订阅）

### 2) 城市碳排放（`co2_city_year.xlsx`）
- 主来源：CEADs（China Emission Accounts and Datasets）城市清单
- 入口：<https://www.ceads.net/data/city-inventory/>
- 若页面提供多版本，以口径覆盖2000–2023且城市层级一致版本为准

### 3) 经济与控制变量（`city_controls_2000_2023.xlsx`）
- 主来源：`中国城市统计年鉴`
- 缺失补充：各省统计年鉴
- 核心字段：`gdp_real`, `pop_resident`, `ind2_share`, `urban_rate`, `fdi_gdp`, `fiscal_exp_gdp`, `green_patent`

### 4) 机制变量（`mechanism_vars_city_year.xlsx`）
- 居民耐用品：城市年鉴中“每百户拥有量”
- 交通变量：交通运输年鉴/城市年鉴交通章节
- 住户能源：能源统计年鉴（居民生活能源消费）

### 5) 地理质心（`city_centroid.csv`）
- 仓库当前已提供地级市质心CSV，可直接用于空间矩阵计算

## 自动下载与日志

运行：

```bash
python scripts/fetch_raw_data.py
```

输出：
- `data/raw/logs/download_log_*.csv`：每个数据源的状态（`exists/downloaded/manual/failed`）

> 建议在可访问外网+有数据库订阅的机器上执行同一脚本，然后把四个Excel复制回本仓库 `data/raw/`。
