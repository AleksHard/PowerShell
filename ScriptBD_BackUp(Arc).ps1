###############################################################
#
# Скрипт создания BackUp'а из базы данных
#           
###############################################################

"
Запускаем скрипт создания BackUp'а из базы данных."
Start-Sleep -s 4

# Обзываем резерватор удобным именем
Set-Alias -Name gbak -Value "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe"

# Добавляем сборку для работы с архивами
Add-Type -AssemblyName "System.IO.Compression.FileSystem"

# Получаем текущую дату
$CurrentDate = Get-Date
# Приводим к формату год-месяц-день
$CurrentDate = "{0:yyyy-MM-dd}" -f $CurrentDate
"
Текущая дата: $CurrentDate."

# Запихиваем в переменные: пути, пароли, явки
$Archive = "D:\Bastion\DB_for_reports\Warehouse\$CurrentDate-Arc.zip"   # Путь к архиву с backup БД
$FDumpDir = "D:\Bastion\DB_for_reports\Temp"                            # Путь к временной папке
$FPassword = "masterkey"                                                # Пароль от БД Огнептиц
$FLogin = "SYSDBA"                                                      # Логин пользователя БД
$FDataDir = "D:\Bastion\DB_for_reports\BD"                              # Путь к базе данных

"
Чистим временные папки."
Remove-Item $FDumpDir\*.*
Start-Sleep -s 4

# Бэкапим базу данных
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\ARC.GDB $FDumpDir\$CurrentDate-Arc.fbk


# Упаковываем бэкапы в архив
"
Упаковываем бэкапы в архив"
Start-Sleep -s 4
[IO.Compression.ZipFile]::CreateFromDirectory($FDumpDir, $Archive)


"Готово!"