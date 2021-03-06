# Скрипт создания и архивирования резервных копий базы данных

# Обзываем резерватор и архиватор удобными именами
Set-Alias -Name gbak -Value "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe"
Set-Alias -Name zip7 -Value "C:\Program Files\7-Zip\7z.exe"

# Устанавливаем соединение с удалённым хранилищем
#net use \\rdt.razrez.local\backup\Arch vRjJOMy2 /user:razrez\opback

# Запихиваем в переменные: пути, пароли, явки
#$ArchiveDir = "\\rdt.razrez.local\backup\Arch"  # Путь к папке с архивами (удалённое хранилище)
$FDumpDir = "D:\Bastion\DB_for_reports\Temp"               # Путь к временной папке
$FPassword = "masterkey"                         # Пароль от БД Огнептиц
$FDataDir = "D:\Bastion\DB_for_reports\BD"                   # Путь к рабочей БД
$FLogin = "SYSDBA"                              # Логин пользователя БД
#$ExpiredDayInterval = 30                        # Время хранения бэкапов
$FRestDB = "C:\Bastion\DataRest"                # Путь к восстановленной базе данных

# Получаем текущую дату
$CurrentDate = Get-Date
# Приводим к формату год-месяц-день
$CurrentDate = "{0:yyyy-MM-dd}" -f $CurrentDate

# Чистим временные папки
Remove-Item $FDumpDir\*.*
Remove-Item -Recurse D:\Backup\Arch\*

# Бэкапим базу данных
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\BASTION.GDB $FDumpDir\$CurrentDate-BASTION.fbk -y $FDumpDir\$CurrentDate-BASTION.log
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\BPROT.GDB $FDumpDir\$CurrentDate-BPROT.fbk -Y $FDumpDir\$CurrentDate-BPROT.log
gbak -b -g -v -user $FLogin -pas $FPassword -se localhost:service_mgr $FDataDir\PCN.GDB $FDumpDir\$CurrentDate-PCN.fbk -Y $FDumpDir\$CurrentDate-PCN.log

# Упаковываем бэкапы в запароленный архив
zip7 a -tzip -ppas D:\Backup\Arch\$CurrentDate\$CurrentDate.zip $FDumpDir\*.*

# Переносим архив на удалённый сервер
Copy-Item D:\Backup\Arch\$CurrentDate -Recurse $ArchiveDir

# Удаляем старые архивы
gci $ArchiveDir | ForEach {
    $dirDate = [datetime]$_.Name
        if ($dirDate -lt (Get-Date).AddDays(-$ExpiredDayInterval)) {
            rd $_.FullName -Recurse
        }
}

# Закрываем соединение
net use \\rdt.razrez.local\backup\Arch /d