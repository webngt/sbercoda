Поскольку у нас нет **ингресс-контроллера** встроенного, его необходимо поставить. 

Ставить будем в системный **namespace** `kube-system` с помощью утилиты **helm**:

`helm repo add bitnami https://charts.bitnami.com/bitnami`{{execute T1}}

`helm install nginx bitnami/nginx-ingress-controller -n kube-system`{{execute T1}}

Запустим в цикле команду, которая из всех *подов* `kube-system`, отфильтрует *под* **ингресс** **контроллера** по меткам `app.kubernetes.io/name` и `app.kubernetes.io/component`. 

`watch kubectl get -n kube-system pod -l app.kubernetes.io/name=nginx-ingress-controller -l app.kubernetes.io/component=controller`{{execute T1}}

Дождемся пока *под* **ингресс** **контроллера** не окажется в статусе **Running**. 

И выйдем из цикла сочетанием клавиш **Ctrl-C**.

**Ингресс-контроллер** в данном случае - это **nginx** и **контроллер**, который читает изменения сущности **Ingress**. **Nginx** внутри **Kubernetes** запущен, как обычное приложение, и для него также есть **Service**. Тип сервиса **LoadBalancer**, т.е. доступ к **nginx** будет извне кластера по внешнему **IP** адресу.  

Можно посмотреть на настройки этого сервиса:
`kubectl describe svc nginx-nginx-ingress-controller -n kube-system`{{execute T1}}


Сохраним значение внешнего **IP** в переменную окружения `NGINX_EXTERNAL_IP`.

`NGINX_EXTERNAL_IP=$(kubectl get service nginx-nginx-ingress-controller -n kube-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}")`{{execute T1}}

Теперь можем сделать запросы с помощью команды **curl**:

`curl $NGINX_EXTERNAL_IP/`{{execute T1}}

Т.к. созданных ингрессов еще нет, то nginx отдает дефолтную конфигурацию

```
controlplane $ curl $NGINX_EXTERNAL_IP/
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```



