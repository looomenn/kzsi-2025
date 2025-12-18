#import "../templates/lib.typ": project, code_box
 
#let std_name = sys.inputs.at("name", default: "looomenn")
#let std_group = sys.inputs.at("group", default: "XX-00")
#let teacher = sys.inputs.at("teacher", default: "Mykola Parasuk")

#show: project.with(
  work_type: "Комп'ютерний практикум",
  number: "4",
  discipline: "Комплексні системи захисту інформації",
  topic: "Оцінка рівня захищеності ІС",
  student_name: std_group+"\n"+std_name,
  teacher_name: teacher,
  year: 2025,
  extra_info: ("Варіант":"1")
)


#outline()
#pagebreak()

= Мета
Опанувати методи обробки результатів опитування з оцінювання рівня
захищеності ІС. Опанувати методику роботи із нечіткими даними.

= Хід роботи

== Формування запитань

1. $Q_5$: Чи використовується двофакторна автентифікація для доступу до адмін-панелі?
  - Шкала: $0 dots 5$ (де 0 — ніколи, 5 — завжди/обов'язково)

2. $Q_6$: Як часто оновлюються сигнатури антивірусного ПЗ?
  - Шкала: $0 dots 10$ (де 0 — не оновлюються, 10 — автоматично щогодини)

3. $Q_7$: Чи ведеться журнал фізичного доступу до серверної кімнати?
  - Шкала: $0 dots 3$ (де 0 — ні, 3 — так, з відеофіксацією)
  
4. $Q_8$: Чи проводяться інструктажі з кібергігієни для персоналу?
  - Шкала: $0 dots 4$ (де 0 — ні, 4 — щомісяця з тестуванням)

#let questions_config = (
  (text: "2FA (Адмін-панель)", min: 0, max: 5,  ans: 4),
  (text: "Оновлення Антивірусу", min: 0, max: 10, ans: 7),
  (text: "Журнал фіз. доступу", min: 0, max: 3,  ans: 1), 
  (text: "Кібергігієна",      min: 0, max: 4,  ans: 2),
)

#let expert_matrix = (
  (5.0, 3.0, 4.0, 4.0),
  (2.0, 5.0, 4.5, 4.0), 
  (1.0, 0.5, 5.0, 3.0), 
  (1.0, 1.0, 2.0, 5.0), 
)

#let row_sums = expert_matrix.map(r => r.sum())
#let total_sum = row_sums.sum()
#let PN = row_sums.map(s => s / total_sum)

#let U_stars = range(4).map(i => {
  let cfg = questions_config.at(i)
  let val = 4.0 * (cfg.ans - cfg.min) / (cfg.max - cfg.min)
  val
})


#let calc_mu(u, term_i, pn) = {
  let base = 1.0 + calc.pow(u - term_i, 2)
  calc.pow(1.0 / base, pn)
}

#let table2_data = range(4).map(row_idx => {
  let u = U_stars.at(row_idx)
  let pn = PN.at(row_idx)
  let mus = range(5).map(term_i => calc_mu(u, term_i, pn))
  (u, mus)
})

#let min_cols = range(5).map(col_idx => {
  let col_vals = table2_data.map(d => d.at(1).at(col_idx))
  calc.min(..col_vals)
})

#let final_max = calc.max(..min_cols)
#let final_term_idx = min_cols.position(x => x == final_max)
#let term_names = ("Низький (Н)", "Нижче Середнього (НС)", "Середній (С)", "Вище Середнього (ВС)", "Високий (В)")


== Відповіді співробітників


#let header_color = rgb("#dbdbdb")
#let sub_header_color = rgb("fff2cc") 

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1.2fr, 1.2fr, 2fr, auto, auto),
    stroke: 0.5pt,
    align: center + horizon,
    fill: (col, row) => {
      if row == 0 { header_color }
      else if col >= 5 and col <= 6 { sub_header_color }
      else { none }
    },
    
    table.header(
      [№], [1], [2], [3], [4], 
      [$P_j$], [$P\N_j$ ], 
      [$X_j^*$], [Min], [Max]
    ),

    ..range(4).map(i => {
      let q = questions_config.at(i)
      let sum_p = row_sums.at(i)
      let pn_val = PN.at(i)
      let row_vals = expert_matrix.at(i)
      (
        [#{i+1}], 
        [#row_vals.at(0)], [#row_vals.at(1)], [#row_vals.at(2)], [#row_vals.at(3)],
        [#sum_p], 
        [#calc.round(pn_val, digits: 4)], 
        [#q.ans], 
        [#q.min], 
        [#q.max]
      )
    }).flatten(),

    table.cell(colspan: 5, align: right)[*Сума:*],
    [#total_sum], [1.000], table.cell(colspan: 3, fill: none)[]
  )
  ,caption: [Коефіцієнти важливості запитань та відповіді співробітників]
)

== Оцінка рівня захищеності

#let result_color = rgb("#666666")
#let highlight_stroke = 2pt + red

#figure(
  table(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr),
    stroke: 0.5pt,
    align: center + horizon,
    fill: (col, row) => {
      if row == 0 { header_color }
      else if row == 5 { sub_header_color }
      else { none }
    },
    
    table.header(
      [№], [$U^*_j$], 
      [$mu_1^j$ \ (Н)], [$mu_2^j$ \ (НС)], [$mu_3^j$ \ (С)], [$mu_4^j$ \ (ВС)], [$mu_5^j$ \ (В)]
    ),

    ..range(4).map(i => {
      let data = table2_data.at(i)
      let u_val = data.at(0)
      let mus = data.at(1)
      (
        [#{i+1}], 
        [#calc.round(u_val, digits: 4)],
        [#calc.round(mus.at(0), digits: 4)],
        [#calc.round(mus.at(1), digits: 4)],
        [#calc.round(mus.at(2), digits: 4)],
        [#calc.round(mus.at(3), digits: 4)],
        [#calc.round(mus.at(4), digits: 4)]
      )
    }).flatten(),

    table.cell(colspan: 2, align: right)[*Min :*],
    ..min_cols.map(v => text(weight: "bold", fill: if v == final_max {red} else {black})[#calc.round(v, digits: 4)])
  )
  ,caption: [Функції приналежності та визначення рівня захищеності]
)


= Висновки

Згідно зі значенням максимуму, рівень захищеності відповідає терма з номером 4. 

\
З цього випливає, що оцінка рівня захищеності комп'ютерних класів: (ВС) "вище середнього".
