Для демонстрации работы механизма **обнаружения сервисов**  нам нужен внешний, по отношению к нашему *деплойменту*, *под*. Давайте его запустим с помощью команды `kubectl run`:

`kubectl run -it --rm busybox --image=busybox`{{execute T1}}

Мы находимся "внутри" контейнера *пода*, и можем запускать команды. 

Поскольку *поды* находятся в одном пространстве имен, то можем обратиться к нашем приложению просто по доменному имени `{имя сервиса}`, т.е. в нашем случае `hello-service` :

`wget -qO- http://hello-service:9000/`{{execute T1}}

И получим ответ от одного из *подов* приложения:

```
/ # wget -qO- http://hello-service:9000/
Hello world from hello-deployment-d67cff5cc-c47w5!/ # 
```

Также можем обратиться по доменному имени `{имя сервиса}.{имя неймспейса}`, в нашем случае это будет `hello-service.myapp`

`wget -qO- http://hello-service.myapp:9000/`{{execute T1}}

И получим ответ от одного из *подов* приложения:

```
/ # wget -qO- http://hello-service.myapp:9000/
Hello world from hello-deployment-d67cff5cc-c7hpw!/ # 
```

А также по полному доменному имени:

`wget -qO- http://hello-service.myapp.svc.cluster.local:9000/`{{execute T1}}

И получим ответ от одного из *подов* приложения:

```
/ # wget -qO- http://hello-service.myapp.svc.cluster.local:9000/
Hello world from hello-deployment-d67cff5cc-c7hpw!/ # 
```

Теперь можно удалить все объекты можно с помощью команды:

`kubectl delete -f service.yaml -f deployment.yaml`{{execute T1}}
