function cmd = get_view_command( raw_fullfile, firings_fullfile, sample_rate )

cmd = sprintf( 'mountainview --raw=''%s'' --firings=''%s'' --samplerate=%d' ...
  , raw_fullfile, firings_fullfile, sample_rate );

end