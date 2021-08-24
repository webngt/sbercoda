Начнем с входной точки для кластера, через которую происходит управление кластером и взаимодействие компонентов - **API Server**

Спроксируем **API Server** на локальный порт `8080` с помощью команды.

`./proxy_api_server_to_localhost_8080.sh &`{{execute T1}}

Теперь обращаясь по локальному порту `8080`, мы можем совершать запросы к **API Server**-у.

Например, мы можем получить конфигурацию и состояние кластера, относящуюся к **controlplane** ноде, сделав запрос:

`curl -s 127.0.0.1:8080/api/v1/nodes/controlplane/ | jq`{{execute T1}}

> jq - это утилита для форматирования, фильтрации и преобразования текстового вывода в формате JSON, мы еще не раз с ней встретимся

В ответ мы получим довольно большой json с информацией о ноде.

Вся эта информация хранится в хранилище **etcd**. Мы можем зайти **etcd** c помощью команды `docker exec` и посмотреть эту конфигурацию. **Etcd** является key-value хранилищем и, зная ключ, можно получить значение с помощью утилиты **etcdctl**. Информация о ноде **controlplane** хранится в ключе `/registry/minions/controlplane`. 

Сохраним id контейнера, в котором запущен **etcd**, в переменную окружения `ETCD_DOCKER_ID`:
`ETCD_DOCKER_ID=$(docker ps | grep -v pause | grep etcd | awk '{print$1}')`{{execute T1}}

И сделаем запрос напрямую в **etcd**:
`docker exec -it $ETCD_DOCKER_ID etcdctl get /registry/minions/controlplane  --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/peer.crt  --key /etc/kubernetes/pki/etcd/peer.key`{{execute T1}}

В ответе получим ту же самую информацию что и отдал **API Server**.

Также с помощью этой утилиты можем посмотреть, какие еще есть ключи. 

`docker exec -it $ETCD_DOCKER_ID etcdctl get / --prefix --keys-only --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/peer.crt  --key /etc/kubernetes/pki/etcd/peer.key`{{execute T1}}

Как видим ключей довольно много, каждый хранит какой-то отдельный аспект конфигурации кластера или его состояния.

Таким образом, через **API Server** пользователи кластера (утилиты или человек) и внутренние компоненты кластера получают и обновляют конфигурацию и статус кластера, который хранится в **etcd**, а также подписываются на изменения. 

`clear`{{execute T1}} `clear`{{execute T2}}
