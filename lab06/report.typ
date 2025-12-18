#import "../templates/lib.typ": project, code_box
 
#let std_name = sys.inputs.at("name", default: "looomenn")
#let std_group = sys.inputs.at("group", default: "XX-00")
#let teacher = sys.inputs.at("teacher", default: "Mykola Parasuk")
#let header_color = rgb("#dbdbdb")

#show: project.with(
  work_type: "Комп'ютерний практикум",
  number: "6",
  discipline: "Комплексні системи захисту інформації",
  topic: "Вимірювання поверхні атаки",
  student_name: std_group+"\n"+std_name,
  teacher_name: teacher,
  year: 2025,
  extra_info: ("Варіант":"1")
)


#outline()
#pagebreak()

= Мета
Ознайомитись із поняттям поверхні атаки. Навчитись обчислювати числовий показник поверхні атак для різних систем.

= Хід роботи

== Види атак на Linux
+ Open TCP/UDP socket (Відкриті сокети).
+ Open RPC endpoint (RPC точки).
+ Service running as root (Сервіси під root).
+ Service running as non-root (Звичайні сервіси).
+ Setuid root program (Програми з SUID).
+ Enabled local user account (Локальні акаунти).
+ User id=root (Акаунти з ID 0).
+ Unpassworded account (Акаунти без пароля).
+ Nobody account (Акаунт nobody).
+ Weak file permission (Слабкі права файлів).
+ Script enabled (Увімкнені скрипти).
+ Symbolic link (Символічні посилання).
+ Httpd module (Модулі веб-сервера).
+ Dynamic web page (Динамічний контент).


== Розрахунок поверхні атаки для Linux ($P_k$)
Задамо ваги ($w_i$) — наскільки атака небезпечна/ймовірна (від 0 до 1), та частоту ($n_i$) — скільки таких вразливих місць знайдено в системі (наприклад, сканером).

Формула:
$
  P_k = sum (n_i times w_i)
$

#figure(
  table(
    columns: (0.1fr, 0.7fr, 0.5fr, 0.5fr, 0.5fr),
    stroke: 0.5pt,
    fill: (col, row) => {
      if row == 0 { header_color }
    },
    align: (col, row) => (
      if col == 1 { left } else { center }
    ),
    table.header(
      [№], [Клас атаки],[Вага ($w_i$)],[Частота (n)],[$w_i times n$],
    ),
    [1], [Open TCP/UDP socket], [0.8], [12], [9.6],
    [2], [Open RPC endpoint], [0.6], [5], [3.0],
    [3], [Service running as root], [1.0 (критично)], [3], [3.0],
    [4], [Service running as non-root], [0.5], [8], [4.0],
    [5], [Setuid root program], [0.9], [15], [13.5],
    [6], [Enabled local user account], [0.7], [4], [2.8],
    [7], [User id=root account], [1.0], [1], [1.0],
    [8], [Unpassworded account], [0.9], [0], [0.0],
    [9], [Nobody account], [0.4], [1], [0.4],
    [10], [Weak file permission], [0.6], [25], [15.0],
    [11], [Script enabled], [0.5], [10], [5.0],
    [12], [Symbolic link], [0.3], [20], [6.0],
    [13], [Httpd module], [0.4], [5], [2.0],
    [14], [Dynamic web page], [0.7], [10], [7.0],
    table.cell(colspan: 4, align: right)[Сума $P_k("Linux")$], [72.3]
  ),
  caption: "Розрахунок поверхні атак для Linux"
)

== Побудова ієрархії атак для іншої ОС (Windows)

Ієрархія атак для Windows (Resource -> Attack Class):

\
1. Network Services (Мережеві служби):
  - SMB Vulnerabilities: Атаки на протокол SMB (наприклад, EternalBlue).
  - RDP Exposure: Відкритий порт 3389, атаки BlueKeep.
  - NetBIOS/LLMNR: Атаки отруєння відповідей (Responder).

\
2. Privileges & Accounts (Привілеї):
  - Administrator Account: Атаки на вбудованого адміна.
  - UAC Bypass: Обхід контролю облікових записів.
  - Token Manipulation: Крадіжка токенів доступу.

\
3. File System & Registry (Файли та Реєстр):
  - DLL Hijacking: Підміна бібліотек у папках програм.
  - Registry Persistence: Автозавантаження через ключі реєстру (RunKeys).
  - Alternate Data Streams (ADS): Приховування коду у файлах NTFS.

\
4. Applications (Додатки):
  - PowerShell Execution: Запуск шкідливих скриптів (Fileless malware).
  - Office Macros: Вразливості VBA макросів.

#pagebreak()

== Розрахунок поверхні атаки для Windows ($P_k$)

#figure(
  table(
    columns: (0.1fr, 0.7fr, 0.3fr, 0.3fr, 0.3fr),
    stroke: 0.5pt,
    fill: (col, row) => {
      if row == 0 { header_color }
    },
    align: (col, row) => (
      if col == 1 { left } else { center }
    ),
    table.header(
      [№], [Клас атаки],[Вага ($w_i$)],[Частота (n)],[$w_i times n$],
    ),
    [1], [SMB Vulnerabilities], [0.9], [2], [1.8],
    [2], [RDP Exposure], [0.8], [1], [0.8],
    [3], [NetBIOS/LLMNR Enabled], [0.6], [1], [0.6],
    [4], [Administrator Account Active], [1.0], [1], [1.0],
    [5], [UAC Bypass possibilities], [0.7], [5], [3.5],
    [6], [Token Manipulation], [0.8], [2], [1.6],
    [7], [DLL Hijacking risk], [0.5], [20], [10.0],
    [8], [Registry Persistence Keys], [0.6], [15], [9.0],
    [9], [Alternate Data Streams], [0.4], [5], [2.0],
    [10], [PowerShell Execution Enabled], [0.8], [1], [0.8],
    [11], [Office Macros Enabled], [0.7], [3], [2.1],
    [12], [Unpatched Services], [0.9], [4], [3.6],
    table.cell(colspan: 4, align: right)[Сума $P_k("Linux")$], [36.8]
  ),
  caption: "Розрахунок поверхні атак для Windows"
)

== Порівняння
Отримали наступні значення:\
- $P_k("Linux") = 72.3$
- $P_k("Windows") = 36.8$

\
Висновки:\
У даному експерименті поверхня атаки Linux виявилася більшою. Це зумовлено тим, що в обраній конфігурації Linux було знайдено значну кількість програм із SUID бітом ($n=15$) та слабких прав доступу до файлів ($n=25$), що є специфічним для Unix-подібних систем. 

\
Windows показала менший результат завдяки суворішим налаштуванням за замовчуванням у сучасних версіях (вимкнений SMBv1, UAC), хоча ризики DLL Hijacking залишаються високими.

#pagebreak()
== Визначення поверхонь атак

=== Linux
$
  "Surface"_{"Linux/Windows"} = <("Methods"), ("Resources")>
$

#code_box(title: "plaintext")[
```
<
  (
    [
      "Open TCP/UDP socket", 
      "Open RPC endpoint", 
      "Service running as root",
      "Service running as non-root",
      "Setuid root program",
      "Enabled local user account",
      "User id=root account",
      "Unpassworded account",
      "Nobody account",
      "Weak file permission",
      "Script enabled",
      "Symbolic link",
      "Httpd module",
      "Dynamic web page"
      ]
  ),
  (
    [
      "Мережеві сокети (TCP/UDP)",
      "RPC точки (endpoint)",
      "Сервіси з правами root",
      "Звичайні сервіси (non-root)",
      "Виконувані файли (SUID)",
      "Локальні облікові записи",
      "Акаунт суперкористувача (Root)",
      "Акаунти без паролів", "Акаунт nobody",
      "Файлова система (права доступу)",
      "Скрипти та сценарії",
      "Символічні посилання",
      "Модулі веб-сервера",
      "Динамічний веб-контент"
    ]
  )
>

```
]

#pagebreak()
=== Windows
#code_box(title: "plaintext")[
```
<
  (
    [
      "SMB Vulnerabilities",
      "RDP Exposure"
       "Administrator Account Active",
       "UAC Bypass",
       "Token Manipulation",
       "DLL Hijacking",
       "Registry Persistence",
       "Alternat Data Streams (ADS)",
       "PowerShell Execution",
       "Office Macros Enabled",
       "Unpatched Services"
    ]
  ),
  (
    [
      "Порт 445 (SMB Share)",
      "Порт 3389 (TermService)",
      "Обліковий запис Administrator",
      "Механізм UAC",
      "Токени доступу (Access Tokens)",
      "Системні бібліотеки (.dll)",
      "Ключі реєстру (Autorun)",
      "Файлова система NTFS",
      "Інтерпретатор PowerShell",
      "Офісні документи (VBA)",
      "Системні служби Windows"
    ]
  )
>
```
]