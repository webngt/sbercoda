package sbercode

hasError := contains(input.mvn_out, "[ERROR]")
hasInfo := contains(input.mvn_out, "[INFO]")

allow[msg] {  
  not hasError
  hasInfo
  msg := input.mvn_out
}

deny[msg] {  
  hasError
  hasInfo
  msg := input.mvn_out
}

error[msg] {
  not hasInfo  
  msg := input.mvn_out
}