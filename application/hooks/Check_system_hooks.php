<?php 
defined('BASEPATH') OR exit('No direct script access allowed');
class Check_system_hooks extends CI_Controller { 
/**
* Constructor
*/   
 private $CI;
  
  function __construct()
    {
    	parent::__construct();
        $this->CI =& get_instance();
        $this->CI->load->helper('ap_function');
        //$this->load->helper('ap_function'); 
    }

public function check_system_valid()
	{
		$CI =& get_instance();
		switch ( trim($CI->config->check_system_login))
		{			
			// Only use for init controller.
			case 'begin':
				return TRUE;
				break;
			
			// Check valid begin from init controller	
			case '0':
				if ( $this->check_begin_application_valid() == TRUE )
					return TRUE;
				else
					redirect ('do_init');	
				break;
			
			// Check valid BackEnd.	
			case '1': 
				if ( $this->check_valid_backend())
					return TRUE;
				else
					redirect ('do_init');	
				break;
			
			// Check valid FrontEnd.	
			case '2':			
				if ( $this->check_valid_frontend() == TRUE )
					return TRUE;
				else
					redirect ('do_init');	
				break;			
			// Invalid run application.				
			default:
				exit('Your code invalid. <br> Check it with your R&D team, please.');
				break;			
		}		
	}

//
//	Kiem tra ung dung duoc khoi dong hop le.
//
private function check_begin_application_valid()
    {
		if (Fget_userdata('session_begin_application')=='1')
			return TRUE;
		else
			return FALSE;
									
    }

//
//	Kiem tra dieu kien su dung cac controller thuoc backend.
//
private function check_valid_frontend()
    {
		if($this->check_begin_application_valid() == TRUE)
			return TRUE;
		else
			return FALSE;	
    }

//
//	Kiem tra dieu kien su dung cac controller thuoc backend.
//
function  check_login()
{	
	
			if(Fget_userdata('session_nid_user') =='' OR Fget_userdata('session_nid_user') =='0')
				return FALSE;
			else
				return TRUE;

}
private function check_valid_backend()
    {	
		if($this->check_begin_application_valid() == TRUE AND $this->check_login()== TRUE)
			return TRUE;
		else
			return FALSE;
    }
}

