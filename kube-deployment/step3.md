Теперь попробуем убрать метку с пода деплоймента, а потом его вернуть обратно:

Запомним в переменную `POD_NAME` имя первого пода в деплойменте: 

`POD_NAME=$(kubectl get pod -l app=hello-demo -o jsonpath="{.items[0].metadata.name}")`{{execute T1}}

С помощью команды **kubectl label** мы можем динамически добавлять, убирать и менять метки объектов. 

Удаляем метку **app** с первого пода:

`kubectl label pod $POD_NAME app-`{{execute T1}}

Проверяем, что метку действительно убрали: 

`kubectl get pods --show-labels`{{execute T1}}

```
controlplane $ kubectl get pods --show-labels
NAME                               READY   STATUS    RESTARTS   AGE     LABELS
hello-deployment-d67cff5cc-2vpkg   1/1     Running   0          2m10s   pod-template-hash=d67cff5cc
hello-deployment-d67cff5cc-hrfh8   1/1     Running   0          6m16s   app=hello-demo,pod-template-hash=d67cff5cc
hello-deployment-d67cff5cc-hsf6g   1/1     Running   0          6m16s   app=hello-demo,pod-template-hash=d67cff5cc
hello-deployment-d67cff5cc-qbghj   1/1     Running   0          30s     app=hello-demo,pod-template-hash=d67cff5cc
```

Во второй вкладке можем наблюдать за тем, как под без метки запущен, а деплоймент создал еще одну новую поду.

```
NAME                               READY   STATUS    RESTARTS   AGE
hello-deployment-d67cff5cc-2vpkg   1/1     Running   0          112s
hello-deployment-d67cff5cc-hrfh8   1/1     Running   0          5m58s
hello-deployment-d67cff5cc-hsf6g   1/1     Running   0          5m58s
hello-deployment-d67cff5cc-qbghj   1/1     Running   0          12s
```

А если мы вернем поду его метку:

`kubectl label pod $POD_NAME app=hello-demo`{{execute T1}}

Во второй вкладке можем наблюдать за тем, деплоймент удалил один из подов.
```
NAME                               READY   STATUS        RESTARTS   AGE
hello-deployment-d67cff5cc-2vpkg   1/1     Running       0          2m54s
hello-deployment-d67cff5cc-hrfh8   1/1     Running       0          7m
hello-deployment-d67cff5cc-hsf6g   1/1     Running       0          7m
hello-deployment-d67cff5cc-qbghj   1/1     Terminating   0          74s
```

