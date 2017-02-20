###############################################################
#
# Скрипт восстановления базы данных
#           
###############################################################

# Добавляем сборку для работы с архивами
Add-Type -AssemblyName "System.IO.Compression.FileSystem"

# Обзываем резерватор и архиватор удобными именами
Set-Alias -Name gbak -Value "C:\Program Files (x86)\Firebird\Firebird_2_5\bin\gbak.exe"

# Получаем текущую дату
$CurrentDate = Get-Date
# Приводим к формату год-месяц-день
$CurrentDate = "{0:yyyy-MM-dd}" -f $CurrentDate

"Текущая дата: $CurrentDate"
Start-Sleep -s 4

# Запихиваем в переменные: пути, пароли, явки
$Archive = "D:\Backup\Arch\$CurrentDate.zip"    # Архив c backup'ами
$FDumpDir = "D:\Backup\Arch"                    # Путь к временной папке
$FWaHo = "D:\Backup\Warehouse"                  # Хранилище
$FDataDir = "C:\Bastion\Data"                   # Путь к рабочей БД
$FLogin = "SYSDBA"                              # Логин пользователя БД
$FPassword = "cC6x5uP6"                         # Пароль от БД Огнептиц

"
Распаковываем архив во временную папку"
[IO.Compression.ZipFile]::ExtractToDirectory($Archive, $FDumpDir)

# Ресторим базу данных
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-BASTION.fbk $FDumpDir\$CurrentDate-BASTION.GDB
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-BPROT.fbk $FDumpDir\$CurrentDate-BPROT.GDB
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-PCN.fbk $FDumpDir\$CurrentDate-PCN.GDB

"
Готово!"