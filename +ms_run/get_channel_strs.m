function out = get_channel_strs( prefix, channels )

shared_utils.assertions.assert__isa( channels, 'double' );

assert( min(channels) > 0 && max(channels) < 100, 'Channels must be > 0 and < 100.' );

out = cell( size(channels) );

for i = 1:numel(channels)
  if ( channels(i) < 10 )
    out{i} = sprintf( '%s0%d', prefix, channels(i) );
  else
    out{i} = sprintf( '%s%d', prefix, channels(i) );
  end
end

end