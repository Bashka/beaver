Простой сервис на Bash для организации "Непрерывной интеграции" (Continuous Integration).

## Конфигурация

Для конфигурации сервиса CI используется файл, описывающий команды для каждого этапа интеграции в виде функций Bash. По умолчанию используется файл `ci.config`, расположенного в корневом каталоге сервиса, но с помощью параметра `--config FILE` можно указать другой адрес файла конфигурации.

Сервис CI использует следующие переменные в своей работе:

* `log` - адрес файла-отчета

Конфигурация может включать следующие функции (в порядке их вызова):

* `ci_bootstrap` - подготовка окружения и проекта к сборке
* `ci_update` - получение изменений исходных кодов программы
* `ci_analyse` - статистический и другие анализы полученных изменений исходных кодов программы
* `ci_build` - сборка исходных кодов в исполняемые файлы
* `ci_unit_test` - запуск модульных тестов
* `ci_deploy` - развертывание программы (отчистка артефактов предыдущего запуска, подготовка базы данных и т.д.)
* `ci_test` - запуск системных тестов
* `ci_archive` - архивирование полученной программы
* `ci_report` - рассылка отчетов о результатах интеграции
* `ci_error` - данная функция вызывается только при возникновении ошибки на любом из предыдущих этапов и служит для уведомления об этом пользователей

### Пример конфигурации

```bash
# Переход в каталог проекта
cd my-project

# Подготовка проекта к сборке
function ci_bootstrap {
    mysql -u admin -p my_pass -e "DROP DATABASE db; CREATE DATABASE db"
}

# Загрузка изменений исходных кодов
function ci_update {
    if test -d .git; then
        return git pull
    else  
        return git clone https://github.com/vendor/project ./
    fi
}

# Сборка
function ci_build {
    return npm install && npm run build
}

# Запуск модульных тестов
function ci_unit_test {
    return npm run unit_test
}

# Развертывание проекта
function ci_deploy {
    return mysql -u admin -p my_pass db < migration/schema.sql &&\
        mysql -u admin -p my_pass db < migration/data.sql
}

# Уведомление о результатах интеграции
function ci_report {
    return mail -s "CI report" my@mail.com < $log
}

# Уведомление об ошибке
function ci_error {
    echo "== Error =="
    return mail -s "CI report" my@mail.com < $log
}
```

## Триггеры

Для запуска процесса интеграции изменений используется вызов Bash-скрипта `trigger`. Сделать это можно различными способами, описанными ниже.

### Прямой вызов

```bash
./trigger
```

### По расписанию

Настройте `crontab` в соответствии с требуемым расписанием, на пример для ежедневной сборки:

```bash
0 0 * * * /home/user/ci/trigger
```

### При фиксации изменений в системе контроля версий

Для этого необходимо запустить HTTP-сервер для прослушивания порта и запуска триггера интеграции, на пример так:

```bash
while true; do
  { echo -ne "HTTP/1.0 200 OK\r\n\r\n"; } | nc -v -l -p 8000 && /home/user/ci/trigger
done
```

После успешного запуска HTTP-сервера, необходимо настроить ваш репозиторий системы контроля версий на вызов этого HTTP-сервера при фиксации изменений исходных кодов. Если вы используете [Github][], это можно сделать настроив [Webhooks][].

## Отправка отчетов

### На почту

```bash
function ci_report {
  return mail -s "CI report" my@mail.com < $log
}
```

### По протоколу SSH

```bash
function ci_report {
  return scp $log user@ci-client.com:/home/user/ci-archive/ci.log
}
```

### По протоколу HTTP

```bash
function ci_report {
  return curl -X POST --form "report=@$log" --silent http://ci-monitor.com
}
```

[Github]: https://github.com
[Webhooks]: https://developer.github.com/webhooks/creating
