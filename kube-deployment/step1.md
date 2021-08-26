Создадим **deployment.yaml** файл с манифестом **Kubernetes**: 

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

Применим манифест

`kubectl apply -f deployment.yaml`{{execute T1}}

`kubectl get pods`{{execute T1}}

Дождемся, пока деплоймент раскатится - т.е. когда все поды станут в статусе **Running**


```
NAME                               READY   STATUS    RESTARTS   AGE
hello-deployment-d67cff5cc-hrfh8   1/1     Running   0          35s
hello-deployment-d67cff5cc-hsf6g   1/1     Running   0          35s
```

## Состояние деплоймента

Состояние деплоймента можно получить с помощью команд:

`kubectl get deploy hello-deployment `{{execute T1}}

```
controlplane $ kubectl get deploy hello-deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-deployment   2/2     2            2           24m
```

Тут можно увидеть состояние более подробно:

`kubectl describe deploy hello-deployment`{{execute T1}}

Например, можно увидеть полную статистику по репликам:
```
Replicas:           2 desired | 2 updated | 2 total | 2 available | 0 unavailable
```
