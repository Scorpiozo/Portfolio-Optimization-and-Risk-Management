# Portfolio Optimization & Risk Management

An advanced quantitative finance framework written in **R** that automates real-time financial asset harvesting, executes multivariate Monte Carlo risk simulations, and maps the Markowitz Efficient Frontier using vectorized matrix algebra and stochastic calculus.

---

## 📈 Financial Framework & Core Mathematical Foundations

This framework moves away from backward-looking historical tracking by implementing a predictive, forward-looking simulation engine. It treats market dynamics not as isolated patterns, but as an interconnected, multivariate random field where asset covariance dictates structural portfolio risk.

### 1. Continuous Log Returns Transformation

To achieve statistical stationarity and ensure asset returns are additive across time horizons, the asset price matrix $P_{t,j}$ is converted into continuous log returns ($R_{t,j}$). This transformation tames heavy-tailed variance distributions and ensures changes are perfectly symmetrical for upside and downside movements:

$$R_{t,j} = \ln\left(\frac{P_{t,j}}{P_{t-1,j}}\right) = \ln(P_{t,j}) - \ln(P_{t-1,j})$$

Where $P_{t,j}$ represents the Adjusted Closing Price of asset $j$ at time $t$.

### 2. Stochastic Co-Movement Mapping via Cholesky Decomposition

A standard Monte Carlo framework that applies shocks to individual assets independently fails because it ignores the cross-asset correlation structures deeply rooted in real-world markets. To solve this, the framework captures asset dependencies directly from the empirical covariance matrix ($\Sigma$) and applies a **Cholesky Decomposition** to isolate the lower triangular matrix ($L$):

$$\Sigma = L L^T$$

When completely independent, uncorrelated random market shocks ($Z \sim \mathcal{N}(0, I)$) are generated, they are projected through this lower triangular operator. This transforms them into dynamically correlated market shocks that perfectly match historical asset co-movements:

$$\text{Simulated Portfolio Return} = \sum_{j=1}^{n} w_j \cdot \left( \mu_j + [L Z]_j \right)$$

Where $w_j$ is the weight allocated to asset $j$, and $\mu_j$ is its historical mean return.

### 3. Vectorized Portfolio Risk Algebra

Rather than executing resource-heavy iterative loops to calculate risk, the framework leverages compact matrix calculus. The total portfolio volatility ($\sigma_p$) is derived by evaluating the quadratic form of the allocation weight vector ($w$) mapped across the structural asset covariance matrix ($\Sigma$):

$$\sigma_p = \sqrt{w^T \Sigma w}$$

---

## 🛠️ System Features & Analytical Pipeline

* **Live API Data Ingestion:** Automates REST pipeline requests to the Yahoo Finance API via the `quantmod` SDK, pulling historical data matrices for seven mega-cap equities: Apple (`AAPL`), Microsoft (`MSFT`), Google (`GOOGL`), Amazon (`AMZN`), Tesla (`TSLA`), Netflix (`NFLX`), and NVIDIA (`NVDA`).
* **Statistical Initialization:** Automatically extracts adjusted closing values, drops incomplete chronological entries, and builds a comprehensive empirical baseline by computing the asset mean vectors ($\mu$), covariance spaces ($\Sigma$), and asset-to-asset Pearson correlation configurations ($r$).
* **Stochastic Value at Risk (VaR) Solver:** Runs a 10,000-iteration Monte Carlo simulation to project daily portfolio performance. By taking the 5th percentile of the resulting distribution, it isolates the **95% VaR Limit**—the exact boundary defining the worst-case expected loss over a single trading day under normal market conditions.
* **Efficient Frontier Amortization:** Models 5,000 distinct portfolio allocation vectors ($w$) satisfying the standard constraint $\sum w_i = 1$. It isolates individual risk and reward coordinates to map out the complete upper boundary of the Markowitz Efficient Frontier.

---

## 📂 Visual Intelligence Diagnostics

The engine integrates `ggplot2` to render five critical quantitative data plots:

| Diagnostic Display | Underlying Method | Strategic Analytical Purpose |
| --- | --- | --- |
| **The Efficient Frontier Plane** | Random Weight Mapping | Plots 5,000 simulated portfolios. Color-graded by return-to-risk performance to locate maximum-efficiency profiles. |
| **Monte Carlo VaR Histogram** | 10k Stochastic Trials | Visualizes the complete probability distribution of daily returns, marking the 5% risk failure line. |
| **Asset Correlation Heatmap** | Pearson $r$ Matrix Grid | Melts the correlation matrix into a dual-axis grid to easily identify structural redundancies and concentration risks. |
| **Cumulative Growth Multiplier** | Compound Log Returns | Tracks the historical compounding path of an initial $1 investment across each ticker since January 2023. |
| **Asset Volatility Scatter Mapping** | Absolute Deviation Analysis | Compares each individual equity's standalone daily return against its standard deviation to isolate highly volatile assets. |

---

## 📦 System Dependencies & Verification

Ensure your environment has the following production packages compiled:

```R
install.packages(c("quantmod", "ggplot2", "reshape2"))

```

### Script Block Schema Blueprint

```text
├── 1. Setup & Data Ingestion   --> Pulls Yahoo Finance vectors via getSymbols()
├── 2. Statistical Foundations  --> Derives mean returns, covariance, and correlation matrices
├── 3. Monte Carlo Simulation   --> Executes Cholesky factorization and resolves 95% VaR
├── 4. Portfolio Optimization   --> Simulates 5,000 randomized asset weight portfolios
└── 5. Visualizations [5-9]     --> Builds and outputs ggplot2 diagnostic plots

```

---

## 🚀 Execution Guide

1. Clone or download your script into your working directory (e.g., as `portfolio_optimization.R`).
2. Fire up your terminal or RStudio console and execute the source command:

```R
source("portfolio_optimization.R")

```

The system will ping Yahoo Finance, compile the underlying statistics, return the exact **95% VaR daily threshold** to your console output, and generate the analytical charts.

---

## 🔍 Interpretation & Troubleshooting Guide

### 1. Interpreting the 95% VaR Output

If the console prints `[1] "95% VaR: -0.0245"`, it means that based on historical and simulated trajectories, **there is a 95% probability that the portfolio will not lose more than 2.45% of its total value on any given day.** Conversely, there remains a 5% tail-risk chance that losses could exceed this number during high-volatility market events.

### 2. Resolving Yahoo Finance API Blocks

If the `getSymbols` package throws a connection or parsing failure error:

* Check your network connection to verify access to the Yahoo Finance endpoints.
* Ensure your local system time is accurate (discrepancies can invalidate the automated security handshakes).
* If needed, adjust the `from = "2023-01-01"` attribute to a tighter date range to reduce the size of the requested historical data payloads.

---

*Designed for algorithmic risk assessment and quantitative portfolio simulation.*

---