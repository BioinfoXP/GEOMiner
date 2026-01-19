<div align="center">


<img src="https://wandering.oss-cn-hangzhou.aliyuncs.com/OB_Zotero/20260119103543.png" width="200" alt="GEOMiner Logo">

# GEOMiner: AI-Driven Semantic Curation of NCBI GEO Datasets

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/Language-R_4.0%2B-276DC3.svg)](https://www.r-project.org/)
[![Shiny App](https://img.shields.io/badge/Shiny-Live_Demo-ff69b4.svg?logo=RStudio&logoColor=white)](https://bioinfoxp.shinyapps.io/GEOMine-Shiny/)
[![Status](https://img.shields.io/badge/Manuscript-In_Prep-orange)](https://github.com/BioinfoXP/GEOMiner)

<br>

**Automating Dataset Selection from GEO Using Large Language Models**

[**Live Demo**](https://bioinfoxp.shinyapps.io/GEOMine-Shiny/) | [**Report Bug**](https://github.com/BioinfoXP/GEOMiner/issues) | [**Request Feature**](https://github.com/BioinfoXP/GEOMiner/issues)

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
- [Usage Examples](#-usage-examples)
  - [CLI Workflow](#cli-workflow)
  - [Web Interface](#web-interface)
- [Methodology](#-methodology)
- [Citation](#-citation)
- [License & Contact](#-license--contact)

---

## 📝 Overview

**GEOMiner** is a sophisticated R package designed to automate the retrieval, curation, and analysis of transcriptomic datasets from the NCBI Gene Expression Omnibus (GEO). 

Traditional keyword searches often yield high noise. **GEOMiner** leverages **Large Language Models (LLMs)** and **Retrieval-Augmented Generation (RAG)** techniques to move beyond syntax-matching, offering **context-aware semantic curation**. It enables researchers to filter datasets based on complex biological criteria (e.g., *specific tissue types*, *clinical outcomes*, or *exclusion of cell lines*) with high precision.

---

## 🚀 Key Features

| Feature                          | Description                                                  |
| :------------------------------- | :----------------------------------------------------------- |
| **🤖 Semantic Query Translation** | Converts natural language research questions into precise NCBI Entrez Boolean strings, handling MeSH terms and synonyms automatically. |
| **🎯 RAG-Based Scoring**          | Evaluates datasets on a **0-100 scale** against user-defined inclusion/exclusion criteria (e.g., *"Only human tissue, exclude PDX models"*). |
| **⚡ High-Performance Parsing**   | Implements multi-threaded parallel processing to scrape and analyze metadata from hundreds of datasets efficiently. |
| **📊 Automated Extraction**       | Automatically extracts critical study variables including **Sample Size ($N$)**, **Organism**, **Platform**, and **Study Design**. |
| **📑 Intelligent Reporting**      | Generates publication-ready Excel reports with color-coded relevance scores and direct hyperlinks for validation. |

---

## 💻 Getting Started

### Prerequisites

- R (>= 4.0.0)
- An API Key from an LLM provider (OpenAI, DeepSeek, or local LLM server).

### Installation

You can install the development version of **GEOMiner** from GitHub:

```r
if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools")
}

devtools::install_github("BioinfoXP/GEOMiner")
```

### Configuration

Set your API key in the R environment for security. You can add this to your `.Renviron` file or run it per session:

```R
# Example: Setting OpenAI API Key
Sys.setenv(OPENAI_API_KEY = "sk-...")

# Example: Setting DeepSeek API Key (Optional)
Sys.setenv(DEEPSEEK_API_KEY = "sk-...")
```

------

## 🧪 Usage Examples

### CLI Workflow

The core function `geo_mine()` handles the end-to-end workflow.

#### 1. Context-Specific Mining (Recommended)

Refine results by defining specific inclusion/exclusion criteria.

R

```
library(GEOMiner)

# Scenario: Searching for Lung Cancer studies involving EGFR mutations
# Criteria: Strictly human tissue samples; exclude cell lines and PDX models.

results <- geo_mine(
  keyword = "Lung Cancer EGFR",
  context = "Include only human tissue samples with EGFR mutation status. Exclude cell lines, organoids, and PDX models.",
  limit = 20,
  output_file = "lung_egfr_clinical_curated.xlsx"
)
```

#### 2. Using Alternative LLM Providers

Switch providers by changing the `base_url` and `model` parameters.

R

```
results <- geo_mine(
  keyword = "Single cell RNA-seq breast cancer",
  limit = 10,
  base_url = "[https://api.deepseek.com/v1](https://api.deepseek.com/v1)",  # Endpoint
  model = "deepseek-chat",                   # Model Name
  api_key = Sys.getenv("DEEPSEEK_API_KEY")   # Securely retrieve key
)
```

### Web Interface

For users who prefer a graphical interface, **GEOMiner** is available as a deployed Shiny application. No coding is required.

<div align="center">

[![GEOMiner Shiny App](https://wandering.oss-cn-hangzhou.aliyuncs.com/OB_Zotero/20260119113206.png)](https://bioinfoxp.shinyapps.io/GEOMine-Shiny/)

*Click the screenshot above to launch the interactive application.*

</div>

</div>

------

## 🛠 Methodology

The GEOMiner pipeline consists of five automated stages:

1. **Query Generation**: NLP-driven translation of user intent into NCBI syntax.
2. **Metadata Retrieval**: Fetching metadata via `rentrez` API.
3. **Parallel Parsing**: High-speed scraping of study abstracts and design details.
4. **Semantic Evaluation (RAG)**: LLM-based scoring of dataset relevance against the `context` prompt.
5. **Structured Output**: Standardization of results into a tabular format.

### Scoring Criteria

| **Score** | **Level**  | **Definition**                                               |
| --------- | ---------- | ------------------------------------------------------------ |
| 🟢         | **90-100** | **High Relevance.** Dataset strictly meets all inclusion criteria (e.g., correct tissue, clinical data available). |
| 🟡         | **70-89**  | **Moderate Relevance.** Topic matches, but may lack secondary details (e.g., small $N$ or unclear survival data). |
| ⚪         | **0-69**   | **Low Relevance.** Mismatched organism, wrong sample type (e.g., cell line), or insufficient metadata. |

------

## 📚 Citation

**GEOMiner** is currently a research project in active development. If you use this software in your work, please cite it as follows (Manuscript in preparation):

> **Xia, P.** (2025). *GEOMiner: AI-Driven Semantic Curation of NCBI GEO Datasets*. R package version 0.1.0. https://github.com/BioinfoXP/GEOMiner

代码段

```
@manual{GEOMiner2025,
  title  = {GEOMiner: AI-Driven Semantic Curation of NCBI GEO Datasets},
  author = {Peng Xia},
  year   = {2025},
  note   = {R package version 0.1.0 (Manuscript in preparation)},
  url    = {[https://github.com/BioinfoXP/GEOMiner](https://github.com/BioinfoXP/GEOMiner)}
}
```

------

## ⚠️ Disclaimer

**GEOMiner** is an assistive tool. While it significantly reduces curation time, **manual verification** of the selected datasets against original GEO records is recommended before conducting downstream meta-analysis.

------

## 👤 Author

Peng Xia, PhD Candidate

School of Basic Medical Sciences, Lanzhou University

- **Research Interests:** Cancer Genomics, Single-Cell Analysis, AI-Driven Data Mining
- **Email:** [xp294053@163.com](mailto:xp294053@163.com)
- **GitHub:** [@BioinfoXP](https://github.com/BioinfoXP)

------

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
