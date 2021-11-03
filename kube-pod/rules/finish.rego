package sbercode

default error = []

pod_list[pods] {
  item := input.items[_]   
  item.kind == "Pod"                   
  pods := item
}

allow[msg] {  
  count(pod_list) > 0
  msg := "Pod created"
}

deny[msg] {  
  count(pod_list) = 0
  msg := "No pod found"
}