# EC4308 Project Proposal

**Project Title**: Forecasting the Equity Risk Premium Out-of-Sample: Regularized Machine Learning and Technical Indicators  
**Course**: EC4308 – Machine Learning and Economic Forecasting (AY 2026/2027 Semester 1)  
**Instructor**: Prof. Denis Tkachenko  
**Target Submission Format**: Strict 1-Page Document (~500–550 words total)  

---

### Group Members & Section Allocations
* **Member 1 (ML Architect)**: [Member 1 Name] (Matric: [Matric Number]) – [Email]
* **Member 2 (Data Specialist)**: [Member 2 Name] (Matric: [Matric Number]) – [Email]
* **Member 3 (Econometrician)**: Sasinthiran Kannan (Matric: **A0272426E**) – `e1121829@u.nus.edu`
* **Member 4 (Literature & Assembly Lead)**: [Member 4 Name] (Matric: [Matric Number]) – [Email]

---

### 1. Research Question & Economic Motivation
*(Assigned to: **Member 4** | Target Length: ~110–130 words)*  
*Guidance for Member 4: Contrast Goyal & Welch (2008/2024 failure of fundamentals out-of-sample) with Neely et al. (2014 technical indicators) and Gu, Kelly, & Xiu (2020 ML in asset pricing). List the 3 core research questions.*

[Member 4: Write your ~120-word section here...]

---

### 2. Target Variable & Data Description
*(Assigned to: **Member 2** | Target Length: ~110–130 words)*  
*Guidance for Member 2: Define the S&P 500 log excess return target variable over 3-month T-bills at h ∈ {1, 3, 12} horizons. Describe the 1927:01–2023:12 sample timeline, the 14 Goyal-Welch macroeconomic fundamentals, and the 14 Neely technical indicators (MA, MOM, OBV).*

[Member 2: Write your ~120-word section here...]

---

### 3. Econometric & Machine Learning Methodology
*(Assigned to: **Member 1** | Target Length: ~110–130 words)*  
*Guidance for Member 1: Describe the expanding-window training/testing scheme (1927–1989 in-sample; 1990–2023 quarantined out-of-sample). Specify penalized linear models (Ridge, LASSO, Elastic Net via glmnet), dimension reduction (PCR, PLS via pls), Random Forest (ranger), and forecast ensembling.*

[Member 1: Write your ~120-word section here...]

---

### 4. Forecast Evaluation & Significance Testing
*(Assigned to: **Member 3 – Sasinthiran Kannan** | Status: **Completed & Verified** | Length: ~125 words)*

We evaluate out-of-sample predictive performance against the historical prevailing mean benchmark:  
  Ŷ_{t+h}^{BM} = (1/t) Σ_{s=1}^t Y_s  

Statistical forecast accuracy is measured using the Campbell-Thompson (2008) Out-of-Sample R²:  
  R²_OOS = 1 − [ Σ_{t=T_in}^{T-h} (Y_{t+h} − Ŷ_{t+h})² / Σ_{t=T_in}^{T-h} (Y_{t+h} − Ŷ_{t+h}^{BM})² ]  

To evaluate whether R²_OOS > 0 is statistically significant, we employ the Clark & West (2007) test, which explicitly corrects for parameter estimation noise under the nested null hypothesis (H0: β = 0). Pairwise performance between non-nested machine learning architectures is evaluated using the Diebold & Mariano (1995) test.

Recognizing that statistical precision does not ensure economic profitability, we conduct an economic evaluation. We simulate a mean-variance investor with risk aversion γ = 3 who dynamically rebalances portfolio weights w_t = (1/γ)(Ŷ_{t+h} / σ̂_t²) between equities and 3-month Treasury bills (constrained to w_t ∈ [0, 1.5]). Performance is assessed via the annualized Certainty Equivalent Return (CER) utility gain (ΔU) relative to the benchmark and the portfolio's annualized Sharpe Ratio.

---

### 5. Feasibility & Execution Timeline
*(Assigned to: **Member 4** | Target Length: ~30–40 words)*  
*Guidance for Member 4: State that Goyal's dataset is public, clean, and requires no proprietary scraping; all models run natively in R with fixed seeds; full code and data will be archived for 100% reproducibility.*

[Member 4: Write your ~35-word section here...]

---

### Key References (Methodological & Empirical Foundation)
1. **Campbell, J. Y., & Thompson, S. B. (2008)**. Predicting the equity premium out of sample: Can anything beat the historical average? *The Review of Financial Studies*, 21(4), 1509–1531.
2. **Clark, T. E., & West, K. D. (2007)**. Approximately normal tests for equal predictive accuracy in nested models. *Journal of Econometrics*, 138(1), 291–311.
3. **Diebold, F. X., & Mariano, R. S. (1995)**. Comparing predictive accuracy. *Journal of Business & Economic Statistics*, 13(3), 253–263.
4. **Goyal, A., & Welch, I. (2008)**. A comprehensive look at the empirical performance of equity premium prediction. *The Review of Financial Studies*, 21(4), 1455–1508.
5. **Neely, C. J., Rapach, D. E., Tu, J., & Zhou, G. (2014)**. Forecasting the equity risk premium: The role of technical indicators. *Management Science*, 60(7), 1772–1791.
