library(shiny)
library(shinyAce)

shinyUI(
  fluidPage(
    titlePanel("Interface to SQLite DB"),

    splitLayout(
        fileInput("file", label = "SQLite database"),
        textOutput("errorFile")
    ),
    tabsetPanel(
      tabPanel("DB informations",
               textOutput("resume")),
      tabPanel("Tables content",
               uiOutput("listTable"),
               tableOutput("contentTable")),
      tabPanel("SQL Querying",
               splitLayout(
                 aceEditor(outputId = "query", value = "SQL query", mode = "sql", theme = "ambiance", height = "150px"),
                 verticalLayout(
                   actionButton("submit", label = "Execute"),
                   textOutput("logQuery")
                 )
               ),
               tableOutput("resQuery")
              )
    )
  )
)