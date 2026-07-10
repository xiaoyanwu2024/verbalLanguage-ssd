# Verbal Strategy Analysis — Data & Code

This repository contains data and analysis code associated with a manuscript currently under review. The repository is temporarily public for peer review purposes. Full public release will follow upon acceptance.

**Contact:** Xiaoyan Wu — xiaoyan.psych@gmail.com

---

## Repository Structure

```
data/
  dataset.xlsx        Trial-level verbal strategy classifications and participant variables

code/
  strategy_main_analysis.m   Overall logistic regression + Fisher's exact tests
  strategy_lmm_analysis.m    Group x Question interaction model (per rater)
  olife_2D_logistic.m        O-LIFE logistic regression models (Models 1–4)
  medianSplitAnalysis.m      CD median split Fisher's exact tests
```

---

## Data (`dataset.xlsx`)

Each row corresponds to one verbal report. Each participant contributed two rows: one for self-reflection (Q1) and one for teaching-others (Q2), giving 214 rows in total.

### Strategy Classification

Participants' verbal reports were transcribed from audio recordings. The `text` column contains the original transcription in the participant's spoken language. Keywords relevant to the classification decision are highlighted in red in the spreadsheet.

Two human raters (rater1, rater2) independently classified each verbal report into one of three strategy categories:

| Strategy | Definition |
|----------|------------|
| `2D` | The participant described a two-dimensional spatial structure, referencing relationships between items along two distinct dimensions (e.g., a grid, a map, or a plane) |
| `1D` | The participant described a one-dimensional structure, organizing items along a single dimension only (e.g., a timeline, a sequence by age, or a linear order) |
| `none` | The participant did not describe any explicit organizational strategy, or the description was too vague to classify |

Out of 214 reports, 18 cases (highlighted in yellow) showed disagreement between the two raters. These 18 cases were reviewed independently a second time, after which the two raters discussed and reached a consensus decision. The final agreed classification is recorded in the `strategy` column and is used in all analyses.

### Column Descriptions

| Column | Description |
|--------|-------------|
| `subject_id` | Participant ID |
| `group` | Learning condition: `Image` or `Language` |
| `question` | Question type: `self-reflection` or `teaching-others` |
| `text` | Transcribed verbal report (multiple languages; keywords highlighted in red) |
| `rater1` | Human rater 1 classification: `2D`, `1D`, or `none` |
| `rater2` | Human rater 2 classification: `2D`, `1D`, or `none` |
| `strategy` | Final consensus classification used in all analyses |
| `UE` | O-LIFE Unusual Experiences subscale score |
| `CD` | O-LIFE Cognitive Disorganization subscale score |
| `IA` | O-LIFE Introvertive Anhedonia subscale score |
| `IN` | O-LIFE Impulsive Nonconformity subscale score |
| `age` | Age in years (decimal), calculated from date of birth to date of testing |
| `gender` | `Male` or `Female` |

---

## Requirements

MATLAB R2020a or later, with the Statistics and Machine Learning Toolbox.

All scripts read `dataset.xlsx` from the `data/` folder. Update the `dataPath` variable in each script if your folder structure differs.

---

## O-LIFE Reference

> Mason, O., Claridge, G., & Jackson, M. (1995). New scales for the assessment of schizotypy. *Personality and Individual Differences, 18*(1), 7–13.
