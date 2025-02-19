
# Declare global variables used in the package to avoid warnings during devtools::check()

utils::globalVariables(c("Var1", "Freq"))
if(getRversion() >= "2.15.1") utils::globalVariables("Pourcentage")
