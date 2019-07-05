function [A_hat, E_hat] = LowRankByRPCA(D, lambda, tol, maxIter)
Y = D;
[h, w] = size(D);
norm_two = norm(Y, 2);
norm_inf = norm(Y, Inf) / lambda;
dual_norm = max(norm_two, norm_inf);
Y = Y / dual_norm;
A_hat = zeros(h, w);
E_hat = zeros(h, w);
dnorm = norm(D, 'fro');
mu = 1.25 / norm_two;
mu_bar = mu * 1e7;
rho = 1.5;
sv = 10;
n = w;
itr = 0;
while (1)
	temp_T = D - A_hat + (1 / mu) * Y;
	E_hat = max(temp_T - lambda / mu, 0) + min(temp_T + lambda / mu, 0);
	[U, S, V] = svd(D - E_hat + (1 / mu) * Y, 'econ');
	diagS = diag(S);
	svp = length(find(diagS > (1 / mu)));
	if svp < sv
		sv = min(svp + 1, n);
	else
		sv = min(svp + round(0.05 * n), n);
	end
	
	A_hat = U(:, 1:svp) * diag(diagS(1:svp) - 1 / mu) * V(:, 1:svp)';

	Z = D - A_hat - E_hat;
	Y = Y + mu * Z;
	mu = min(mu * rho, mu_bar);
	itr = itr + 1;
	stopCriterion = norm(Z, 'fro') / dnorm;
	if (stopCriterion < tol) || (itr >= maxIter)
		break;
	end
end
% fprintf('IALM Finished at iteration %d\n', itr);
end