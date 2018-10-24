app <- ShinyDriver$new("../")
app$snapshotInit("test_cyper_NOEC")

# Input 'contents_rows_current' was set, but doesn't have an input binding.
# Input 'contents_rows_all' was set, but doesn't have an input binding.
app$setInputs(navbar = "SSD", timeout_ = 10000)
app$snapshot()
app$setInputs(tabsetpanel = "Goodness of Fit", timeout_ = 10000)
app$snapshot()
app$setInputs(tabsetpanel = "HC5 and Plot", timeout_ = 10000)
app$snapshot(list(output = "coolplot"))
app$snapshot(list(output = "bestfit2"))
app$snapshot(list(output = "hc5"))
