import random
from typing import Callable

THRESHOLDS = {
    0.3: 1,
    0.5: 2,
    0.7: 3,
    0.9: 4,
    1.0: 5,
}

class Evaluator:
    """
    Class for assessing the security system based on a three-dimensional matrix of parameters.
    """
    
    WEIGHTS_O: list[float] = [0.3, 0.2, 0.2, 0.3]
    WEIGHTS_H: list[float] = [0.2, 0.2, 0.2, 0.2, 0.2]
    WEIGHTS_E: list[float] = [0.15, 0.15, 0.1, 0.15, 0.15, 0.15, 0.15]

    LINGUISTIC_MARKS: dict[int, str] = {
        1: "повністю не відповідає (Н)",
        2: "не відповідає (НС)",
        3: "відповідає в основному (С)",
        4: "майже відповідає (ВС)",
        5: "повністю відповідає вимогам (В)",
    }

    def __init__(self):
        self.dim_o = len(self.WEIGHTS_O)
        self.dim_h = len(self.WEIGHTS_H)
        self.dim_e = len(self.WEIGHTS_E)

    def _get_mark_from_value(self, val: float) -> int:
        """Converts a numerical value into a score (1-5) according to thresholds."""
        for threshold, score in THRESHOLDS.items():
            if val <= threshold:
                return score
        return 5

    def generate_matrix_a(self) -> list[list[list[float]]]:
        """Generates matrix A with random values [0, 1)."""
        return [
            [[random.random() for _ in range(self.dim_o)] 
             for _ in range(self.dim_h)]
            for _ in range(self.dim_e)
        ]

    def generate_matrix_b(self, matrix_a: list[list[list[float]]]) -> list[list[list[int]]]:
        """Generates a binary matrix B based on A (threshold 0.5)."""
        return [
            [[1 if val > 0.5 else 0 for val in row] for row in plane]
            for plane in matrix_a
        ]

    def generate_matrix_c(self, matrix_a: list[list[list[float]]]) -> list[list[list[int]]]:
        """Generates a matrix of ratings C (1-5) based on A."""
        return [
            [[self._get_mark_from_value(val) for val in row] for row in plane]
            for plane in matrix_a
        ]

    def calculate_index(self, matrix: list[list[list[float]]], use_weights: bool = True) -> float:
        """Calculates the integral quality index."""
        total_score = 0.0
        
        for e, plane in enumerate(matrix):
            for h, row in enumerate(plane):
                for o, val in enumerate(row):
                    if use_weights:
                        weight = (
                            self.WEIGHTS_E[e] * self.WEIGHTS_H[h] * self.WEIGHTS_O[o]
                        )
                        total_score += val * weight
                    else:
                        total_score += val

        if not use_weights:
            count = self.dim_e * self.dim_h * self.dim_o
            return total_score / count
            
        return total_score

    def get_element_description(self, code: int, matrix: list[list[list[float]]]) -> str:
        """Returns the description of the item by code (for example, 121)."""
        # code 121 -> o=1, h=2, e=1
        s_code = str(code)
        if len(s_code) != 3:
            return f"Invalid code: {code}"
            
        o_idx = int(s_code[0]) - 1
        h_idx = int(s_code[1]) - 1
        e_idx = int(s_code[2]) - 1

        try:
            val = matrix[e_idx][h_idx][o_idx]
        except IndexError:
            return f"Code {code} is out of bounds"

        mark = self._get_mark_from_value(val)
        return f"{code} {self.LINGUISTIC_MARKS[mark]}"

    def find_worst_blocks(self, matrix_a: list[list[list[float]]], limit: int = 10) -> list[tuple[str, float]]:
        """Finds N blocks with the smallest weighted contribution."""
        elements = []
        for e in range(self.dim_e):
            for h in range(self.dim_h):
                for o in range(self.dim_o):
                    val = matrix_a[e][h][o]
                    weight = self.WEIGHTS_E[e] * self.WEIGHTS_H[h] * self.WEIGHTS_O[o]
                    code = f"{o + 1}{h + 1}{e + 1}"
                    elements.append((code, val * weight))

        elements.sort(key=lambda x: x[1])
        return elements[:limit]

    def _print_matrix(self, matrix: list[list[list]], name: str, printer: Callable[[str], None]):
        """Pretty print given matrix."""
        printer(f"\n{name}:")
        for e in range(self.dim_e):
            printer(f"E{e + 1}:")
            for h in range(self.dim_h):
                row_str = " ".join(
                    f"{val:.2f}" if isinstance(val, float) else f"{val}" 
                    for val in matrix[e][h]
                )
                printer(f"  H{h + 1}: {row_str}")

    def generate_report(self, filename: str):
        """Generates a complete report and saves it to a file."""
        matrix_a = self.generate_matrix_a()
        matrix_b = self.generate_matrix_b(matrix_a)
        matrix_c = self.generate_matrix_c(matrix_a)

        with open(filename, "w", encoding="utf-8") as f:
            def log(text: str = ""):
                print(text)
                f.write(text + "\n")

            self._print_matrix(matrix_a, "Матриця A (0..1)", log)
            self._print_matrix(matrix_b, "Матриця B (0 або 1)", log)
            self._print_matrix(matrix_c, "Матриця C (1..5)", log)

            log("\nІндекси якості")
            metrics = [
                ("A (з вагами)", matrix_a, True),
                ("A (без ваг)", matrix_a, False),
                ("B (з вагами)", matrix_b, True),
                ("B (без ваг)", matrix_b, False),
                ("C (з вагами)", matrix_c, True),
                ("C (без ваг)", matrix_c, False),
            ]
            
            for name, mat, weighted in metrics:
                log(f"{name}: {self.calculate_index(mat, weighted):.3f}")

            log("\nПеревірка елементів (варіант 1)")
            check_codes = [121, 433, 412, 117, 322]
            for code in check_codes:
                log(self.get_element_description(code, matrix_a))

            index_a = self.calculate_index(matrix_a, True)
            threshold = 0.75
            status = "прийнятна" if index_a >= threshold else "не прийнятна"
            comp = "≥" if index_a >= threshold else "<"
            log(f"\nСистема {status}: {index_a:.3f} {comp} {threshold}")

            log("\nНайгірші блоки (top 10)")
            for code, val in self.find_worst_blocks(matrix_a):
                log(f"{code} => внесок {val:.5f}")


if __name__ == "__main__":
    evaluator = Evaluator()
    evaluator.generate_report("lab01.txt")
