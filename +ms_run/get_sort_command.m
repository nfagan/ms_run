function cmd = get_sort_command(pipeline_path, raw_path, out_path, params_path)

cmd = sprintf( '\nmlp-run %s sort --raw=%s --firings_out=%s --_params=%s' ...
      , pipeline_path, raw_path, out_path, params_path);

end