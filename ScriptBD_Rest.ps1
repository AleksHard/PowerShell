###############################################################
#
# Скрипт восстановления из базы данных
#           
###############################################################

"
Запускаем скрипт восстановления БД."
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
$Archive = "D:\Bastion\DB_for_reports\Warehouse\$CurrentDate-b.zip"   # Путь к архиву с backup БД
$FDumpDir = "D:\Bastion\DB_for_reports\Temp"                        # Путь к временной папке
$FPassword = "masterkey"                                            # Пароль от БД Огнептиц
$FLogin = "SYSDBA"                                                  # Логин пользователя БД
$FRestDB = "D:\Bastion\DB_for_reports\Arch"                         # Путь к восстановленной базе данных

"
Чистим временные папки."
Remove-Item $FDumpDir\*.*
Start-Sleep -s 4
"
Распаковываем архив с backup'ом БД."
[IO.Compression.ZipFile]::ExtractToDirectory($Archive, $FDumpDir)
"
Архив успешно распакован."

# Ресторим базу данных
"
Ресторим базу данных"
Start-Sleep -s 4
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-BASTION.fbk $FRestDB\$CurrentDate-BASTION.GDB
"
Файл BASTION.GDB успешно создан"
Start-Sleep -s 4
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-BPROT.fbk $FRestDB\$CurrentDate-BPROT.GDB
"
Файл BPROT.GDB успешно создан"
Start-Sleep -s 4
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-PCN.fbk $FRestDB\$CurrentDate-PCN.GDB
"
Файл PCN.GDB успешно создан"
Start-Sleep -s 4

"
Готово"