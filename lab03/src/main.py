import random


RANDOM_SEED = 42
N_THREATS = 10
N_REQS = 12


def normalize(vec: list[float]) -> list[float]:
    s = sum(vec)
    if s == 0:
        return [0.0 for _ in vec]
    return [x / s for x in vec]


def calc_x(cur: float, worst: float, best: float) -> float:
    if best == worst:
        return 1.0
    
    if best > worst:
        val = (cur - worst) / (best - worst)
    else:
        val = (worst - cur) / (worst - best)
        
    return max(0.0, min(1.0, val))


def calculate_W(
    alpha_vec: list[float], 
    dq_vec: list[float], 
    beta_mat: list[list[float]], 
    x_vec: list[float]
) -> tuple[float, list[float]]:
    W_total = 0.0
    details = []
    
    for i in range(len(alpha_vec)):
        p_us = sum(beta_mat[i][j] * x_vec[j] for j in range(len(x_vec)))

        w_i = alpha_vec[i] * dq_vec[i] * p_us
        W_total += w_i
        details.append(p_us)
        
    return W_total, details


def main() -> None:
    random.seed(RANDOM_SEED)

    reqs_data: list[tuple[str, float, float, float]] = [
        ("Backup Storage", 0, 2, 1),
        ("Duplication/Day", 0.5, 5, 3),
        ("Antivirus Vendors", 1, 3, 2),
        ("Uptime SLA %", 95.0, 99.9, 99.0),
        ("Replicas Count", 1, 4, 2),
        ("Password Length", 6, 16, 10),
        ("No Protection Mode", 0.0, 1.0, 0.5),
        ("Anti-Rootkit", 0.0, 1.0, 1.0),
        ("Log Alerting", 0.0, 1.0, 0.7),
        ("DDoS Protection", 0.0, 1.0, 0.8),
        ("Encryption Level", 0.0, 1.0, 0.7),
        ("MFA Implementation", 0.0, 1.0, 0.8)
    ]


    raw_alpha = [random.randint(1, 100) for _ in range(N_THREATS)]
    alpha = normalize(raw_alpha)


    raw_dq = [random.random() for _ in range(N_THREATS)]
    delta_q = normalize(raw_dq)

    beta = [normalize([random.random() for _ in range(N_REQS)]) for _ in range(N_THREATS)]

    x_current: list[float] = []
    x_best: list[float] = []

    for _, worst, best, cur in reqs_data:
        x_current.append(calc_x(cur, worst, best))
        x_best.append(1.0)


    W_curr, P_us_curr = calculate_W(alpha, delta_q, beta, x_current)
    W_best, P_us_best = calculate_W(alpha, delta_q, beta, x_best)


    print("Results:\n")
    print(f"{'№':<3} | {'Alpha (Prob)':<20} | {'Delta Q (Losses)':<20} | {'P_us (Protection)':<20}")
    print("-" * 75)

    for i in range(N_THREATS):
        print(f"{i+1:<3} | {alpha[i]:<20.5f} | {delta_q[i]:<20.5f} | {P_us_curr[i]:<20.5f}")

    print("\nX_j:")
    print(f"{'Req Name':<20} | {'Worst':<6} | {'Best':<6} | {'Cur':<6} | {'X_val (Norm)':<10}")
    print("-" * 60)
    
    for i, (name, w, b, c) in enumerate(reqs_data):
        print(f"{name:<20} | {w:<6} | {b:<6} | {c:<6} | {x_current[i]:<10.4f}")

    print("-" * 60)
    print(f"W (Поточний показник):   {W_curr:.6f}")
    print(f"W (Потенційний/Best):    {W_best:.6f}")


    cost_n_unit = 500
    cost_m_unit = 300
    budget_limit = 1700

    cost_cur = (2 * cost_n_unit) + (1 * cost_m_unit)
    cost_best = (3 * cost_n_unit) + (2 * cost_m_unit)

    print(f"\nBudget (Limit Z={budget_limit})")
    
    status_cur = "OK" if cost_cur <= budget_limit else "Over"
    print(f"Поточна вартість:  {cost_cur} -> {status_cur}")
    
    status_best = "OK" if cost_best <= budget_limit else "Over"
    print(f"Найкраща вартість: {cost_best} -> {status_best}")

if __name__ == "__main__":
    main()
