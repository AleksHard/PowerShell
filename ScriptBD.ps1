# Скрипт создания и архивирования резервных копий базы данных

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

# Запихиваем в переменные: пути, пароли, явки
$ArchiveDir = "\\rdt.razrez.local\backup\Arch"               # Путь к папке с архивами (удалённое хранилище)
$Archive = "D:\Backup\Arch\$CurrentDate\$CurrentDate.zip"    # Архив с созданными backup'ами
$FDumpDir = "D:\Backup\Vrem\Temp"                            # Путь к временной папке
$FPassword = "cC6x5uP6"                                      # Пароль от БД Огнептиц
$FDataDir = "C:\Bastion\Data"                                # Путь к рабочей БД
$FLogin = "SYSDBA"                                           # Логин пользователя БД
$ExpiredDayInterval = 30                                     # Время хранения бэкапов
$FRestDB = "C:\Bastion\DataRest"                             # Путь к восстановленной базе данных

"
Чистим временные папки"
# Чистим временные папки
Start-Sleep -s 4
Remove-Item $FDumpDir\*.*
Remove-Item -Recurse D:\Backup\Arch\*

# Создаём временную папку с текущей датой
MD D:\Backup\Arch\$CurrentDate

"
Бэкапим базу данных"
# Бэкапим базу данных
Start-Sleep -s 4
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\BASTION.GDB $FDumpDir\$CurrentDate-BASTION.fbk -y $FDumpDir\$CurrentDate-BASTION.log
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\BPROT.GDB $FDumpDir\$CurrentDate-BPROT.fbk -Y $FDumpDir\$CurrentDate-BPROT.log
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\PCN.GDB $FDumpDir\$CurrentDate-PCN.fbk -Y $FDumpDir\$CurrentDate-PCN.log

"
Упаковываем бэкапы в архив"
# Упаковываем бэкапы в архив
Start-Sleep -s 4
[IO.Compression.ZipFile]::CreateFromDirectory($FDumpDir, $Archive)

"
Переносим архив на удалённый сервер"
# Переносим архив на удалённый сервер
Start-Sleep -s 4
Move-Item -Path D:\Backup\Arch\$CurrentDate -Destination $ArchiveDir

"
Удаляем старые архивы"
# Удаляем старые архивы
gci $ArchiveDir | ForEach {
    $dirDate = [datetime]$_.Name
        if ($dirDate -lt (Get-Date).AddDays(-$ExpiredDayInterval)) {
            rd $_.FullName -Recurse
        }
}

"
Закрываем соединение"
# Закрываем соединение
net use \\rdt.razrez.local\backup\Arch /d

"
FINISH"