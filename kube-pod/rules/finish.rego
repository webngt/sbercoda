package sbercode

allow[msg] {  
    item := input.items[_]                                                                                                         
    item.kind == "Pod"                   
    msg := "Pod created"
}

deny[msg] {
  item := input.items[_]   
  not item.kind == "Pod"                   
  msg := "No pods found"
}