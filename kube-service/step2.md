Созданный сервис имеет тип **ClusterIP**, это значит, что нашему **сервису** был назначен виртуальный **IP**. Узнать его мы можем из статуса **сервиса** с помощью команды `kubectl describe`.  

Давайте сделаем запрос на этот **IP** адрес , и убедимся, что приложение действительно на нем отвечает. 

## Получение ClusterIP

Получить **ClusterIP** и сохранить его в переменной окружени можно с помощью формата вывода **jsonpath** команды `kubectl get`.   

Получаем полную информацию об объекте **Service** в формате **json**:

`kubectl get service hello-service -o json | jq`{{execute T1}}

Смотрим, где именно в **json** находится информация с **ClusterIP**. И через **jsonpath** запрашиваем только его:

`kubectl get service hello-service -o jsonpath="{.spec.clusterIP}"`{{execute T1}}

Сохраняем в переменную окружения:

`CLUSTER_IP=$(kubectl get service hello-service -o jsonpath="{.spec.clusterIP}")`{{execute T1}} 

Проверим, что сохранилось в переменную окружения:

`echo $CLUSTER_IP`{{execute T1}}

```
controlplane $ echo $CLUSTER_IP
10.108.237.251
```

## Запросы к приложению через ClusterIP

Давайте обратимся к **ClusterIP** по `9000` порту:

`curl http://$CLUSTER_IP:9000/`{{execute T1}}

```
curl http://$CLUSTER_IP:9000/
Hello world from hello-deployment-d67cff5cc-c7hpw!
```

Если запустим в цикле, то будем получать ответы от разных *подов*:

`while true; do curl http://$CLUSTER_IP:9000/ ; echo ''; sleep .5; done`{{execute T1}}

Выйти из цикла можно с помощью сочетания клавиш **Ctrl - C**

```
$ while true; do curl http://$CLUSTER_IP:9000/ ; echo ''; sleep .5; done
Hello world from hello-deployment-d67cff5cc-c47w5!
Hello world from hello-deployment-d67cff5cc-q6xcw!
Hello world from hello-deployment-d67cff5cc-c7hpw!
Hello world from hello-deployment-d67cff5cc-c7hpw!
Hello world from hello-deployment-d67cff5cc-q6xcw!
Hello world from hello-deployment-d67cff5cc-c47w5!
Hello world from hello-deployment-d67cff5cc-c7hpw!
Hello world from hello-deployment-d67cff5cc-c7hpw!
Hello world from hello-deployment-d67cff5cc-q6xcw!
Hello world from hello-deployment-d67cff5cc-q6xcw!
Hello world from hello-deployment-d67cff5cc-q6xcw!
Hello world from hello-deployment-d67cff5cc-c47w5!
Hello world from hello-deployment-d67cff5cc-c47w5!
Hello world from hello-deployment-d67cff5cc-q6xcw!
^C
controlplane $ 
```

