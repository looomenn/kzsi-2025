#import "../templates/lib.typ": project, code_box
 
#let std_name = sys.inputs.at("name", default: "looomenn")
#let std_group = sys.inputs.at("group", default: "XX-00")
#let teacher = sys.inputs.at("teacher", default: "Mykola Parasuk")
#let header_color = rgb("#dbdbdb")

#show: project.with(
  work_type: "Комп'ютерний практикум",
  number: "7",
  discipline: "Комплексні системи захисту інформації",
  topic: "Задача формування
   експертної групи з найкращою компетентністю",
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

=== Вхідні дані

#let alpha_input = 0.3
#let beta_0 = 0.23

- Довірча імовірність: $p = 0.95$
- Апріорне значення варіації  $beta_0 = #beta_0$
- Відносна ширина довірчого інтервалу $alpha = #alpha_input$

== Визначення чисельності експертів

#let t_values = (
  (2, 12.71),
  (3, 4.30),
  (4, 3.18),
  (5, 2.78),
  (6, 2.57),
  (7, 2.45),
  (8, 2.37),
  (9, 2.31),
  (10, 2.26),
  (11, 2.23),
  (21, 2.09),
  (121, 1.98)
)


#let calculate_row(k, t) = {
  let ratio = calc.sqrt(k) / t
  let beta = ratio * alpha_input
  let k = k -1
  (k, t, ratio, beta)
}

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  inset: 10pt,
  stroke: 0.5pt,
  align: center,
  fill: (col, row) => if row == 0 { header_color } else { none },
  [$k-1$], [$t_(p, k-1)$], [$beta / alpha$], [$beta$],
  
  ..t_values.map(val => {
    let (k, t) = val
    let res = calculate_row(k, t)
    (
      [#res.at(0)], 
      [#res.at(1)], 
      [#calc.round(res.at(2), digits: 4)], 
      [ 
        #par(
          if calc.abs(res.at(3) - beta_0) < 0.02 {
             text(fill: rgb("#048217"), weight: "medium")[#calc.round(res.at(3), digits: 4)] 
          } 
          else { 
            text(fill: black)[#calc.round(res.at(3), digits: 4)] 
          }
        )
      ]
    )
  }).flatten()
)

#let optimal = t_values.map(val => {
    let (k, t) = val
    calculate_row(k, t)
}).find(
  r => calc.abs(r.at(3) - beta_0) == t_values.map(
    v => calc.abs(calculate_row(v.at(0), v.at(1)).at(3) - beta_0)
  ).sorted().first()
 )


Для заданого $beta = #beta_0$, найближче розрахункове значення становить *#calc.round(optimal.at(3), digits: 4)*, що відповідає $(k-1) = #optimal.at(0)$ $arrow$ $k = #{optimal.at(0) + 1}$

Оптимальна кількість експертної $= #{optimal.at(0) + 1}$

#pagebreak()
== Розрахунок коефіцієнтів компетентності 

Код файлом доступний в архів та на гітхабів - @pycode

\
Для запуску потрібно:
- `python >= 3.10`
- `numpy`:  `pip install numpy`


\
Приклад виконання:
#code_box(title:"plaintext")[
```text
For k=5:
consistency index: 0.0271
consistency ratio: 0.0242
status: consistent

matrix:
[[1.    0.5   1.    9.    2.   ]
 [2.    1.    2.    9.    4.   ]
 [1.    0.5   1.    9.    2.   ]
 [0.111 0.111 0.111 1.    0.143]
 [0.5   0.25  0.5   7.    1.   ]]

weights:
[0.2239 0.3997 0.2239 0.0273 0.1253]
```
]

\
=== Огляд коду

Код розділений на відповідні фрагменти:

\
1. Константи та структура результату
#code_box(title:"src/main.py", info:"python")[
```python
import numpy as np
from typing import NamedTuple

RI = {
    1: 0.0, 2: 0.0, 3: 0.58, 4: 0.90, 5: 1.12,
    6: 1.24, 7: 1.32, 8: 1.41, 9: 1.45, 10: 1.49,
}

SAATY_SCALE = np.arange(1, 10, dtype=float)


class SimulationResult(NamedTuple):
    matrix: np.ndarray
    weights: np.ndarray
    ci: float
    cr: float
```
]


\
2. Округлення відношення до найближчого значення з шкали Сааті
#code_box(title:"src/main.py", info:"python")[
```python
def closest_saaty(ratio: float, scale: np.ndarray = SAATY_SCALE) -> float:
    ratio = float(ratio)
    if ratio >= 1.0:
        idx = int(np.abs(scale - ratio).argmin())
        return float(scale[idx])

    inv = 1.0 / ratio
    idx = int(np.abs(scale - inv).argmin())
    return 1.0 / float(scale[idx])

```
]

\
3. Генерація матриці попарних порівнянь Сааті
#code_box(title:"src/main.py", info:"python")[
```python
def gen_matrix(priorities: np.ndarray) -> np.ndarray:
    n = priorities.size
    A = np.eye(n, dtype=float)

    for i in range(n):
        for j in range(i + 1, n):
            ratio = priorities[i] / priorities[j]
            v = closest_saaty(ratio)
            A[i, j] = v
            A[j, i] = 1.0 / v

    return A
```
]

#pagebreak()
4. Обчислення ваг через головний власний вектор
#code_box(title:"src/main.py", info:"python")[
```python
def eigenvector_weights(A: np.ndarray) -> tuple[np.ndarray, float]:
    vals, vecs = np.linalg.eig(A)
    idx = int(np.argmax(np.real(vals)))
    lam_max = float(np.real(vals[idx]))

    w = np.real(vecs[:, idx])
    w = np.abs(w)
    w = w / w.sum()
    return w, lam_max
```
]

\
5. Обчислення узгодженості CI та CR
#code_box(title:"src/main.py", info:"python")[
```python
def consistency(A: np.ndarray, lam_max: float) -> tuple[float, float]:
    n = A.shape[0]
    if n <= 2:
        return 0.0, 0.0

    ci = (lam_max - n) / (n - 1)
    ri = RI.get(n, RI[10])
    cr = 0.0 if ri == 0 else ci / ri
    return float(ci), float(cr)
```
]

\
6. Оцінка статусу зігдно з CR
#code_box(title:"src/main.py", info:"python")[
```python
def cr_status(cr: float) -> str:
    if cr < 0.1:
        return "consistent"
    if cr < 0.2:
        return "acceptable"
    return "inconsistent"
```
]

#pagebreak()
7. Функція симуляції, яка генерує пріоритети, матрицю, ваги та CI/CR
#code_box(title:"src/main.py", info:"python")[
```python
def simulate(n: int, seed: int | None = None) -> SimulationResult:
    rng = np.random.default_rng(seed)
    priorities = rng.dirichlet(np.ones(n))
    A = gen_matrix(priorities)

    w, lam_max = eigenvector_weights(A)
    ci, cr = consistency(A, lam_max)
    return SimulationResult(A, w, ci, cr)
```
]


\
8. Ну й звісно, точка входу
#code_box(title:"src/main.py", info:"python")[
```python
def main() -> None:
    k_experts = 5
    res = simulate(k_experts)

    print(f"For k={k_experts}:")
    print(f"consistency index: {res.ci:.4f}")
    print(f"consistency ratio: {res.cr:.4f}")
    print(f"status: {cr_status(res.cr)}\n")

    print("matrix:")
    print(np.array2string(res.matrix, precision=3, suppress_small=True))

    print("\nweights:")
    print(np.array2string(res.weights, precision=4, suppress_small=True))

```
]

#pagebreak()
== Задача цілочисельного лінійного програмування
Вимога задачі: максимізувати сумарну компетентність при обмеженому бюджеті.

\
Код файлом доступний в архів та на гітхабів - @matcode

\
Припустимо, маємо наступні вхідні дані (вартість послуг експертів $h$ та бюджет $H$):
- Вартість експертів ($h$): [100, 50, 60, 80, 120, 70] (умовні одиниці).
- Загальний бюджет ($H$): 250.

\
#code_box(title:"src/main.m", info:"matlab")[
```matlab
k = 5;
a = [0.2239 0.3997 0.2239 0.0273 0.1253];
h = [100, 50, 60, 80, 120];
H = 250;

f = -a;
intcon = 1:k;

A = h;
b = H;

lb = zeros(k, 1);
ub = ones(k, 1);

[x, fval] = intlinprog(f, intcon, A, b, [], [], lb, ub);

fprintf('Оптимальний склад групи експертів:\n');
total_cost = 0;
total_auth = 0;

for i = 1:k
    if x(i) > 0.5
        fprintf('Експерт #%d: Включено (Компетентність: %.4f, Вартість: %d)\n', ...
            i, a(i), h(i));
        total_cost = total_cost + h(i);
        total_auth = total_auth + a(i);
    end
end

fprintf('\nЗагальна вартість: %d (Бюджет: %d)\n', total_cost, H);
fprintf('Сумарна компетентність: %.4f\n', total_auth);
```
]

#pagebreak()
Результат:
#code_box(title:"plaintext")[
```matlab
Оптимальний склад групи експертів:
Експерт #1: Включено (Компетентність: 0.2239, Вартість: 100)
Експерт #2: Включено (Компетентність: 0.3997, Вартість: 50)
Експерт #3: Включено (Компетентність: 0.2239, Вартість: 60)

Загальна вартість: 210 (Бюджет: 250)
Сумарна компетентність: 0.8475
```
]

#pagebreak()
#bibliography("refs.yaml", style: "ieee")