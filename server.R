library(shiny)
library(shinyAce)
library(RSQLite)

# debug function
log <- function (...) {
  cat(..., "\n", file = stderr())
}

shinyServer(
  function(input, output, session) {

    # Get database connection
    getDB <- eventReactive(input$file, {
      if (is.null(input$file)) return (NULL)
      con <- try(dbConnect(RSQLite::SQLite(), as.character(input$file$datapath)), silent = T)
      if (class(con) == "try-error") {
        output$errorFile = renderText({ "Not a SQLite database !"})
        con <- NULL
      }
      con
    })
    
    # Add informations on database
    output$resume <- renderText({
      db = getDB()
      if (is.null(db)) return (NULL)
      paste(length(dbListTables(db)), "table(s) in database")
    })

    # Choice list to select table to show
    output$listTable <- renderUI({
      db = getDB()
      if (is.null(db)) return (NULL)
      choix = dbListTables(db)
      selectInput("listTable", label = "Select table", choices = choix)
    })
    
    # Show table content 
    # -> result from the query : SELECT * FROM table
    output$contentTable <- renderTable({
      db = getDB()
      if (is.null(db)) return (NULL)
      if (is.null(input$listTable)) return (NULL)
      query = paste("SELECT * FROM", input$listTable)
      res = tryCatch(dbGetQuery(db, query), error = function(e) return (NULL))
      res
    })
    
    # Show query result
    resQuery <- eventReactive(input$submit, {
      db = getDB()
      if (is.null(db)) return (NULL)
      query = input$query
      start = Sys.time()
      res = tryCatch(dbGetQuery(db, query), error = function(e) return(e))
      end = Sys.time()
      if ("data.frame" %in% class(res)) {
        output$logQuery = renderText({ 
          paste("OK.", round(as.numeric(end - start) * 1000), "ms") 
        })
        return (res)
      } else {
        output$logQuery = renderText({ res$message })
        return (NULL)
      }
    })
    output$resQuery <- renderTable({
      resQuery()
    })
  }
)