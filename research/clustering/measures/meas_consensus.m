%% Get different consensus functions
function c = meas_consensus (cfunc, Clust1, Clust2)
  %% Check the arguments
  [ nelems  dummy1 ] = size(Clust1);
  [ nelems2 dummy2 ] = size(Clust2);

  if dummy1 ~= 1 || dummy2 ~= 1
    error('Clusterings should be column vectors');
  end

  if nelems ~= nelems2
    error('Clusterings should be of the same size');
  end

  %% Switch
  if strcmp(cfunc, 'part_diff')
    %% Partition difference
    M1 = comb_sharing_matrix(Clust1);
    M2 = comb_sharing_matrix(Clust2);
    c  = sum(sum((M1 - M2) .^ 2));

  elseif strcmp(cfunc, 'katz_powell')
    %% Katz & Powell Index
    M1  = comb_sharing_matrix(Clust1);
    M2  = comb_sharing_matrix(Clust2);

    n1  = sum(sum(M1));
    n2  = sum(sum(M2));
    n12 = sum(sum(M1 .* M2));

    c   = (nelems ^ 2 * n12 - n1 * n2) / ...
        sqrt(n1 * (nelems ^ 2 - n1) * n2 * (nelems ^ 2 - n2));

  elseif strcmp(cfunc, 'cohen_kappa')
    %% Cohen's kappa
    M1  = comb_sharing_matrix(Clust1);
    M2  = comb_sharing_matrix(Clust2);

    n1  = sum(sum(M1))
    n2  = sum(sum(M2))
    n12 = sum(sum(M1 .* M2))

    if nelems ^ 2 == n1 * n2
      c = 1;
    else
      c = (n12 - n1 * n2) / (nelems ^ 2 - n1 * n2);
    end

  elseif strcmp(cfunc, 'chisq')
    %% Chi square

    %% Occurrence matrix
    Occ   = meas_occ (Clust1, Clust2);

    %% Marginals
    Marg1 = sum(Occ, 2);
    Marg2 = sum(Occ);

    %% Expected matrix
    Exp   = Marg2 * Marg1 / nelems;

    %% Chi Sq
    c     = sum(sum(((Occ - Exp) .^ 2) ./ Exp));

  elseif strcmp(cfunc, 'cat_util')
    %% Category utility of Clust1 wrt Clust2

    %% Occurrence matrix
    Occ   = meas_occ(Clust1, Clust2);

    %% Marginals
    Marg1 = sum(Occ, 2);
    Marg2 = sum(Occ);

    %% Size
    [ siz1 siz2 ] = size(Occ);

    %% Conditioned matrix
    Cond  = Occ ./ (Marg1 * ones(1, siz2));

    %% Category utility
    c     = sum(Marg1 .* sum(Cond .^ 2, 2)) - ...
        sum(Marg2 .^ 2);

  elseif strcmp(cfunc, 'nmi')
    %% Normalized mutual information

    %% Occurrence matrix
    Occ   = meas_occ(Clust1, Clust2) / nelems;

    %% Marginals
    Marg1 = sum(Occ, 2);
    Marg2 = sum(Occ);

    %% Expected matrix
    Exp   = Marg2 * Marg1;

    %% Mutual information
    MI    = sum(sum(Occ .* log(Occ ./ Exp)));

    %% Entropies
    H1    = - sum(Marg1 .* log(Marg1));
    H2    = - sum(Marg2 .* log(Marg2));

    %% Normalized mutual information
    c     = MI / sqrt(H1, H2);

  else
    error('Function not supported');
  end

% end function
