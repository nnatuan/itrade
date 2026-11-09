<?php if (!defined('BASEPATH')) exit('No direct script access allowed');
	

	
	
	//Add fck Editor 
	function init_fck()
	{
		$CI =& get_instance();
		  $fckeditorConfig = array(
          'instanceName' 	=> 'a',
          'BasePath' 		=> base_url().'tkb_application/plugins/fckeditor/',
		  'ToolbarSet' 		=> 'Basic',
          'Width' 			=> '100%',
          'Height' 			=> '100%',
          'Value' 			=> ''
           );
   			$CI->load->library('fckeditor', $fckeditorConfig);
			
	}