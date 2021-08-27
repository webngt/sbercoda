Создадим **deployment.yaml**: 

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
          image: schetinnikov/hello-app:v3
          ports:
            - containerPort: 8000
</pre>

Создадим файл **service.yaml**

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

Применим манифесты:

`kubectl apply -f deployment.yaml -f service.yaml`{{execute T1}}

Можем наблюдать за тем, как создаются *поды*. 

`kubectl get pods -l app=hello-demo `{{execute T1}}

Дождемся, пока *деплоймент* раскатится - т.е. когда все *поды* окажутся в статусе **Running**

```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/hello-deployment-7d79b5c767-2v8th   1/1     Running   0          70s
pod/hello-deployment-7d79b5c767-4hxll   1/1     Running   0          70s
```

## Переменные окружения

Мы используем версию приложения, которая по пути`/env` отдает свою конфигурацию, вместе с переменными окружения.

Давайте сделаем запрос к приложению и посмотрим на настройки по умолчанию. 

Сохраним **clusterIp** *сервиса* в переменную `CLUSTER_IP`:

`CLUSTER_IP=$(kubectl get service hello-service -o jsonpath="{.spec.clusterIP}")`{{execute T1}}

Смотрим ответ приложения:

`curl -s http://$CLUSTER_IP:9000/env | jq`{{execute T1}}

```
controlplane $ curl -s http://$CLUSTER_IP:9000/env | jq
{
  "DATABASE_URI": "",
  "HOSTNAME": "hello-deployment-7d79b5c767-4hxll",
  "GREETING": "Hello"
}
```

Теперь изменим их, добавим секцию **env**  в спецификацию контейнера деплоймента. 

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
          image: schetinnikov/hello-app:v3
          ports:
            - containerPort: 8000
          env:
            - name: DATABASE_URI
              value: 'postgresql+psycopg2://myuser:passwd@postgres.myapp.svc.cluster.local:5432/myapp'
            - name: GREETING
              value: 'Alloha'
</pre>


Давайте применим манифест

`kubectl apply -f deployment.yaml`{{execute T1}}

Можем наблюдать за тем, как создаются *поды*. 

`kubectl get pods -l app=hello-demo `{{execute T1}}

Дождемся, пока *деплоймент* раскатится - т.е. когда все *поды* окажутся в статусе **Running**

После обновления, приложение отдает другие переменные окружения: 

`curl -s http://$CLUSTER_IP:9000/env | jq`{{execute T1}}

```
controlplane $ curl -s http://$CLUSTER_IP:9000/env | jq
{
  "HOSTNAME": "hello-deployment-9797f8f6d-nnzcm",
  "DATABASE_URI": "postgresql+psycopg2://myuser:passwd@postgres.myapp.svc.cluster.local:5432/myapp",
  "GREETING": "Alloha"
}
```