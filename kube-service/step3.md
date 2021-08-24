Изменим тип существующего **сервиса** на **NodePort** 

Обновим  файл **service.yaml** с описанием **сервиса**:

<pre class="file" data-filename="./service.yaml" data-target="insert" data-marker="  type: ClusterIP">
  type: NodePort</pre>

Применим манифест: 

`kubectl apply -f service.yaml`{{execute T1}}

Во второй вкладе можем увидеть обновленный статус **сервиса**:

```
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/hello-service     NodePort    10.108.237.251   <none>        9000:32296/TCP   5m12s
```

`TYPE` изменился на `NodePort`, а в `PORT` появился порт ноды - `32296`.

Давайте с вами убедимся, что при обращении по этому *порту* на любую из *нод* будет отвечать наше приложение. 

## Получение порта ноды

Получить **nodePort** и сохранить его в переменной окружени можно с помощью формата вывода **jsonpath** команды `kubectl get`.   

Получаем полную информацию об объекте **Service** в формате **json**:

`kubectl get service hello-service -o json | jq`{{execute T1}}

Смотрим, где именно в **json** находится информация о **nodePort**. И через **jsonpath** запрашиваем только его:

`kubectl get service hello-service -o jsonpath="{.spec.ports[0].nodePort}"`{{execute T1}}

Сохраняем в переменную окружения:

`NODE_PORT=$(kubectl get service hello-service -o jsonpath="{.spec.ports[0].nodePort}")`{{execute T1}}

## Запросы к приложению через порт ноды

Давайте обратимся к *нодам* по порту `$NODE_PORT`:

При обращении на этот *порт* на любой *ноде* кластера **Kubernetes**, у нас будут происходить обращения к нашему *сервису*:

На рабочей *ноде*:

`curl http://node01:$NODE_PORT/`{{execute T1}}

```
curl http://node01:$NODE_PORT/
Hello world from hello-deployment-d67cff5cc-q6xcw!
```

На *управляющей*:

`curl http://controlplane:$NODE_PORT/`{{execute T1}}

```
curl http://controlplane:$NODE_PORT/
Hello world from hello-deployment-d67cff5cc-c7hpw!
```