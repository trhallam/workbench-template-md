RV <- getRversion()
OS <- paste(RV, R.version["platform"], R.version["arch"], R.version["os"])
codename <- sub("Codename.\t", "", "jammy")
options(HTTPUserAgent = sprintf("R/%s R (%s)", RV, OS))
options(repos = c(
          carpentries = "https://carpentries.r-universe.dev/",
          CRAN = paste0("https://packagemanager.posit.co/all/__linux__/", codename, "/latest")
))
install.packages(c("sandpaper", "varnish", "pegboard", "tinkr", "rmarkdown"))
