###############################################################
#
# Скрипт восстановления базы данных из удалённого хранилища
#           
###############################################################

# Добавляем сборку для работы с архивами
Add-Type -AssemblyName "System.IO.Compression.FileSystem"

# Обзываем резерватор и архиватор удобными именами
Set-Alias -Name gbak -Value "C:\Program Files (x86)\Firebird\Firebird_2_5\bin\gbak.exe"

# Устанавливаем соединение с удалённым хранилищем
net use \\rdt.razrez.local\backup\Arch vRjJOMy2 /user:razrez\opback

# Получаем текущую дату
$CurrentDate = Get-Date
# Приводим к формату год-месяц-день
$CurrentDate = "{0:yyyy-MM-dd}" -f $CurrentDate

"Текущая дата: $CurrentDate"
Start-Sleep -s 4

# Чистим временные папки
"
Чистим временные папки"
Start-Sleep -s 4
Remove-Item $FDumpDir\*.*

# Запихиваем в переменные: пути, пароли, явки
$Archive = "\\rdt.razrez.local\backup\Arch\$CurrentDate\$CurrentDate.zip"  # Путь к архиву с backup'ом БД (удалённое хранилище)
$FDumpDir = "D:\Backup\Vrem"                    # Путь к временной папке
$FWaHo = "D:\Backup\Warehouse"                  # Хранилище
$FDataDir = "C:\Bastion\Data"                   # Путь к рабочей БД
$FLogin = "SYSDBA"                              # Логин пользователя БД
$FPassword = "cC6x5uP6"                         # Пароль от БД Огнептиц

# Копируем архив с backup'ом на локальный сервер
"
Копируем архив с backup'ом на локальный сервер"
Copy-Item $Archive -Destination $FDumpDir
$FDumpArc = "D:\Backup\Vrem\$CurrentDate.zip"
"
Разархивируем архив во временную папку"
[IO.Compression.ZipFile]::ExtractToDirectory($FDumpArc, $FDumpDir)

# Ресторим базу данных
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-BASTION.fbk $FDumpDir\BASTION.GDB
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-BPROT.fbk $FDumpDir\BPROT.GDB
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-PCN.fbk $FDumpDir\PCN.GDB

#Останавливаем службу FireBirdGuardian
"
Останавливаем службу FireBirdGuardian"
Stop-Service FirebirdGuardianDefaultInstance
Start-Sleep -s 4

# Переименовываем файлы действующей БД
"
Переименовываем файлы действующей БД"
Start-Sleep -s 4
Rename-Item "$FDataDir\BASTION.GDB" $CurrentDate-BASTION-OLD.GDB
Rename-Item "$FDataDir\BPROT.GDB" $CurrentDate-BPROT-OLD.GDB
Rename-Item "$FDataDir\PCN.GDB" $CurrentDate-PCN-OLD.GDB

# Перемещаем восстановленную БД в папку действующей БД
"
Перемещаем восстановленную БД в папку действующей БД"
Move-Item -Path $FDumpDir\BASTION.GDB -Destination $FDataDir\BASTION.GDB
Move-Item -Path $FDumpDir\BPROT.GDB -Destination $FDataDir\BPROT.GDB
Move-Item -Path $FDumpDir\PCN.GDB -Destination $FDataDir\PCN.GDB

# Запускаем службу FireBirdGuardian
"
Запускаем службу FireBirdGuardian"
Start-Service FirebirdGuardianDefaultInstance
Start-Sleep -s 4

# Перемещаем старую БД в хранилище
"
Перемещаем старую БД в хранилище"
Move-Item -Path $FDataDir\$CurrentDate-BASTION-OLD.GDB -Destination $FWaHo\$CurrentDate-BASTION-OLD.GDB
Move-Item -Path $FDataDir\$CurrentDate-BPROT-OLD.GDB -Destination $FWaHo\$CurrentDate-BPROT-OLD.GDB
Move-Item -Path $FDataDir\$CurrentDate-PCN-OLD.GDB -Destination $FWaHo\$CurrentDate-PCN-OLD.GDB

"
Закрываем соединение"
# Закрываем соединение
net use \\rdt.razrez.local\backup\Arch /d

"
Готово"