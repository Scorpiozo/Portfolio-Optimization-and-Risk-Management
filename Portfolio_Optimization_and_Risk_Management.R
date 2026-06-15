#' ---
#' title: "Portfolio Optimization and Risk Management"
#' date: "2026-04-10"
#' output: pdf_document
#' ---

# 1. SETUP & REAL DATA ACQUISITION
library(ggplot2)
library(quantmod)

tickers <- c("AAPL","MSFT", "GOOGL","AMZN", "TSLA", "NFLX", "NVDA")

# Pull real data from Yahoo Finance
getSymbols(tickers, src = "yahoo", from = "2023-01-01")

# Extract 'Adjusted' prices and merge them
prices_list <- lapply(tickers, function(x) Ad(get(x)))
price_matrix <- do.call(merge, prices_list)

# Calculate REAL Log Returns
returns_matrix <- diff(log(price_matrix)) [-1, ]
colnames(returns_matrix) <- tickers

# Convert to matrix
returns_matrix <- as.matrix(returns_matrix)
n_assets <- ncol(returns_matrix)

# Define simulation parameters
n_sims <- 10000
n_portfolios <- 5000


# 2. STATISTICAL FOUNDATIONS (Matrix Algebra)
avg_returns <- colMeans(returns_matrix)
cov_matrix <- cov(returns_matrix)
cor_matrix <- cor(returns_matrix)


# 3. MONTE CARLO SIMULATION (Risk Analysis)
weights <- runif(n_assets)
weights <- weights / sum(weights)

L <- t(chol(cov_matrix))

sim_results <- replicate(n_sims, {
  random_shocks <- rnorm(n_assets)
  correlated_shocks <- L %*% random_shocks
  sum(weights * (avg_returns + correlated_shocks))
})

var_95 <- quantile(sim_results, 0.05)
print(paste("95% VaR:", round(var_95, 4)))


# 4. PORTFOLIO OPTIMIZATION (The Efficient Frontier)
opt_results <- matrix(NA, nrow = n_portfolios, ncol = 2)
colnames(opt_results) <- c("Risk", "Return")

for(i in 1:n_portfolios) {
  w <- runif(n_assets)
  w <- w / sum(w)
  
  p_ret <- sum(w * avg_returns)
  p_risk <- sqrt(t(w) %*% cov_matrix %*% w)
  
  opt_results[i, ] <- c(p_risk, p_ret)
}

opt_results <- as.data.frame(opt_results)


# 5. EFFICIENT FRONTIER VISUALIZATION
ggplot(opt_results, aes(x = Risk, y = Return)) +
  geom_point(aes(color = Return / Risk), alpha = 0.5) + 
  scale_color_gradient(low = "red", high = "green") +
  labs(
    title = "Efficient Frontier - Monte Carlo Portfolio Optimization",
    subtitle = "Optimal Portfolios: High Return vs Low Volatility",
    x = "Portfolio Risk (Volatility)",
    y = "Expected Return",
    color = "Return/Risk"
  ) +
  theme_minimal()

# 6. The VALUE AT RISK (VaR) HISTOGRAM
sim_df <- data.frame(Returns = sim_results)

ggplot(sim_df, aes(x = Returns)) +
  geom_histogram(bins = 100, fill = "steelblue", color = "white", alpha = 0.7) +
  geom_vline(xintercept = var_95, linetype = "dashed", color = "red", size = 1) +
  annotate("text", x = var_95, y = 100, label = paste("95% VaR"), color = "red", angle = 90, vjust = -1) +
  labs(title = "Monte Carlo Simulation: Distribution of Daily Returns",
       subtitle = "Red line represents the 5% Value at Risk threshold",
       x = "Simulated Daily Return", y = "Frequency") +
  theme_minimal()


# 7. CORRELATION HEATMAP
library(reshape2)
melted_cor <- melt(cor_matrix)

ggplot(melted_cor, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0.5) +
  geom_text(aes(label = round(value, 2)), color = "black", size = 3) +
  labs(title = "Asset Correlation Matrix",
       subtitle = "Measuring how tickers move in relation to each other",
       x = "", y = "", fill = "Correlation") +
  theme_minimal()


# 8. CUMULATIVE GROWTH OF ASSETS (RETURNS COMPARISON)
cum_returns <- apply(returns_matrix, 2, function(x) cumprod(1 + x))
cum_df <- data.frame(Date = index(price_matrix)[-1], cum_returns)
melted_cum <- melt(cum_df, id.vars = "Date")

ggplot(melted_cum, aes(x = Date, y = value, color = variable)) +
  geom_line(size = 0.8) +
  labs(title = "Cumulative Growth of $1 Investment",
       subtitle = "Performance comparison since Jan 2023",
       x = "Date", y = "Growth Multiplier", color = "Ticker") +
  theme_minimal()


# 9. INDIVIDUAL ASSET RISK VS RETURN
asset_stats <- data.frame(
  Ticker = tickers,
  Return = avg_returns,
  Risk = apply(returns_matrix, 2, sd)
)

ggplot(asset_stats, aes(x = Risk, y = Return, label = Ticker)) +
  geom_point(color = "darkred", size = 3) +
  geom_text(vjust = -1, fontface = "bold") +
  labs(title = "Individual Asset Risk vs. Return",
       subtitle = "Comparison of mean return and standard deviation per ticker",
       x = "Volatility (Standard Deviation)", y = "Average Daily Return") +
  theme_minimal()