## Проверка ограничения 100Kб

Скрипт `finish.sh` генерирует невалидные данные в размере 200Кб

Сервис проверки должен прерывать выполнение, когда размер полученных от скрипта данных будет равно 100K

Пример ответа от сервиса проверки c использованием Insomnia `/assigmentService/PostValidate`

```json
{
	"Result": {
		"TaskID": "12123123",
		"Status": "FAILED",
		"Details": "PolicyClient.Check: rpc error: code = InvalidArgument desc = validate json failed: ffffffffffffffffffff,\ninput len: 102400",
		"CheckRes": {
			"Allow": [],
			"Deny": [],
			"Error": []
		}
	}
}
```