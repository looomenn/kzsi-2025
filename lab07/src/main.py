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


def closest_saaty(ratio: float, scale: np.ndarray = SAATY_SCALE) -> float:
    ratio = float(ratio)
    if ratio >= 1.0:
        idx = int(np.abs(scale - ratio).argmin())
        return float(scale[idx])

    inv = 1.0 / ratio
    idx = int(np.abs(scale - inv).argmin())
    return 1.0 / float(scale[idx])


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


def eigenvector_weights(A: np.ndarray) -> tuple[np.ndarray, float]:
    vals, vecs = np.linalg.eig(A)
    idx = int(np.argmax(np.real(vals)))
    lam_max = float(np.real(vals[idx]))

    w = np.real(vecs[:, idx])
    w = np.abs(w)
    w = w / w.sum()
    return w, lam_max


def consistency(A: np.ndarray, lam_max: float) -> tuple[float, float]:
    n = A.shape[0]
    if n <= 2:
        return 0.0, 0.0

    ci = (lam_max - n) / (n - 1)
    ri = RI.get(n, RI[10])
    cr = 0.0 if ri == 0 else ci / ri
    return float(ci), float(cr)


def cr_status(cr: float) -> str:
    if cr < 0.1:
        return "consistent"
    if cr < 0.2:
        return "acceptable"
    return "inconsistent"


def simulate(n: int, seed: int | None = None) -> SimulationResult:
    rng = np.random.default_rng(seed)
    priorities = rng.dirichlet(np.ones(n))
    A = gen_matrix(priorities)

    w, lam_max = eigenvector_weights(A)
    ci, cr = consistency(A, lam_max)
    return SimulationResult(A, w, ci, cr)


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


if __name__ == "__main__":
    main()
