app <- ShinyDriver$new("../")
app$snapshotInit("mytest")

# Input 'contents_rows_current' was set, but doesn't have an input binding.
# Input 'contents_rows_all' was set, but doesn't have an input binding.
app$snapshot()
app$setInputs(ChemicalName = "Glyphosate")
app$snapshot()
app$setInputs(Endpoint = "EC50")
app$snapshot()
app$setInputs(ChemicalName = "Cypermethrin")
app$snapshot()
app$setInputs(Endpoint = "LC50")
app$snapshot()
app$setInputs(ChemicalName = "Glyphosate")
app$snapshot()
