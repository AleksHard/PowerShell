# Добавляем сборку для работы с архивами
Add-Type -AssemblyName "System.IO.Compression.FileSystem"

# Обзываем резерватор удобным именем
Set-Alias -Name gbak -Value "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe"

"
Запускаем скрипт BackUp-Restor"
# Получаем текущую дату
$CurrentDate = Get-Date
# Приводим к формату год-месяц-день
$CurrentDate = "{0:yyyy-MM-dd}" -f $CurrentDate
"Текущая дата: $CurrentDate"

# Чистим временные папки
"Чистим временные папки"                                                  #1
Start-Sleep -s 4
Remove-Item $FDumpDir\*.*

# Описываем переменные
MD D:\Bastion\DB_for_reports\Temp\$CurrentDate
$Archive = "D:\Bastion\DB_for_reports\Arch\$CurrentDate.zip"   # Путь к архиву с backup БД
$FDumpDir = "D:\Bastion\DB_for_reports\Temp"                   # Директория временных файлов
$FDataDir = "D:\Bastion\DB_for_reports\BD"                     # Путь к рабочей БД
$FWaHo = "D:\Bastion\DB_for_reports\Warehouse"                 # Хранилище
$FLogin = "SYSDBA"                                             # Логин пользователя БД
$FPassword = "masterkey"                                       # Пароль от БД Огнептиц

#"Распаковываем архив с backup'ом БД"
#[IO.Compression.ZipFile]::CreateFromDirectory($FDumpDir, $Archive)       #2
#[IO.Compression.ZipFile]::ExtractToDirectory($Archive, $FDumpDir)

# Бэкапим базу данных
"
Начинаем бэкапить базу данных"
Start-Sleep -s 4
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\BASTION.GDB $FDumpDir\$CurrentDate-BASTION.fbk
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\BPROT.GDB $FDumpDir\$CurrentDate-BPROT.fbk
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\PCN.GDB $FDumpDir\$CurrentDate-PCN.fbk
Start-Sleep -s 4

# Ресторим базу данных
"
Начинаем ресторить базу данных"
Start-Sleep -s 4
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-BASTION.fbk $FDataDir\$CurrentDate-BASTION.GDB
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-BPROT.fbk $FDataDir\$CurrentDate-BPROT.GDB
gbak -c -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDumpDir\$CurrentDate-PCN.fbk $FDataDir\$CurrentDate-PCN.GDB

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

Start-Sleep -s 4
# Переименовываем файлы восстановленной БД
"
Переименовываем файлы восстановленной БД"
Start-Sleep -s 4
Rename-Item "$FDataDir\$CurrentDate-BASTION.GDB" BASTION.GDB
Rename-Item "$FDataDir\$CurrentDate-BPROT.GDB" BPROT.GDB
Rename-Item "$FDataDir\$CurrentDate-PCN.GDB" PCN.GDB

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
Готово"