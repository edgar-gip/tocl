% Update the neighbours
function NW = som_update_neighbours(W, Sample, bmu, DistX, alpha, radius)
  %% At the beginning, it is the same
  NW = W;
  
  if (radius == 0.0)
    %% Just update bmu
    NW(bmu,:) = alpha * Sample + (1 - alpha) * W(bmu,:);
    NW(bmu,:) = NW(bmu,:) / sqrt(norm_sq(NW(bmu,:)));
      
  else
    %% Keep those that are at a distance lower than radius  
    Neigh = find(DistX(bmu,:) <= radius);
    
    %% Update the neighbours
    Theta = alpha * exp(-DistX(bmu, Neigh) / radius);
    
    for i = 1 : size(Neigh)
      n = Neigh(i);
      NW(n,:) = Theta(i) * Sample + (1 - Theta(i)) * W(n,:);
      NW(n,:) = NW(n,:) / sqrt(norm_sq(NW(n,:)));
    end
  end

% end function