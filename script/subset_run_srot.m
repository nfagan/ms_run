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

adjusted_pl2_files = cell( size(pl2_files) );
failed_to_process = false( size(pl2_files) );
more_than_one = false( size(pl2_files) );

current_mda_files = shared_utils.io.dirnames( firings_p, '.mda', false );

allow_regions = { 'bla', 'acc' };

%%



