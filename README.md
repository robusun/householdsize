# Household Size and City-level Carbon Emissions in China (2000-2023)

本仓库包含一套可复现研究框架，用于分析**家庭规模变化对中国城市碳排放的影响**，方法上采用空间计量模型，并覆盖：
- 基准分析（空间杜宾模型）
- 机制分析（住房能耗、耐用品、交通）
- 异质性分析（采暖/资源型城市等）
- 稳健性分析（替换变量、样本修剪等）

## 目录结构
- `paper/manuscript_cn.md`：中文论文草稿（含理论、模型、结果与政策含义）
- `data/raw/README.md`：真实数据来源清单与字段规范
- `stata/01_build_panel.do`：原始数据清洗与面板构建
- `stata/02_spatial_models.do`：基准空间回归与效应分解
- `stata/03_mechanism_heterogeneity_robustness.do`：机制、异质性、稳健性
- `output/`：回归结果输出目录

## 运行步骤
1. 根据 `data/raw/README.md` 下载并放置原始数据到 `data/raw/`。
2. 在Stata依次运行：
   - `do stata/01_build_panel.do`
   - `do stata/02_spatial_models.do`
   - `do stata/03_mechanism_heterogeneity_robustness.do`
3. 查看 `output/` 下的结果表与日志。

## 说明
当前环境无法自动联网抓取数据库，故本仓库以“真实数据清单 + 可执行Stata代码 + 论文文本”的形式交付，便于你在有数据库访问权限的机器上一键复现。
