install.packages("fpp2")
install.packages("fpp3")
install.packages("tsibble")
install.packages("tsfeatures")

library(fpp2)
library(fpp3)
library(dplyr)
install.packages("readxl")
library(readxl)
library(tsibble)
library(tsfeatures)
library(moments)


Germany <- read_excel ("/Users/PNHa/Library/CloudStorage/OneDrive-Personal/Forecasting/Germany.xlsx")
View (Germany)

#1
G <- ts(Germany$Temperature, start = c(1991, 1), frequency = 12) 

Gts <- as_tsibble(G)

view(Gts)


q1 <- quantile(Gts$value, 0.25)
q3 <- quantile(Gts$value, 0.75)
iqr <- q3 - q1
lower <- q1 - 1.5*iqr
upper <- q3 + 1.5*iqr
outliers <- Gts$value[Gts$value < lower | Gts$value > upper]
view(outliers)
summary(Gts$value)

mean(Gts$value)
median(Gts$value)
mode(Gts$value)

range(Gts$value)
sd(Gts$value)
var(Gts$value)
cv=sd(Gts$value)/mean(Gts$value)

#check normal distribution
qqnorm(Gts$value) 
qqline(Gts$value)
skewness(Gts$value)
hist(Gts$value, breaks = 20, main = "Histogram of Germany's Monthly Mean Temperature (°C) between 1991-2021", xlab = "Data Values")

#2
Gts |> autoplot(value) + ggtitle ("Germany's Monthly Mean Temperature (°C) between 1991-2021") + xlab ("Time") + ylab ("Mean temperature")

Gts |> ACF(value) |> autoplot() + ggtitle ("ACF of Germany's Monthly Mean Temperature (°C) between 1991-2021") + xlab ("lag")

Gts |> gg_tsdisplay(value, plot_type='partial', lag=36) + ggtitle ("ACF and PACF of Germany's Monthly Mean Temperature (°C) between 1991-2021") + xlab ("lag")


Gdcmp <- Gts |>
  model(stl = STL(value))

components(Gdcmp) |> autoplot() + ggtitle ("Decomposition of Germany's Monthly Mean Temperature (°C) between 1991-2021") + xlab ("Time")


Gts |> gg_season(value)

Gts|> features(value, features = guerrero)






#3

#difference 
a) 

Gts |> features(value, unitroot_kpss)

Gts |> features(value, unitroot_nsdiffs)

Gts |> features(value, unitroot_ndiffs)

Gts |> autoplot(difference(value,12)) + ggtitle ("Germany's Monthly Mean Temperature (°C) between 1991-2021 after seasonal differencing") + xlab ("lag")

Gts |> features(difference(value,12), unitroot_kpss)

Gts |> features(difference(value,12), unitroot_nsdiffs)

Gts |> features(difference(value,12), unitroot_ndiffs)

Gts |> gg_tsdisplay(difference(value,12), plot_type='partial') + ggtitle ("Germany's Monthly Mean Temperature (°C) between 1991-2021 after seasonal differencing") + xlab ("lag")




b)

GArima <- Gts |>    # Estimate three models
  model(
    arima303211 = ARIMA(value ~ 0 + pdq(3,0,3) + PDQ(2,1,1)),
    arima300210 = ARIMA(value ~ pdq(3,0,0) + PDQ(2,1,0)), 
    auto = ARIMA(value, stepwise = FALSE, approx = FALSE)
  )

GArima |> pivot_longer(everything(), names_to = "Model name", values_to = "Orders")

report(GArima)

glance(GArima) |> arrange(AICc) |> select(.model:BIC) |> 

augment(GArima) |> features(.innov, ljung_box, lag = 36, dof = 4)

augment(GArima) |> features(.innov, ljung_box, lag = 36, dof = 4)

forecast(GArima, h=120) |> 
  filter(.model == "auto") |> autoplot(Gts) + ggtitle ("Forecast of Germany's Monthly Mean Temperature (°C) between 2022-2032 using auto (3,0,0)(1,1,2)[12] model") + xlab ("Time") + ylab ("")

GArima |> select(auto) |> gg_tsresiduals(lag=36) + ggtitle ("Residuals of Germany's Monthly Mean Temperature between 1991-2021 using auto ARIMA(3,0,0)(1,1,2)[12] model") + xlab ("lag")


GArima |> select(arima300210) |> gg_tsresiduals(lag=36) + ggtitle ("Residuals of Germany's Monthly Mean Temperature between 1991-2021 using ARIMA(3,0,0)(2,1,1)[12] model") + xlab ("lag")


GArima |> select(arima303211) |> gg_tsresiduals(lag=36) + ggtitle ("Residuals of Germany's Monthly Mean Temperature between 1991-2021 using ARIMA(3,0,3)(2,1,1)[12] model") + xlab ("lag")






#forecasting 
GArima |> forecast (h=120)|> filter(.model=='auto') |> autoplot(Gts) + ggtitle ("Forecasting Germany's Monthly Mean Temperature between 2022-2032 using arima300112 model") + xlab ("lag")

