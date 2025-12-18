#import "../templates/lib.typ": project, code_box
 
#let std_name = sys.inputs.at("name", default: "looomenn")
#let std_group = sys.inputs.at("group", default: "XX-00")
#let teacher = sys.inputs.at("teacher", default: "Mykola Parasuk")
#let header_color = rgb("#dbdbdb")

#show: project.with(
  work_type: "Комп'ютерний практикум",
  number: "8",
  discipline: "Комплексні системи захисту інформації",
  topic: "Оцінювання ризиків в
інформаційній системі",
  student_name: std_group+"\n"+std_name,
  teacher_name: teacher,
  year: 2025,
  extra_info: ("Варіант":"1")
)


#outline()
#pagebreak()

= Мета
Ознайомитись із поняттям ризику та його роллю в керуванні інформаційною безпекою.

= Хід роботи

== Виявлення на оцінення ризиків для ІС

За основу візьмемо схему з Комп'ютерний практикум №2.
#figure(
  image("assets/diagram.svg"),
  caption: [Схема ІС]
)

#pagebreak()
=== Ідентифікація активів і загроз

#figure(
  table(
    columns: (1fr, 1.3fr, 2fr),
    fill: (col,row) => {
      if row == 0 {header_color} else {none}
    },
    align: left,
    stroke: 0.5pt,
    table.header(
      [Актив], [Загрози], [Опис Загрози]
    ),
[Сервер БД \ (Внутрішня мережа)], 
    [SQL Injection], 
    [Впровадження шкідливого коду через веб-сайт для викрадення даних клієнтів.],

    [Веб-сайт (DMZ)], 
    [Deface / XSS], 
    [Підміна головної сторінки або атака на користувачів сайту.],

    [FTP Сервер (DMZ)], 
    [Brute Force], 
    [Підбір паролів для несанкціонованого доступу до файлового сховища.],

    [Поштовий сервер \ (Зона інтернет-обміну)], 
    [Phishing / Spam Relay], 
    [Використання сервера для розсилки спаму або проникнення через фішинг.],

    [MME (VRRP кластер)], 
    [DDoS атака], 
    [Перевантаження зовнішніх маршрутизаторів для зупинки роботи мережі.],

    [Робочі місця], 
    [Malware / Ransomware], 
    [Зараження вірусами-шифрувальниками через дії користувачів.],

    [VPN шлюз], 
    [Man-in-the-Middle], 
    [Перехоплення даних при підключенні віддалених працівників.],

    [AMO \ (Міжмережевий екран)], 
    [Misconfiguration], 
    [Помилки конфігурації, що дозволяють доступ із DMZ у внутрішню мережу.]
  ),caption: [Таблиця активів і загроз]
)

== Навести показники, які характерезують виявлені ризики

=== Кількісна оцінка

Використовуємо формули:

\
1. Очікуваня одиночні витрати:
$
 \S\LE = \AV times \EF  
$

\
2. Щорічне очікування витрат:
$
 \A\LE = \S\LE times \A\RO
$

#let fmt(num) = {
  let s = str(int(num))
  let result = ""
  let len = s.len()
  let i = 0
  while i < len {
    if i > 0 and calc.rem(len - i, 3) == 0 {
      result += ","
    }
    result += s.at(i)
    i += 1
  }
  result
}

#let risk_data = (
  ("Сервер БД", "SQL Injection", 300000, 0.40, 0.5),
  ("Веб-сайт", "Deface / XSS",    80000, 0.20, 2.0),
  ("FTP Сервер", "Brute Force",   50000, 0.60, 0.5),
  ("Поштовий сервер", "Phishing",100000, 0.10, 4.0),
  ("MME (VRRP)", "DDoS атака",   150000, 0.50, 1.0),
  ("Робочі місця", "Ransomware", 200000, 0.30, 0.3),
  ("VPN шлюз", "MITM",            60000, 0.40, 0.5),
)


\
#figure(
  table(
    columns: (1.5fr, 1.2fr, 1fr, 0.6fr, 1fr, 0.6fr, 1fr),
    fill: (col,row) => {
      if row == 0 {header_color} else {none}
    },
    align: (col, row) => if col >= 2 and row > 0 { right } else { left },
    stroke: 0.5pt,
    table.header(
      [Актив], [Загрози], [AV, \$], [EF, %], [SLE, \$], [ARO], [ALE, \$]
    ),
    ..risk_data.map(row => {
      let (asset, threat, av, ef, aro) = row

      let sle = av * ef
      let ale = sle * aro
      
      (
        [#asset],
        [#threat],
        [#fmt(av)],
        [#(ef * 100)%],
        [#fmt(sle)],
        [#aro],
        [#fmt(ale)]
      )
    }).flatten()

  ),caption: [Розрахунок SLE та ALE]
)

\
=== Ризики в якісному аспекті
Використовуємо формули:

$
  R = P times V
$
\

(де $P$ — ймовірність, $V$ — величина втрат). Шкала оцінки:

\
- Дуже високий: $R > 0.4$
- Високий: $0.2 < R <= 0.4$
- Середній: $0.1 < R <= 0.2$
- Низький/Дуже низький: $R <= 0.1$


#let risk_data = (
  ("Сервер БД", "SQL Injection",  0.30, 0.90),
  ("Веб-сайт", "Deface / XSS",    0.70, 0.20),
  ("FTP Сервер", "Brute Force",   0.50, 0.30),
  ("Поштовий сервер", "Phishing", 0.80, 0.15),
  ("MME (VRRP)", "DDoS атака",    0.50, 0.60),
  ("Робочі місця", "Ransomware",  0.40, 0.50),
  ("VPN шлюз", "MITM",            0.20, 0.40),
)


#let get_risk_status(r) = {
  if r > 0.4 {
    [Дуже високий]
  } else if r > 0.2 {
    [Високий]
  } else if r > 0.1 {
    [Середній]
  } else {
    [Низький]
  }
}

\
#figure(
  table(
    columns: (1.5fr, 1.2fr, 0.6fr, 0.6fr, 0.6fr, 1fr),
    fill: (col,row) => {
      if row == 0 {header_color} else {none}
    },
    align: (col, row) => if col >= 2 and row > 0 { right } else { left },
    stroke: 0.5pt,
    table.header(
      [Актив], [Загрози], [$P$], [$V$], [$R$], [Якісна оцінка]
    ),
    ..risk_data.map(row => {
      let (asset, threat, p, v) = row

      let r = p * v

      (
        [#asset],
        [#threat],
        [#(calc.round(p, digits: 4))],
        [#(calc.round(v, digits: 4))],
        [#(calc.round(r, digits: 4))],
        [#get_risk_status(r)]
      )
    }).flatten()

  ),caption: [Якісна оцінка ризиків]
)

#pagebreak()
= Висновки
Кількісний аналіз показав, що найбільші фінансові ризики несе загроза DDoS атаки на вхідні маршрутизатори (MME), оскільки це зупиняє всі бізнес-процеси ($A\LE = 75,000$), а також компрометація Бази Даних ($A\LE = 60,000$).

\
Якісний аналіз підтвердив, що критичними елементами є База Даних та мережева інфраструктура (MME), які отримали оцінку ризику "Високий".

\
Для зменшення ризиків рекомендовано налаштувати WAF для веб-сайту та посилити правила фільтрації на AMO.