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


И файл **service.yaml** с манифестом *сервиса* 

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


И создадим файл **ingress.yaml**  :

<pre class="file" data-filename="./ingress.yaml" data-target="replace">
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: hello-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - http:
      paths:
        - path: /
          backend:
            serviceName: hello-service
            servicePort: 9000
</pre>


Давайте применим все манифесты

`kubectl apply -f deployment.yaml -f service.yaml -f ingress.yaml`{{execute T1}}

С помощью команды

`kubectl get pods`{{execute T1}}

можем наблюдать за тем, как создаются *поды*. 

Дождемся, пока *деплоймент* раскатится - т.е. когда все *поды* станут в статусе **Running**


## Запросы к ингресс-контроллеру

Можно делать запросы к **ингрес-контроллеру** и он будет маршрутизировать трафик в соответствии с правилами из **ингрессов**:

Обратимся к **ингресс-контроллеру** по внешнему **IP** адресу. 

`curl $NGINX_EXTERNAL_IP/version`{{execute T1}}

`curl $NGINX_EXTERNAL_IP/`{{execute T1}}

## Меняем правила марутизация трафика

Давайте поменяем правила маршрутизации так, чтобы все запросы к балансировщику на локейшен `/myapp/` проксировались  в `hello-service` на `9000` порт. Для того, чтобы это реализовать на стороне балансера нужно будет перезаписывать локейшн и "отрезать" `/myapp`. Сделать это можно с помощью директивы **rewrite-target** в **nginx**.  Но этой директивы нет объекте типа **Ingress**. Дополнительные настройки в **Ingress** можно передать с помощью *аннотаций*. Для директивы **rewrite-target** нужно использовать *аннотацию* `nginx.ingress.kubernetes.io/rewrite-target`. В нашем случае `/$2` означает: "заменить локейшн на 2-ую группу из регулярного выражения `/myapp($|/)(.*)` - т.е. фактически отрезать часть `/myapp($|/)`". Это то, что нам надо. 

Обновим манифест **ингресса**: 

<pre class="file" data-filename="./ingress.yaml" data-target="replace">
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: hello-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - http:
      paths:
        - path: /myapp($|/)(.*)
          backend:
            serviceName: hello-service
            servicePort: 9000
</pre>


И применим манифест: 

`kubectl apply -f ingress.yaml`{{execute T1}}

**Ингресс контроллер** обновил конфигурацию **nginx**, теперь, обращаясь по урлу `/` балансировщик будет отдавать **404**-ую ошибку (не найдено): 

`curl $NGINX_EXTERNAL_IP/`{{execute T1}}

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

Обращаясь по урлу `/myapp/version` , балансировщик будет отдавать версию сервиса `hello-service`:

`curl $NGINX_EXTERNAL_IP/myapp/version`{{execute T1}}

```
controlplane $ curl $NGINX_EXTERNAL_IP/myapp/version
{"version": "1"}
```

А по `/myapp/` :

`curl $NGINX_EXTERNAL_IP/myapp/`{{execute T1}}

будет отдавать :

```controlplane $ curl $NGINX_EXTERNAL_IP/myapp/
Hello world from hello-deployment-d67cff5cc-fhcl5!
```

Также мы с вами можем посмотреть, как выглядит конфигурация балансировщика **nginx**, с помощью команды:

`kubectl exec deploy/nginx-nginx-ingress-controller -n kube-system -- cat /etc/nginx/nginx.conf`{{execute T1}}





