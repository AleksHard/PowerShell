# Скрипт для получения статистики работы базы данных

# Обзываем резерватор и архиватор удобными именами
Set-Alias -Name gstat -Value "C:\Program Files (x86)\Firebird\Firebird_2_5\bin\gstat.exe"

# Запихиваем в переменные: пути, пароли, явки
$FDumpDir = "D:\Backup\TEMP"                    # Путь к временной папке
$FPassword = "cC6x5uP6"                         # Пароль от БД Огнептиц
$FDataDir = "C:\Bastion\Data\"                   # Путь к рабочей БД
$FLogin = "SYSDBA"                              # Логин пользователя БД

# Получаем текущую дату
$CurrentDate = Get-Date
# Приводим к формату год-месяц-день
$CurrentDate = "{0:yyyy-MM-dd}" -f $CurrentDate

# Чистим временные папки
Remove-Item $FDumpDir\*.*

# Получаем статистику БД
gstat -h $FDataDir\BASTION.GDB -user $FLogin -pas $FPassword
gstat -h $FDataDir\BPROT.GDB -user $FLogin -pas $FPassword
gstat -h $FDataDir\PCN.GDB -user $FLogin -pas $FPassword