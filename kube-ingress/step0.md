Сначала запустим кластер **Kubernetes**. Для этого нужно дождаться выполнения команды:

`./launch_k8s.sh`{{execute}}

Давайте с вами создадим свой **namespace**, в котором будем работать:

`kubectl create namespace myapp`{{execute}}

Чтобы каждый раз не вводить название **namespace**-а в командах **kubectl** изменим контекст:

`kubectl config set-context --current --namespace=myapp`{{execute}}

Для того, чтобы наблюдать тем за статусом объектов **Kubernetes** во втором терминале запустим команду:

`watch kubectl get pods,deploy,svc,ingress`{{execute T2}}

> Если терминал не был до этого открыт, то команду нужно будет нажать 2 раза - первый раз будет открыт терминал, а во второй выполнится уже команда

