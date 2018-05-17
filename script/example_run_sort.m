addpath( '~/Repositories/matlab/ms_run' );

conf = ms_run.config.load();

ms_run.util.add_depends();


%%  generate raw data + sort script

pl2_dir = '/media/chang/backup1/EletrophysData_setu3_olga/movedheretherest/preorpost';
pl2_files = shared_utils.io.dirnames( pl2_dir, '.pl2', false );

data_root = conf.PATHS.data_root;

pipeline_fullfile = fullfile( conf.PATHS.pipelines, 'mountainsort3.mlp' );
params_fullfile = fullfile( data_root, 'params', 'params.json' );
raw_p = fullfile( data_root, 'raw' );
tmp_p = fullfile( data_root, 'tmp' );
firings_p = fullfile( data_root, 'firings' );

shared_utils.io.require_dir( raw_p );
shared_utils.io.require_dir( tmp_p );
shared_utils.io.require_dir( firings_p );

channel_map_file = shared_utils.io.fload( fullfile(data_root, 'dictator_pl2_map.mat') );
channel_map_keys = channel_map_file.keys();

tmp_sh_fullfile = fullfile( tmp_p, 'tmp_run.sh' );
 
fid = fopen( tmp_sh_fullfile, 'wt' );

assert( fid >= 0, 'Failed to open "%s".', tmp_sh_fullfile );

adjusted_pl2_files = cell( size(pl2_files) );
failed_to_process = false( size(pl2_files) );
more_than_one = false( size(pl2_files) );

current_mda_files = shared_utils.io.dirnames( raw_p, '.mda', false );

allow_regions = { 'bla', 'acc' };

for i = 1:numel(pl2_files)
  
  pl2_file = pl2_files{i};
  pl2_fullfile = fullfile( pl2_dir, pl2_file );
  
  fprintf( '\n Storing "%s"', pl2_file );
  
  already_processed = cellfun( @(x) contains(lower(x), strrep(lower(pl2_file), '.pl2', '')), current_mda_files );
  
%   if ( sum(already_processed) > 1 )
%     fprintf( '\n Skipping "%s" because it was already processed.', pl2_file );
%     continue;
%   end
  
  ind = cellfun( @(x) ~isempty(strfind(lower(x), lower(strrep(pl2_file, '.pl2', '')))), channel_map_keys );
  
  if ( sum(ind) == 0 )
    fprintf( '\n No files matched "%s"', pl2_file );
    continue;
  end
  
  if ( sum(ind) ~= 1 )
    subset_ind = cellfun( @(x) strcmpi(strrep(x, '..pl2', '.pl2'), pl2_file), channel_map_keys );
    if ( sum(subset_ind) ~= 1 )
      fprintf( '\n No files matched "%s"', pl2_file );
      continue;
    end
    ind = subset_ind;
  end
  
  try
    assert( sum(ind) == 1, 'Expected 1 pl2 file to match "%s"; got %d.', pl2_file, sum(ind) );
    pl2_file = channel_map_keys{ind};
    channel_struct = channel_map_file(pl2_file);
    adjusted_pl2_files{i} = pl2_file;
  catch err
    fprintf( '\n Warning: %s', err.message );
    failed_to_process(i) = true;
    continue;
  end
  
  for j = 1:numel(channel_struct)
    c_channel_struct = channel_struct(j);
    
    region = c_channel_struct.region;
    channels = c_channel_struct.channels;
    
    if ( ~any(strcmp(allow_regions, region)) )
      fprintf( '\n Skipping "%s".', region );
      continue;
    end
    
    channel_strs = ms_run.get_channel_strs( 'WB', channels );
    
    mda_file = sprintf( '%s_%s', region, strrep(pl2_file, '..pl2', '.mda') );
    mda_fullfile = fullfile( raw_p, mda_file );
    out_fullfile = fullfile( firings_p, mda_file );
    
    if ( shared_utils.io.fexists(fullfile(raw_p, mda_file)) )
      continue;
    end
  
    try
      ms_run.make_mda_file( pl2_fullfile, channel_strs, mda_fullfile );
    catch err
      fprintf( '\n Failed to save raw .pl2 file: "%s", with message: "\n%s"' ...
        , pl2_file, err.message );
      continue;
    end

    sort_cmd = ms_run.get_sort_command( pipeline_fullfile, mda_fullfile, out_fullfile, params_fullfile );
    
    sort_cmd = strrep( sort_cmd, '""', '' );

    fprintf( fid, sprintf('\n%s', sort_cmd) );
  end
end

processed_pl2_files = adjusted_pl2_files( ~failed_to_process );

fclose( fid );

%%  generate run command

mda_file = 'bla_2_04052016_kurocoppola_post.mda';
mda_fullfile = fullfile( raw_p, mda_file );
out_fullfile = fullfile( firings_p, mda_file );

sort_cmd = ms_run.get_sort_command( pipeline_fullfile, mda_fullfile, out_fullfile, params_fullfile );

clipboard( 'copy', sort_cmd );

%%  generate run command

run_cmd = sprintf( 'bash "%s"', tmp_sh_fullfile );

clipboard( 'copy', run_cmd );

%%  choose file

FILE_NUMBER = 1;
region = 'acc';
pl2_file = processed_pl2_files{FILE_NUMBER};  

%%

sample_rate = 40e3;
mda_file = sprintf( '%s_%s', region, strrep(pl2_file, '..pl2', '.mda') );
raw_fullfile = fullfile( raw_p, mda_file );
firings_fullfile = fullfile( firings_p, mda_file );

view_cmd = ms_run.get_view_command( raw_fullfile, firings_fullfile, sample_rate );

clipboard( 'copy', view_cmd );
%%
current_mda_file = 'bla_1_Hitch_cop_082616.mda';

% current_mda_file = already_processed{FILE_NUMBER};


%%

sample_rate = 40e3;
mda_file = current_mda_file;
raw_fullfile = fullfile( raw_p, mda_file );
firings_fullfile = fullfile( firings_p, mda_file );

view_cmd = ms_run.get_view_command( raw_fullfile, firings_fullfile, sample_rate );

clipboard( 'copy', view_cmd );

