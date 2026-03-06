#!/usr/bin/env python3
"""下载并整理项目所需原始数据（优先公开可直连来源）。

说明：
- 仅使用标准库，避免依赖第三方包。
- 对需要登录/购买/人工下载的数据，记录来源与整理模板，不伪造数据。
"""
from __future__ import annotations

import csv
import datetime as dt
import pathlib
import ssl
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
LOG_DIR = RAW / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

MANIFEST = [
    {
        "id": "city_centroid",
        "target": RAW / "city_centroid.csv",
        "url": "https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json",
        "note": "公开行政区划边界GeoJSON（用于提取地级市质心；本仓库已提供处理后city_centroid.csv）",
        "required": False,
    },
    {
        "id": "co2_city_year",
        "target": RAW / "co2_city_year.xlsx",
        "url": "https://www.ceads.net/data/city-inventory/",
        "note": "CEADs城市碳排放数据页面（通常需人工选择并下载）",
        "required": True,
    },
    {
        "id": "household_size_city_year",
        "target": RAW / "household_size_city_year.xlsx",
        "url": "https://data.cnki.net/Yearbook/Single/N2020100054",
        "note": "《中国城市统计年鉴》入口（通常需机构订阅）",
        "required": True,
    },
    {
        "id": "city_controls_2000_2023",
        "target": RAW / "city_controls_2000_2023.xlsx",
        "url": "https://data.cnki.net/Yearbook/Single/N2020100054",
        "note": "城市统计年鉴入口（GDP、人口、产业结构等）",
        "required": True,
    },
    {
        "id": "mechanism_vars_city_year",
        "target": RAW / "mechanism_vars_city_year.xlsx",
        "url": "https://data.cnki.net/Yearbook/",
        "note": "年鉴总入口（耐用品、交通、能源相关指标通常需分表下载）",
        "required": True,
    },
]


def try_download(url: str, target: pathlib.Path, timeout: int = 30) -> tuple[bool, str]:
    """尝试下载；成功返回(True, msg)，失败返回(False, reason)。"""
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=ssl.create_default_context()) as resp:
            content_type = resp.headers.get("Content-Type", "")
            data = resp.read()
            target.write_bytes(data)
            return True, f"downloaded {len(data)} bytes, content-type={content_type}"
    except Exception as exc:  # noqa: BLE001
        return False, str(exc)


def main() -> int:
    now = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    log_path = LOG_DIR / f"download_log_{now}.csv"

    rows: list[dict[str, str]] = []

    for item in MANIFEST:
        target = item["target"]

        # 已有文件不覆盖，记录为exists
        if target.exists() and target.stat().st_size > 0:
            rows.append(
                {
                    "id": item["id"],
                    "url": item["url"],
                    "target": str(target.relative_to(ROOT)),
                    "status": "exists",
                    "detail": f"already exists ({target.stat().st_size} bytes)",
                    "required": str(item["required"]),
                    "note": item["note"],
                }
            )
            continue

        # 仅对直链文件尝试下载；网页入口只记录待人工下载
        if item["url"].endswith((".csv", ".xlsx", ".xls", ".zip", ".json")):
            ok, detail = try_download(item["url"], target)
            status = "downloaded" if ok else "failed"
        else:
            ok, detail = False, "manual_download_required"
            status = "manual"

        rows.append(
            {
                "id": item["id"],
                "url": item["url"],
                "target": str(target.relative_to(ROOT)),
                "status": status,
                "detail": detail,
                "required": str(item["required"]),
                "note": item["note"],
            }
        )

    with log_path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["id", "url", "target", "status", "detail", "required", "note"],
        )
        writer.writeheader()
        writer.writerows(rows)

    print(f"[OK] log saved to: {log_path.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
