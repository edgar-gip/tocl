%% Evaluate a clustering
function [ nmi Occ ] = meas_nmi (Clusters, Labels)
  %% Occurrency matrix
  Occ = meas_occ(Clusters, Labels);
  [ nC nL ] = size(Occ);

  %% Marginals
  marC = sum(Occ');
  marL = sum(Occ);
  tot  = sum(marC); % = sum(marL)

  %% Entropy
  vecC = marC .* log(marC / sum(marC));
  entC = sum(vecC(!isnan(vecC)));
  vecL = marL .* log(marL / sum(marL));
  entL = sum(vecL(!isnan(vecL)));

  %% Mutual information
  Exp = marC' * marL;
  Mat = Occ .* log(tot * Occ ./ Exp);
  mi  = sum(Mat(find(!isnan(Mat))));

  %% Return normalized
  nmi = mi / sqrt(entC * entL);

% end function
