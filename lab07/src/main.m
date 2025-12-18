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