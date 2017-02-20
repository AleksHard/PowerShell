# Скрипт создания резервной копии базы данных

# Обзываем резерватор и архиватор удобными именами
Set-Alias -Name gbak -Value "C:\Program Files (x86)\Firebird\Firebird_2_5\bin\gbak.exe"

# Добавляем сборку для работы с архивами
Add-Type -AssemblyName "System.IO.Compression.FileSystem"

# Получаем текущую дату
$CurrentDate = Get-Date
# Приводим к формату год-месяц-день
$CurrentDate = "{0:yyyy-MM-dd}" -f $CurrentDate
"Текущая дата: $CurrentDate"
Start-Sleep -s 4

# Запихиваем в переменные: пути, пароли, явки
$Archive = "D:\Backup\Arch\$CurrentDate.zip"                 # Архив с созданными backup'ами
$FDumpDir = "D:\Backup\Arch"                                 # Путь к временной папке
$FPassword = "cC6x5uP6"                                      # Пароль от БД Огнептиц
$FDataDir = "C:\Bastion\Data"                                # Путь к рабочей БД
$FLogin = "SYSDBA"                                           # Логин пользователя БД

"
Чистим временные папки"
# Чистим временные папки
Start-Sleep -s 4
Remove-Item $FDumpDir\*.*

"
Бэкапим базу данных"
# Бэкапим базу данных
Start-Sleep -s 4
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\BASTION.GDB $FDumpDir\$CurrentDate-BASTION.fbk
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\BPROT.GDB $FDumpDir\$CurrentDate-BPROT.fbk
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\PCN.GDB $FDumpDir\$CurrentDate-PCN.fbk

"
Упаковываем бэкапы в архив"
# Упаковываем бэкапы в архив
Start-Sleep -s 4
[IO.Compression.ZipFile]::CreateFromDirectory($FDumpDir, $Archive)

"
FINISH"