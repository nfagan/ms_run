function make_mda_file( pl2_file, channels, out_file )

import shared_utils.assertions.*;

assert__isa( pl2_file, 'char' );
assert__is_cellstr( channels );
assert__isa( out_file, 'char' );

for i = 1:numel(channels)
  ad = PL2Ad( pl2_file, channels{i} );
  
  if ( i == 1 )
    mat = zeros( numel(channels), numel(ad.Values), 'single' );
  end
  
  mat(i, :) = single( ad.Values );
end

if ( numel(channels) == 1 )
  mat = [ mat; zeros(1, size(mat, 2), 'like', mat) ];
end

writemda32( mat, out_file );

end