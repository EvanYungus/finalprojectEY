library(shiny)
# Define UI for application
ui <- fluidPage(
  titlePanel("Trends by Continent"),
  
  # Dropdown menu for selecting an indicator
  selectInput("series", "Select Indicator:", choices = unique(data_long$Series.Name)),
  
  # Slider input for selecting a year
  #sliderInput("year", "Select Year:", min = 2000, max = 2021, value = 2000, step = 1, sep = ''),
  
  # Leaflet map output
  leafletOutput("map", height = 500),
  
  # Plot output for the selected series and continent
  plotOutput("trendGraph")
)