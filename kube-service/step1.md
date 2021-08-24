## Создание сервиса

Создадим **deployment.yaml** файл с описанием **деплоймента**: 

<pre class="file" data-filename="./deployment.yaml" data-target="replace">
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-demo
  strategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: hello-demo
    spec:
      containers:
        - name: hello-demo
          image: schetinnikov/hello-app:v1
          ports:
            - containerPort: 8000
</pre>

И файл **service.yaml** с описанием **сервиса** 

<pre class="file" data-filename="./service.yaml" data-target="replace">
apiVersion: v1
kind: Service
metadata:
  name: hello-service
spec:
  selector:
    app: hello-demo
  ports:
    - port: 9000
      targetPort: 8000
  type: ClusterIP
</pre>

Применим манифесты

`kubectl apply -f deployment.yaml -f service.yaml`{{execute T1}}

Во втором терминале можем наблюдать за тем, как создаются *поды*. 

```
NAME                                   READY   STATUS              RESTARTS   AGE
pod/hello-deployment-d67cff5cc-c7hpw   0/1     ContainerCreating   0          7s
pod/hello-deployment-d67cff5cc-q6xcw   0/1     ContainerCreating   0          7s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-deployment   0/2     2            0           7s

NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/hello-service   ClusterIP   10.108.237.251   <none>        9000/TCP   7s
```

Дождемся, пока *деплоймент* раскатится - т.е. когда все *поды* станут в статусе **Running**

```
NAME                                   READY   STATUS    RESTARTS   AGE
pod/hello-deployment-d67cff5cc-c7hpw   1/1     Running   0          67s
pod/hello-deployment-d67cff5cc-q6xcw   1/1     Running   0          67s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-deployment   2/2     2            2           67s
```

## Состояние сервиса

Посмотреть состояние **сервиса** можно с помощью команды: 

`kubectl describe service hello-service`{{execute T1}}

Команда выведет информацию о **сервисе**:

```
controlplane $ kubectl describe service hello-service
Name:              hello-service
Namespace:         myapp
Labels:            <none>
Annotations:       Selector:  app=hello-demo
Type:              ClusterIP
IP:                10.108.237.251
Port:              <unset>  9000/TCP
TargetPort:        8000/TCP
Endpoints:         10.244.1.3:8000,10.244.1.4:8000
Session Affinity:  None
Events:            <none>
```

Из интересного, можно увидеть список конкретных **ip** подов, на которые будет направляться трафик в поле **Endpoints**.

Можно убедится, что это именно *поды* нашего *деплоймента*. 

Запустим команду 

`kubectl get pods -owide`{{execute T1}}. 

Параметр `-o wide` используется для расширенного вывода. Сравнивая вывод, можем убедиться, что в поле **Endpoints** именно **ip** адреса *подов* нашего *деплоймента*.

## Создание сервиса с помощью kubectl expose deployment

Мы также могли создать **сервис**, используя *императивную* команду `kubectl expose deployment`. Давайте создадим **сервис** с именем `hello-service-2` для нашего *деплоймента* `hello-deployment` : 

`kubectl expose deployment hello-deployment --type=ClusterIP --name=hello-service-2`{{execute T1}}

И посмотрим его настройки:

`kubectl describe svc hello-service-2`{{execute T1}}

> svc - сокращенное название для ресурса service

Получили сервис с другим **IP**, но теми же самыми **Endpoints**:

```
controlplane $  kubectl describe svc hello-service-2
Name:              hello-service-2
Namespace:         myapp
Labels:            <none>
Annotations:       <none>
Selector:          app=hello-demo
Type:              ClusterIP
IP:                10.98.145.31
Port:              <unset>  8000/TCP
TargetPort:        8000/TCP
Endpoints:         10.244.1.3:8000,10.244.1.4:8000
Session Affinity:  None
Events:            <none>
```

Теперь можем удалить этот **сервис** с помощью команды:

`kubectl delete svc hello-service-2`{{execute T1}}

## Обновление деплоймента

Обновим количество *реплик* и убедимся, что **сервис** `hello-service` подхватит новый *под*:

<pre class="file" data-filename="./deployment.yaml" data-target="insert" data-marker="  replicas: 2">
  replicas: 3</pre>

Применяем манифест:

`kubectl apply -f deployment.yaml`{{execute T1}}

Теперь смотрим в **Endpoints**.

`kubectl describe service hello-service`{{execute T1}}

И новый *под* действительно добавился в **Endpoints**:

```
Name:              hello-service
Namespace:         myapp
Labels:            <none>
Annotations:       Selector:  app=hello-demo
Type:              ClusterIP
IP:                10.108.237.251
Port:              <unset>  9000/TCP
TargetPort:        8000/TCP
Endpoints:         10.244.1.3:8000,10.244.1.4:8000,10.244.1.5:8000
Session Affinity:  None
Events:            <none>
```

## Правила маршрутизации в iptables

Поскольку **сервис** реализуется с помощью правил маршрутизации трафика на **iptables**, то мы можем посмотреть, какие правила прописаны для нашего **сервиса**:

`iptables-save | grep hello-service`{{execute T1}}

И видим правила:

```
-A KUBE-SEP-IR7NZTMQJJ4DUDF4 -s 10.244.1.5/32 -m comment --comment "myapp/hello-service:" -j KUBE-MARK-MASQ
-A KUBE-SEP-IR7NZTMQJJ4DUDF4 -p tcp -m comment --comment "myapp/hello-service:" -m tcp -j DNAT --to-destination 10.244.1.5:8000
-A KUBE-SEP-U4C2XSUEI4EBKBSC -s 10.244.1.3/32 -m comment --comment "myapp/hello-service:" -j KUBE-MARK-MASQ
-A KUBE-SEP-U4C2XSUEI4EBKBSC -p tcp -m comment --comment "myapp/hello-service:" -m tcp -j DNAT --to-destination 10.244.1.3:8000
-A KUBE-SEP-VFLPNOIMHIWUJ3TQ -s 10.244.1.4/32 -m comment --comment "myapp/hello-service:" -j KUBE-MARK-MASQ
-A KUBE-SEP-VFLPNOIMHIWUJ3TQ -p tcp -m comment --comment "myapp/hello-service:" -m tcp -j DNAT --to-destination 10.244.1.4:8000
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.108.237.251/32 -p tcp -m comment --comment "myapp/hello-service: cluster IP" -m tcp --dport 9000 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.108.237.251/32 -p tcp -m comment --comment "myapp/hello-service: cluster IP" -m tcp --dport 9000 -j KUBE-SVC-UXDM6DTBGPPHEIIP
-A KUBE-SVC-UXDM6DTBGPPHEIIP -m comment --comment "myapp/hello-service:" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-U4C2XSUEI4EBKBSC
-A KUBE-SVC-UXDM6DTBGPPHEIIP -m comment --comment "myapp/hello-service:" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-VFLPNOIMHIWUJ3TQ
```

