## Запуск кластера Kubernetes
Сначала запустим кластер **Kubernetes**. Для этого нужно дождаться выполнения команды:

`./launch_k8s.sh`{{execute}}

Посмотрим, на скольких нодах у нас развернут кластер: 

`kubectl get node`{{execute}}

Кластер у нас небольшой, состоит из 2ух нод - одной управляющей ноды и одной рабочей. Управляющая нода имеет имя хоста - **controlplane**, а рабочая - **node01**.

Давайте посмотрим список **namespace**-ов:

`kubectl get namespace`{{execute}}

Видим несколько системных **namespace**-ов, в частности `kube-system`, в котором запущены основные управляющие компоненты кластера **Kubernetes**. Они запущены в виде **подов**. Список **под** в пространстве имен `kube-system`, можно посмотреть с помощью команды:

`kubectl get pods -n kube-system`{{execute}}

Помимо стандартных управляющих комопнент, можно увидеть сетевой плагин - **flannel**, компонент для работы с DNS - **coredns** и т.д.

## Создание пространства имен

Давайте с вами создадим свой **namespace**, в котором будем работать:

`kubectl create namespace myapp`{{execute}}

Чтобы каждый раз не вводить название **namespace**-а в командах **kubectl** изменим контекст:

`kubectl config set-context --current --namespace=myapp`{{execute}}

`clear`{{execute}}

## Создание пода

Давайте создадим **под**, для этого воспользуемся простейшим приложением на Python, у которого есть несколько эндпоинтов, на которые он отвечает:

- `/` отдает текст `Hello world from {имя хоста}!`
- `/version` отдает версию приложения

Для этого создадим файл **pod.yaml** с манифестом кубернетес. Это будет простейшее описание объекта типа **Pod**.

<pre class="file" data-filename="./pod.yaml" data-target="replace">
apiVersion: v1
kind: Pod
metadata:
  name: hello-demo
spec:
  containers:
  - name: hello-demo
    image: schetinnikov/hello-app:v1
    ports:
      - containerPort: 8000
</pre>

> Нужно быть очень аккуратным с yaml форматом, т.к. отступы являются значимыми, и один лишний пробел может "испортить" файл.

С помощью команды `watch` можем отслеживать статус **подов**, которые находятся в нашем **namespace**-е.

`watch kubectl get pods`{{execute T2}}

> Если терминал не был до этого открыт, то команду нужно будет нажать 2 раза - первый раз будет открыт терминал, а во второй выполнится уже команда

И теперь создадим **под**, для этого запустим в первом терминале:

`kubectl apply -f pod.yaml`{{execute T1}}

Во втором терминале отслеживаем статус **пода**. Дождемся, пока у **пода** не станет статус **Running**.

```
NAME         READY   STATUS    RESTARTS   AGE
hello-demo   1/1     Running   0          35s
```

## Логи

После этого можно посмотреть логи контейнера внутри **пода** 

`kubectl logs hello-demo`{{execute T1}}

И увидим логи старта приложения:
```
controlplane $ kubectl logs hello-demo
 * Serving Flask app "app" (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on http://0.0.0.0:8000/ (Press CTRL+C to quit)
```

## Исполнение команд в контексте контейнеров пода

Чтобы выполнить в контейнере **пода** команду в интерактивном режим, можно использовать команду `kubectl exec -it {имя пода} -- {команда}`

Запустим **bash** в поде`hello-demo`:

`kubectl exec -it hello-demo -- /bin/bash`{{execute T1}}

И например, посмотрим переменные окружения:

`env`{{execute T1}}

Чтобы выйти из интеративного режима, надо нажать сочетание клавиш **Ctrl-D**

## Доступ к поду по IP

Попробуем получить доступ к *поду* по **ip**. Для этого, найдем **ip** командой describe 

`kubectl describe pod hello-demo`{{execute T1}}

Также мы можем получить полностью развернутую информацию о *поде* в **json** формате:

`kubectl get -o json pod hello-demo | jq`{{execute}}

С помощью формата вывода **jsonpath** в **kubectl** можно доставать любую информацию о *поде*. Это крайне полезно и удобно для работы в скриптах.

Например, можем вывести только **IP** *пода* `hello-demo` такой командой:

`kubectl get -o jsonpath='{.status.podIP}' pod hello-demo`{{execute}}

Давайте сохраним **IP** пода в переменную `POD_ID`

`POD_IP=$(kubectl get -o jsonpath='{.status.podIP}' pod hello-demo)`{{execute T1}}

И теперь по этому **IP** мы можем обратиться к *поду* с управляющей ноды:

`clear`{{execute T1}}

`curl http://$POD_IP:8000/`{{execute T1}}

В результате выполнения **curl** должен вернуть строку `"Hello world from hello-demo!"`

```
controlplane $ curl http://$POD_IP:8000/
Hello world from hello-demo!
```

И

`curl http://$POD_IP:8000/version`{{execute}}

В результате выполнение **curl** должен вернуть строку `{"version": "1"}`

После этого можно посмотреть логи контейнера внутри пода

`kubectl logs hello-demo`{{execute T1}}

и увидим там логи запросов: 

```
172.17.0.21 - - [25/Jul/2021 17:54:38] "GET / HTTP/1.1" 200 -
172.17.0.21 - - [25/Jul/2021 17:55:05] "GET /version HTTP/1.1" 200 -
```

## Удаление пода

И теперь можем удалить *под*:

`kubectl delete pod hello-demo`{{execute T1}}

Удалятся *под* может достаточно долго, до минуты.

Можем отслеживать статус *пода* во втором терминале, пока объект совсем не будет удален.

## Запуск пода с помощью kubectl run

Помимо декларативных команд, **kubectl** поддерживает и так называемые *императивные команды*.

Например, можно было запустить такую же рабочую нагркузу с помощью команды: 

`kubectl run hello-demo --image=schetinnikov/hello-app:v1`{{execute T1}}

Конечно же, запускается при этом не голый контейнер. При выполнении этой команды создастся *под* с именем `hello-demo`, у которого в определении контейнеров будет только один с образом **schetinnikov/hello-app:v1**.

`kubectl get pod`{{execute T1}}

## Удаление пространства имен

Теперь давайте удалим пространство имен **myapp**. И оно приведет к удалению и всех объектов, которые в нем находятся.

`kubectl delete ns myapp`{{execute T1}}

За процессом удаления можно следить во втором терминале.
