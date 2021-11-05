## Проверка таймаута 10 сек

Скрипт `finish.sh` выполняется бесконечно долго

Сервис проверки должен прерывать выполнение примерно через 10 сек

Пример ответа от сервиса проверки c использованием Insomnia `/assigmentService/PostValidate`

```json
{
	"Result": {
		"TaskID": "12123123",
		"Status": "FAILED",
		"Details": "context deadline exceeded",
		"CheckRes": {
			"Allow": [],
			"Deny": [],
			"Error": []
		}
	}
}
```