library(leaflet)
library(shiny)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(stringr)
data <- read.csv("dataset.csv", stringsAsFactors = FALSE)
#clean up dataset
data <- data %>% mutate_if(is.factor, as.character)
options(scipen = 999) #normal notation
unique(data$Series.Name)
data <- data %>%
  rename_with(~str_remove_all(.x, "X|\\.YR"), starts_with("X"))
#convert to long format
data_long <- data %>%
  pivot_longer(
    cols = starts_with("20"), # Selects all columns that start with '20', which are your year columns
    names_to = "Year",        # The new column that will contain the year
    values_to = "Value"       # The new column that will contain the values from the year columns
  )
data_long <- data_long %>%
  rename(Continents = Country.Name)

server <- function(input, output, session) {
  
  #store cont
  selected_continent <- reactiveVal(NULL)
  
  #Update info
  observeEvent(input$map_marker_click, {
    if (!is.null(input$map_marker_click)) {
      selected_continent(input$map_marker_click$id)
    }
  })
  
  #reactive expression
  graph_data <- reactive({
    req(selected_continent(), input$series)  # Ensure all inputs are available
    
    # Filter data based on cond
    filtered <- data_long %>%
      filter(Continents == selected_continent(), Series.Name == input$series, Year >= 2000 & Year <= 2021) %>%
      arrange(Year)
    
    #debug
    print(head(filtered))
    
    filtered
  })
  
  # Coordinates
  coords <- data.frame(
    Continent = c("North America", "Africa Western and Central", "Europe & Central Asia",
                  "East Asia & Pacific", "Middle East & North Africa", "Sub-Saharan Africa",
                  "South Asia", "Latin America & Caribbean"),
    Lat = c(40, 10, 50, 30, 30, -10, 20, -20),
    Long = c(-100, 10, 30, 110, 45, 25, 90, -60)
  )
  
  # Render the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%  
      addMarkers(data = coords, ~Long, ~Lat, popup = ~Continent, layerId = ~Continent)
  })
  
  #render map
  output$trendGraph <- renderPlot({
    req(graph_data()) 
    
    gg_data <- graph_data()  
    
    ggplot(gg_data, aes(x = Year, y = Value, group = 1)) +
      geom_line() +
      geom_point(size = 2) +
      expand_limits(y = 0) +
      labs(title = paste(input$series, "Trends in", selected_continent()), 
           x = "Year", 
           y = "Value") +
      theme_minimal()
  })
  
}
