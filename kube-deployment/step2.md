Давайте поменяем количество реплик в манифесте:

<pre class="file" data-filename="./deployment.yaml" data-target="insert" data-marker="  replicas: 2">
replicas: 3</pre>


И применим его.

`kubectl apply -f deployment.yaml`{{execute T1}}

Во второй вкладке можем наблюдать за тем, как создаcтся еще одна *пода*.

## Масштабирование деплоймента с помощью kubectl scale 

Также мы можем масштабировать **деплоймент** с помощью *императивной* команды **kubectl scale**.

Например, `kubectl scale deploy/hello-deployment --replicas=2`{{execute T1}}

`watch kubectl get pods -l app=hello-demo`{{execute T1}}

Можем наблюдать за тем, как сначала удаляется *пода*:

```
NAME                               READY   STATUS        RESTARTS   AGE
hello-deployment-d67cff5cc-f96r6   1/1     Terminating   0          16s
hello-deployment-d67cff5cc-hrfh8   1/1     Running       0          95s
hello-deployment-d67cff5cc-hsf6g   1/1     Running       0          95s
```

Дождемся, пока под удалится, и потом выйдем из команды с помощью сочетания клавиш **Ctrl-C**

А после команды:

`kubectl scale deploy/hello-deployment --replicas=3`{{execute T1}}

`watch kubectl get pods -l app=hello-demo`{{execute T1}}

создается еще один *под*:
```
NAME                               READY   STATUS    RESTARTS   AGE
hello-deployment-d67cff5cc-8zbpd   1/1     Running   0          4s
hello-deployment-d67cff5cc-hrfh8   1/1     Running   0          2m55s
hello-deployment-d67cff5cc-hsf6g   1/1     Running   0          2m55s
```

Дождемся, пока под запустится, и потом выйдем из команды с помощью сочетания клавиш **Ctrl-C**



## Удалим один из подов деплоймента

Давайте удалим один из подов деплоймента, и посмотрим, что произойдет. 

Чтобы получить список всех под деплоймента, давайте воспользуемся параметром `-l` в команде **kubectl get**. Этот параметр позволяет фильтровать все объекты, имеющие соответствующие метки. Так мы отфильтруем все поды деплоймента:

`kubectl get pod -l app=hello-demo`{{execute T1}}

А теперь с помощью **jsonpath** выведем имя первого пода из списка:

`kubectl get pod -l app=hello-demo -o jsonpath="{.items[0].metadata.name}"`{{execute T1}}

Запомним его в переменную `POD_NAME`

`POD_NAME=$(kubectl get pod -l app=hello-demo -o jsonpath="{.items[0].metadata.name}")`{{execute T1}}

И удалим:

`kubectl delete pod $POD_NAME`{{execute T1}}

`watch kubectl get pods -l app=hello-demo`{{execute T1}}

Можем наблюдать за тем, как создаcтся еще одна новая пода.

```
NAME                               READY   STATUS        RESTARTS   AGE
hello-deployment-d67cff5cc-2vpkg   1/1     Running       0          6s
hello-deployment-d67cff5cc-8zbpd   1/1     Terminating   0          81s
hello-deployment-d67cff5cc-hrfh8   1/1     Running       0          4m12s
hello-deployment-d67cff5cc-hsf6g   1/1     Running       0          4m12s
```

Дождемся, пока под удалится, и потом выйдем из команды с помощью сочетания клавиш **Ctrl-C**

