#import "../templates/lib.typ": project, code_box
 
#let std_name = sys.inputs.at("name", default: "looomenn")
#let std_group = sys.inputs.at("group", default: "XX-00")
#let teacher = sys.inputs.at("teacher", default: "Mykola Parasuk")
#let header_color = rgb("#dbdbdb")

#show: project.with(
  work_type: "Комп'ютерний практикум",
  number: "5",
  discipline: "Комплексні системи захисту інформації",
  topic: "Оцінювання безпеки мережі за 
допомогою побудови графа атаки",
  student_name: std_group+"\n"+std_name,
  teacher_name: teacher,
  year: 2025,
  extra_info: ("Варіант":"1")
)


#outline()
#pagebreak()

= Мета
Ознайомитись із методом оцінки безпеки мережі на основі графів атак

= Хід роботи

== Вибір схеми

Використаємо схему з Комп'ютерний практику №2.

\
#figure(
  image("assets/diagram.svg"),
  caption: "Схема мережі"
)

#pagebreak()
== Побудова моделі атак

Правило побудови:

#code_box(title: "plaintext")[
```
Attack_rule =(
  {Src_privilege, Dst_privilege, Vuls, Protocols}, 
  {Rslt_privilege, Rslt_protocols, Rslt_vuls}
)
```
]

\
1. Network Reconnaissance
#code_box(title: "attackrule")[
```
Attack_rule =(
  {ACCESS, ACCESS, None, {ICMP, TCP}},
  {ACCESS, {Port_Scan_Result}, Service_Discovery}
)
```
]

\
2. Web SQL Injection
#code_box(title: "attackrule")[
```times
Attack_rule =(
  {ACCESS, USER, SQLi_Vuln, HTTP}, 
  {USER, {Shell_Access}, Web_Compromised}
)
```
]

\
3. FTP Brute Force
#code_box(title: "attackrule")[
```
Attack_rule = (
  {ACCESS, USER, Weak_Password, FTP},
  {USER, {File_Access}, FTP_Compromised}
)
```
]

\
4. Mail Server Exploit
#code_box(title: "attackrule")[
```
Attack_rule = (
  {ACCESS, ROOT, SMTP_Buffer_Overflow, SMTP},
  {ROOT, {all}, Mail_System_Owned}
)
```
]

\
5. VPN Gateway Compromise
#code_box(title: "attackrule")[
```
Attack_rule = (
  {ACCESS, ACCESS, VPN_Creds_Leak, HTTPS/IPSec}, 
  {USER, {Intranet_Network_Access}, VPN_Tunnel_Established}
)
```
]

\
6. Phishing / Client-Side Attack
#code_box(title: "attackrule")[
```
Attack_rule = (
  {ACCESS, USER, Browser/Office_Vuln, SMTP/HTTP}
   {USER, {Reverse_Shell}, Workstation_Compromised}
)
```
]

\
7. Internal Pivot to DB
#code_box(title: "attackrule")[
```
Attack_rule = (
  {USER, ACCESS, Weak_DB_Auth, SQL_Proto},
  {USER, {DB_Connection}, Data_Leak}
)
```
]

\
8. Privilege Escalation on DB
#code_box(title: "attackrule")[
```
Attack_rule = (
  {USER, ROOT, Kernel_Exploit, Local_OS},
  {ROOT, {all}, Full_System_Control}
)
```
]

#pagebreak()
== Побудова графу атак

Головна ціль: Сервер БД

\
#figure(
  image("assets/graph.svg", height: 85%),
  caption: "Граф атак"
)

#pagebreak()
== Задання факторів складності
Для кожного використаного правила атаки задамо фактор складності $D_i in [0, 1]$, де 1 — найлегша атака, 0 — неможлива.

#show table: set text(size: 10pt)

\
#figure(
  table(
    columns: (auto, 0.5fr, 0.2fr, 1fr),
    stroke: 0.5pt,
    align: left + horizon,
    fill: (col, row) => {
      if row == 0 { header_color }
    },

    table.header(
      [Правило], [Назва атаки], [$D_i$], [Обґрунтування]
    ),
    [Rule 1], [Network Reconnaissance], [$0.95$], [Сканування портів майже завжди можливе і просте],
    [Rule 2], [Web SQL Injection], [$0.60$], [Вимагає наявності вразливості в коді сайту],
    [Rule 5],	[VPN Compromise],	[$0.15$], [Висока складність, але можливо],
    [Rule 6],	[Phishing / Client-Side], [$0.80$], [Користувачі часто відкривають шкідливі листи],
    [Rule 7],	[Internal Pivot],	[$0.50$],	[Залежить від налаштувань внутрішнього фаєрволу],
    [Rule 8],	[DB Privilege Escalation], [$0.30$], [Вимагає"дірки" в ядрі ОС або старої версії БД]
  ),
  caption: [Фактори складності]
)


== Обчислення рівня захищеності системи

Рівень захищеності $S(M)$ обчислюється як добуток ймовірностей того, що кожен окремий шлях атаки не відбудеться.

=== Розрахунок складності кожного шляху ($D(P_i)$)
1. Шлях $P_1$ (Web):
  $
    D(P_1) &= D_("Rule1") times D_("Rule2") times D_("Rule7") times D_("Rule8") \
    D(P_1) &= 0.95 times 0.60 times 0.50 times 0.30 = 0.0855
  $
  Шанс успішної реалізації всього ланцюжка ~8.5%

\
2. Шлях $P_2$ (Phishing):
  $
    D(P_2) &= D_("Rule1") times D_("Rule6") times D_("Rule7") times D_("Rule8") \
    D(P_2) &= 0.95 times 0.80 times 0.50 times 0.30 = {0.114}
  $
  Шанс успішної реалізації ~11.4%. Це найнебезпечніший шлях, бо $D(P)$ найвищий

\
3. Шлях $P_3$ (VPN):
  $
    D(P_3) &= D_("Rule5") times D_("Rule8") \
    D(P_3) &= 0.15 times 0.30 = {0.045}
  $
  Примітка: Припускаємо, що після VPN ми відразу атакуємо БД (Rule 8), пропускаючи Pivot, бо ми вже в мережі.\
  Шанс ~4.5%. Найбезпечніший вектор для захисника

#pagebreak()
=== Розрахунок інтегрального рівня захищеності ($S(M)$)

Використовуємо формулу:

$
  S(M) &= product_(i=1)^(k)(1 - D(P_i)) \
  S(M) &= (1 - D(P_1)) times (1 - D(P_2)) times (1 - D(P_3))
$
\

Підставимо значення:
$
  S(M) &= (1 - 0.0855) times (1 - 0.114) times (1 - 0.045) \
  S(M) &= 0.9145 times 0.886 times 0.955
$
\

Проведемо множення:
1. $0.9145 times 0.886 approx 0.8102$
2. $0.8102 times 0.955 approx 0.7737$

$
  S(M) approx 0.774
$


= Висновки
Розрахований рівень захищеності системи складає 0.774 (або 77.4%).

\
Найбільш критичним вектором атаки виявився Шлях 2 (Фішинг) з фактором успіху $0.114$. Це пояснюється високою ймовірністю помилки людини (Rule 6 = 0.8).Шлях через VPN є найскладнішим для зловмисника ($0.045$).

\
Для підвищення $S(M)$ необхідно зосередитися на зменшенні фактора $D_"Rule6"$ (проведення тренінгів для персоналу щодо фішингу) та $D_"Rule2"$ (WAF, виправлення коду сайту). Якщо зменшити $D_"Rule6"$ з 0.8 до 0.4, загальна захищеність системи значно зросте.