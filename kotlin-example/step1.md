## Запуск тестовой сборки

Перейдите в каталог `Sprint-2`

`cd Sprint-2`{{execute}}

Запустите тестовую сборку

`mvn test`{{execute}}

После запуска тестовой сборки вы должы увидеть в терминале ошибки тестовой сборки, как в примере данного фрагмента

```
...
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0 s - in ProblemATest
[INFO]
[INFO] Results:
[INFO]
[ERROR] Failures:
[ERROR]   ProblemBTest.testSolution:8->BaseTest.checkOutput:23 Not equals. Expected <cbcacab
abcd
baabab>, actual <abcabca
abcd
ababab>.
[INFO]
[ERROR] Tests run: 5, Failures: 1, Errors: 0, Skipped: 0
[INFO]
...
```

Исправьте ошибки используя проводник и редактор. 