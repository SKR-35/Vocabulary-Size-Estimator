# Vocabulary Size Estimator

Estimate passive vocabulary size in minutes instead of testing thousands of words.

---

## Overview

Vocabulary Size Estimator is an interactive **R Shiny** application that estimates a learner's passive vocabulary size from a frequency-ranked word list.

Instead of testing thousands of words, the application draws a **stratified random sample** from predefined frequency bands. The user labels the sampled words as **Known** or **Unknown** and the application estimates the total vocabulary size together with a statistical confidence interval.

The application is language-independent and works with any frequency list following the required format.

---

## Features

- Stratified random sampling
- Language-independent frequency lists
- Interactive word labeling
- Passive vocabulary estimation
- Wilson confidence intervals
- Coverage milestones (40–99%)
- Heatmap summary
- Random seed for reproducibility
- CSV export
- Modular R Shiny architecture
- Unit tests with **testthat**

---

## Frequency List Format

The application expects a CSV file containing three columns:

| Column | Description |
|---------|-------------|
| Index | Word rank (1 = most frequent) |
| Word | Word |
| Frequency | Corpus frequency |

Example:

| Index | Word | Frequency |
|------:|------|----------:|
| 1 | the | 2312345 |
| 2 | of | 1982344 |
| 3 | and | 1762341 |

The default repository contains a Polish frequency list for demonstration purposes.

---

## Methodology

The estimation consists of four steps.

### 1. Stratified Sampling

Words are sampled independently from six frequency bands.

| Rank |
|------:|
| 1–1,000 |
| 1,001–3,000 |
| 3,001–5,000 |
| 5,001–10,000 |
| 10,001–20,000 |
| 20,001–50,000 |

---

### 2. Word Labelling

Each sampled word is marked as

- ✓ Known
- ✗ Unknown

Unknown words are not treated as mistakes—they simply indicate that the word is outside the user's current passive vocabulary.

---

### 3. Vocabulary Estimation

For each frequency band:

```
Known ratio × Band size
```

is used to estimate the number of known words.

The overall estimate is the sum across all frequency bands.

---

### 4. Confidence Interval

The application uses **Wilson confidence intervals**, which provide more reliable estimates than the standard normal approximation, especially for small sample sizes or proportions close to 0 or 1.

The estimated vocabulary size is therefore reported together with a confidence interval.

---

## Coverage Milestones

The application also reports common vocabulary coverage milestones.

| Coverage | Approximate Rank |
|---------:|-----------------:|
| 40% | 75 |
| 50% | 200 |
| 60% | 524 |
| 70% | 1,257 |
| 80% | 2,925 |
| 90% | 7,444 |
| 95% | 13,374 |
| 99% | 25,508 |

These values are approximate and may vary depending on the corpus used to construct the frequency list.

---

## Statistical Notes

- Stratified random sampling
- Wilson score confidence intervals
- Adjustable confidence level
- Reproducible sampling using a random seed

Larger sample sizes generally produce narrower confidence intervals and more stable estimates.

---

## Project Structure

```text
app.R
R/
modules/
tests/
data/
docs/
outputs/
```

---

## Running the App

```r
install.packages(c(
  "shiny",
  "DT",
  "dplyr",
  "readr",
  "ggplot2",
  "bslib",
  "testthat"
))

shiny::runApp()
```

---

## Future Improvements

- Multiple language packs
- Automatic corpus validation
- Bayesian estimation
- Adaptive sampling
- Active vs passive vocabulary estimation
- Progress history
- Session saving
- PDF reports