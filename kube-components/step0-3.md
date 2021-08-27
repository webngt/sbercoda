Давайте с вами запустим инстанс сервиса в кластере. Для этого воспользуемся простейшим приложением на питоне, которое на / - отдает текст `Hello world from {имя хоста}!`. Образ контейнера хранится на dockerhub: **schetinikov/hello-app:v1**.

Для того, чтобы создать рабочую нагрузку, нужно сделать запрос к **API Server**-у.
Запрос будет выглядеть следующим образом.

`curl -v -X POST -H "Content-Type: application/json" http://127.0.0.1:8080/api/v1/namespaces/default/pods -d@hello-service.json`{{execute T1}}

Чуть позже мы разберем формат запроса, а сейчас давайте посмотрим, что происходит.

Запустим команду

`curl -s 127.0.0.1:8080/api/v1/events  | jq '.items[] | {message: .message, component: .source.component} | select(.message | index("hello"))'`{{execute T1}}

Команда опрашивает **API Server** по урлу `/api/v1/events` и выбирает только события, которые относятся к нашему контейнеру.

В событиях мы с вами можем увидеть события от **scheduler**-а и **kubelet**-a. Дождемся пока не **kubelet** не напишет, что контейнер `hello-demo` был запущен:

В результаты мы должны увидеть последовательность запуска:
```
{
  "message": "Successfully assigned default/hello-demo to node01",
  "component": "default-scheduler"
}
{
  "message": "Pulling image \"schetinnikov/hello-app:v1\"",
  "component": "kubelet"
}
{
  "message": "Successfully pulled image \"schetinnikov/hello-app:v1\"",
  "component": "kubelet"
}
{
  "message": "Created container hello-demo",
  "component": "kubelet"
}
{
  "message": "Started container hello-demo",
  "component": "kubelet"
}
```
