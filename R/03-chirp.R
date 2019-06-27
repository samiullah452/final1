#' Launch
#'
#' Launch dashboard.
#'
#' @export
chirp <- function(){

  theme <- "paper"
  slider_color <- "white"
  font <- "Raleway"
  font_family <- "'Raleway', sans-serif"
  palette <- c("#4b2991", "#872ca2", "#c0369d", "#ea4f88", "#fa7876", "#f6a97a", "#edd9a3")
  vr_background <- "#052960"
  sentiment_palette <- c("red", "green")
  discrete <- c("#E58606", "#5D69B1", "#52BCA3", "#99C945", "#CC61B0", "#24796C", "#DAA51B",
                "#2F8AC4", "#764E9F", "#ED645A", "#CC3A8E", "#A5AA99")
  edge_color <- "#bababa"
  font_name <- gsub("[[:space:]]", "+", font)
  inverse <- FALSE

  # head
  head <- tagList(
    tags$link(
      href = paste0("https://fonts.googleapis.com/css?family=", font_name),
      rel = "stylesheet"
    ),
    tags$style(
      paste0("*{font-family: '", font, "', sans-serif;}")
    ),
    tags$link(
      href = "final-assets/pushbar.css",
      rel="stylesheet",
      type="text/css"
    ),
    tags$link(
      href = "final-assets/custom.css",
      rel = "stylesheet",
      type = "text/css"
    ),
    tags$script(
      src = "final-assets/pushbar.js"
    ),
    tags$link(
      href = "final-assets/please-wait.css",
      rel = "stylesheet",
      type = "text/css"
    ),
    tags$script(
      src = "final-assets/please-wait.min.js"
    ),
    tags$script(
      src = "https://unpkg.com/micromodal/dist/micromodal.min.js"
    ),
    tags$link(
      rel = "stylesheet",
      href = "https://use.fontawesome.com/releases/v5.7.2/css/all.css",
      integrity = "sha384-fnmOCqbTlWIlj8LyTjo7mOUStjsKC4pOpQbqyi7RrhN7udi9RwhKkMHpvLbHG9Sr",
      crossorigin = "anonymous"
    ),
    tags$script(
      src = "final-assets/custom.js"
    ),
    tags$link(
      rel="shortcut icon",
      href = "https://chirp.sh/img/chirp_favicon.png"
    ),
    tags$style(
      paste0(".pushbar{background-color:", slider_color, ";}")
    )
  )

  particles_json <- jsonlite::fromJSON(
    system.file("assets/particles.json", package = "final")
  )

  options(
    sentiment_palette = sentiment_palette,
    chirp_discrete = discrete,
    chirp_palette = palette,
    chirp_edge_color = edge_color,
    chirp_font_family = font_family,
    vr_background = vr_background
  )

  ui <- navbarPage(
    title = "chirp",
    fluid = TRUE,
    inverse = inverse,
    windowTitle = "chirp",
    header = head,
    theme = shinythemes::shinytheme(theme),
    id = "tabs",
    shinyjs::useShinyjs(),
    networks_ui("networks")


  )


  server <- function(input, output, session){
    c=mongo(collection="project_tweets",db = "project")

    session$sendCustomMessage(
      "load",
      paste("loading")
    )

    query <- parseQueryString(isolate(session$clientData$url_search))
    q<-as.integer(query[['id']])
    #min<-as.integer(query[['min']])
    #max<-as.integer(query[['max']])
    tweet <- c$find(paste0('{"Project_id":',q,'}'))
    tweet[["hashtags"]] <- tweet[["hashtags"]] %>% replace(.=="", NA)
    tweet[["mentions_screen_name"]] <- tweet[["mentions_screen_name"]] %>% replace(.=="", NA)
    tweet[["retweet_screen_name"]] <- tweet[["retweet_screen_name"]] %>% replace(.=="", NA)
    tweet[["quoted_screen_name"]] <- tweet[["quoted_screen_name"]] %>% replace(.=="", NA)
    #showTab(inputId = "tabs", target = "NETWORKS")
    #updateTabsetPanel(session = session, inputId = "tabs", selected = "NETWORKS")
    callModule(networks, "networks", dat = tweet)
  }
  shinyApp(ui, server)
}
