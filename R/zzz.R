.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(
    "final-assets",
    system.file("assets", package = "final")
  )
}
