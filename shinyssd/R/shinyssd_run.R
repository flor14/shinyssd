#' Start shinyssd
#' @title shinyssd: species sensitivity distributions for ecotoxicological risk assessment
#' @description The shinyssd web application is a versatile and easy to use tool that serves to simultaneously model the species sensitivity distributions (SSD) curve of a user-defined toxicity dataset based on four different statistical distribution models (log-normal, log-logistic, Weibull, Pareto). shinyssd directly calculates three estimators Hazard Concentration 1 percent (HC1), 5 percent (HC5) and 10 percent (HC10) associated to the four distribution models together with its confidence intervals, allowing the user to select the statistical distribution and associated HC values that best adjust the dataset.
#' @keywords shinyssd, ssd, shiny
#' @examples
#' \dontrun{
#' library(shinyssd)
#' shinyssd::shinyssd_run()
#' }
#' @export

shinyssd_run <- function() {
  appDir <- system.file("shiny", package = "shinyssd")
  if (appDir == "") {
    stop("Could not find directory. Try re-installing `shinyssd`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}


