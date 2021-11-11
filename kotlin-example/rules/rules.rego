package sbercode

default error = []

hasError := contains(input.out, "[ERROR]")
hasInfo := contains(input.out, "[INFO]")

allow[msg] {  
  not hasError
  hasInfo
  msg := input.out
}

deny[msg] {  
  hasError
  hasInfo
  msg := input.out
}

error[msg] {
  not hasInfo  
  msg := input.out
}