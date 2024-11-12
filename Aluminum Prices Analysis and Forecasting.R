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


Al <- read_excel ("/Users/PNHa/Library/CloudStorage/OneDrive-Personal/Forecasting/Al.xlsx")
View (Al)

A <- ts(Al$`Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton`, start = c(1992, 1), frequency = 12) 

A <- as_tsibble(A)

View(A)

A |> autoplot(value) + ggtitle ("Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton, between 1992-2022") + xlab ("Time") + ylab ("US$ per metric ton")

A |> features(value, features = guerrero)


#decomposition
Alumdcmp <- A |>       
  model(stl = STL(value))
components(Alumdcmp) |> autoplot() + ggtitle ("Decomposition of Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton, between 1992-2022") + xlab ("Time") + ylab ("US$ per metric ton")

components(Alumdcmp) |> select(index, trend, season_adjust) |> autoplot(trend)\


#remove outliers


Adcmp <- A |>
  model(STL(value ~ season(period = 1), robust = TRUE)) |>
  components() 

components(Adcmp) 

Adcmp |> autoplot() + ggtitle ("Decomposition of Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton, between 1992-2022") + xlab ("Time")

Adcmp |> autoplot()

#3b Forecast
Aq1 <- quantile(A$value, 0.25)
Aq3 <- quantile(A$value, 0.75)
Aiqr <- Aq3 - Aq1
Alower <- Aq1 - 1.5*Aiqr
Aupper <- Aq3 + 1.5*Aiqr
Aoutliers <- A$value[A$value < Alower | A$value > Aupper]

Aoutliers <- Adcmp |>
  filter(
    remainder < quantile(remainder, 0.25) - 3*IQR(remainder) |
      remainder > quantile(remainder, 0.75) + 3*IQR(remainder))

view(Aoutliers)    


# View the detected outliers

Adcmp <- A |>
  model(stl = STL(value))

components(Adcmp) |> autoplot() + ggtitle ("Decomposition of Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton, between 1992-2022") + xlab ("Time")

Adcmp |> autoplot()


A_miss <- A |> 
  anti_join(Aoutliers) |> fill_gaps()              # Replace the outliers with missing values


A_fill <- A_miss |> model(ARIMA(value)) |>     # USing ARIMA to replace the outlier
  interpolate(A_miss)

A_fill |> autoplot(value) + ylim(c(0,3498.373))  +    # Redraw the data
  labs(title = "Monthly Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton, between 1992-2022 
                                                                using ARIMA to replace outliers", y = "US$ per metric ton")

A_fill |> right_join(Aoutliers |> select(-value))

fit <- ts(A_fill$value, start = c(1992, 1), frequency = 12) 

fit <- as_tsibble(A_fill)


#Part B b) train test accuarcy 
A_train <- A_fill |> filter(index <= max(index)-12)

FA <- A_train |> 
  model(
    Mean = MEAN(value), 
    Naive = NAIVE(value),
    ANN = ETS(value ~ error("A") + trend("N") + season("N")),
    AAN = ETS(value ~ error("A") + trend("A") + season("N"))
  ) |>
  mutate(combination = (ANN + AAN) / 2) 
accuracy(FA) |> arrange(MASE)

FCA <- FA |> forecast(h = 12) 
FCA |> autoplot(A_train) + ggtitle("Forecasts for monthly Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                     between Jan/2022-Dec/2022") + xlab("Time") + ylab("US$ per metric ton")
FCA |> autoplot(A_train |> filter(index >= max (index)-107), size =1.5) + ggtitle("Forecasts for monthly Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                           between Jan/2022-Dec/2022") + xlab("Time") + ylab("US$ per metric ton")
accuracy(FCA, A_fill) |> arrange(MASE)
FFCA <- FA |>  forecast(h = 12) 
FFCA |> autoplot(A_fill) + ggtitle("Forecasts for monthly Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton, 
                            using predicted values and actual value of months from year 2022") + xlab("Time") + ylab("US$ per metric ton")

FFCA |> autoplot(A_fill |> filter(index >= max (index)-107, size = 1.5) + ggtitle("Forecasts for monthly Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton, using predicted values and actual value of months from year 2022") + xlab("Time") + ylab("US$ per metric ton")

                 
                 
fitu <- A_fill |>
  model(ANN = ETS(value ~ error("A") + trend("N") + season("N")))
report(fitu)

fitunaive <- A_fill |>
  model(Naive = NAIVE(value))
report(fitunaive)

fitu |>
  autoplot(value +
  geom_line(aes(y = .fitted), col="#D55E00",
            data = augment(FA)) +
  labs(y="$US per metric ton", title="Aluminum") +
  guides(colour = "none")

  

fitu <- A_fill |> model(ses = ETS(value ~ error("A") + trend("N") + season("N")))
report(fitu)




#Part B d)

A_forecast <- A_fill |> filter(index <= max(index))

A_f <- A_forecast |>
 model( 
   Mean = MEAN(value), 
   Naive = NAIVE(value),
   ANN = ETS(value ~ error("A") + trend("N") + season("N")),
   AAN = ETS(value ~ error("A") + trend("A") + season("N"))
 ) |>
   mutate(combination = (ANN + AAN) / 2) 
 
 accuracy(FA) |> arrange(MASE)
   
                 
A_future <- A_f |> forecast(h = 12) 
A_future |> autoplot(A_forecast) + ggtitle("Forecasts for monthly Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton between 2023-2024") + xlab("Time") + ylab("US$ per metric ton") 



#check residuals



FA |> select (Naive) |> gg_tsresiduals () + 
  ggtitle("Residuals from forecasting monthly Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                               between 2023-2024 using Naïve method")


FA |> select (Mean) |> gg_tsresiduals () + 
  ggtitle("Residuals from forecasting Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                            between 2023-2024 using Average method")


FA |> select (AAN) |> gg_tsresiduals () + 
  ggtitle("Residuals from forecasting Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                            between 2023-2024 using AAN model")

FA |> select (ANN) |> gg_tsresiduals () + 
  ggtitle("Residuals from forecasting Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                            between 2023-2024. using ANN model")

ANN_residuals <- FA |> select (ANN) |> residuals ()
# Extract the 'Naive' column as a numeric vector
ANN_numeric <- as.numeric(unlist(ANN_residuals))

# Perform the Shapiro-Wilk test
ANNshapiro_test <- shapiro.test(ANN_numeric)

# Print the test results
print(ANNshapiro_test)


# d) draw 1 only the best model

A_AAN <- A_fill |> filter(index <= max(index))

A_AANfuture <- A_AAN |>
  model(AAN = ETS(value ~ error("A") + trend("A") + season("N")))


accuracy(FA) |> arrange(MASE)


A_A <- A_AANfuture |> forecast(h = 24) 
A_A |> autoplot(A_forecast) + ggtitle("Forecasts for monthly Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, 
                                 US$ per metric ton during 2024 using ANN model") + xlab("Time") + ylab("US$ per metric ton") 





#check residuals



FA |> select (Naive) |> gg_tsresiduals () + 
  ggtitle("Residuals from forecasting monthly Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                               between 2023-2024 using Naïve method")

FA |> select (Mean) |> gg_tsresiduals () + 
  ggtitle("Residuals from forecasting Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                            between 2023-2024 using Mean method")


FA |> select (AAN) |> gg_tsresiduals () + 
  ggtitle("Residuals from forecasting Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                            between 2023-2024 using AAN model")

FA |> select (ANN) |> gg_tsresiduals () + 
  ggtitle("Residuals from forecasting Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                            between 2023-2024 using ANN model")
FA |> select (combination) |> gg_tsresiduals () + 
  ggtitle("Residuals from forecasting Aluminum, 99.5% minimum purity, LME spot price, CIF UK ports, US$ per metric ton 
                                                            between 2023-2024 using combination of AAN and ANN model")

