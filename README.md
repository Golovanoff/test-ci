## Инструмент для автоматизированного тестирования CI.

# Идея:
Есть некий репозиторий, в котором заранее сделаны некоторые коммиты. Назовем его репо-донор.

В json-файле задаем имя/путь до этого репозитория, массив хешей/имен веток/тегов, которые необходимо обработать и массив директорий/файлов,  которые необходимо переносить.

При необходимости запускаем инициализацию донора, которая склонирует репо донора в указанную директорию.

После чего в репо-реципиенте запускаем скрипт, указывая путь к json-файлу с настройками.

Скрипт переключает в цикле репо-донор на очередной коммит из массива, переносит содержимое нужных директорий/файлов в текущую ветку текущего репо, делает коммит и пуш.

В настройках можно сделать указание сообщения коммита репо-реципиента для каждого коммита донора, а так же признак - пушить этот коммит или нет.
Возможно, нужно делать не только коммиты, но и другие команлы гит (например, создание ветки).
