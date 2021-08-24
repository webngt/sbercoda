Теперь давайте посмотрим на тип **LoadBalancer**. 
Если  *сервис* имеет тип **LoadBalancer**, это значит, что нашему *сервису* будет назначен **внешний IP**. 


Обновим тип сервиса в файле service.yaml: 

<pre class="file" data-filename="./service.yaml" data-target="insert" data-marker="  type: NodePort">
  type: LoadBalancer</pre>

Применяем его 

`kubectl apply -f service.yaml`{{execute T1}}

Смотрим настройки сервиса во второй вкладке. 

```
NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/hello-service     LoadBalancer   10.108.237.251   172.17.0.15   9000:32296/TCP   6m53s
```

`TYPE` изменился на `LoadBalancer`, а в `EXTERNAL-IP`  получил значение `172.17.0.15`.

Давайте с вами убедимся, что при обращении по этому *IP* по порту `9000` будет отвечать наше приложение. 

## Получение внешнего IP

Получим `externalIp` с помощью **jsonpath** и сохраним его в переменную окружения `EXTERNAL_IP`

`EXTERNAL_IP=$(kubectl get service hello-service -o jsonpath="{.status.loadBalancer.ingress[0].ip}")`{{execute T1}}

## Доступ к приложению через внешний IP

Давайте сделаем запрос с помощью `curl` на этот **IP** и порт `9000`:

`curl http://$EXTERNAL_IP:9000/`{{execute T1}}

В результате получим ответ от одного из  *подов* деплоймента:

```
curl http://$EXTERNAL_IP:9000/
Hello world from hello-deployment-d67cff5cc-c47w5!
```

Если запустим в цикле, то будем получать ответы от разных *подов*:

`while true; do curl http://$EXTERNAL_IP:9000/ ; echo ''; sleep .5; done`{{execute T1}}

Выйти из цикла можно с помощью сочетания клавиш **Ctrl - C**

```
while true; do curl http://$EXTERNAL_IP:9000/ ; echo ''; sleep .5; done
Hello world from hello-deployment-d67cff5cc-c7hpw!
Hello world from hello-deployment-d67cff5cc-c7hpw!
Hello world from hello-deployment-d67cff5cc-c47w5!
Hello world from hello-deployment-d67cff5cc-c47w5!
Hello world from hello-deployment-d67cff5cc-c7hpw!
Hello world from hello-deployment-d67cff5cc-c47w5!
Hello world from hello-deployment-d67cff5cc-c47w5!
Hello world from hello-deployment-d67cff5cc-c7hpw!
^C
controlplane $
```

