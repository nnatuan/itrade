<?php if (!defined('BASEPATH')) exit('No direct script access allowed'); 

/**
 * =================================================================
 * Tokaban Standard System.
 * CodeIniter Tokaban framework for PHP.
 *
 * @package		: CI-TKB 
 * @author		: Tokaban R&D Team.
 * 				: an_hm87
 * @copyright	: Copyright (c) 2009, Tokaban, Inc.
 * @since		: Version 2.0
 * =================================================================
 */   

/**
 *------------------------------------------------------------------
 * employee_model class
 *
 * 
 * @package		ap_standard_system
 * @subpackage	models
 * @category	
 * @author		Hoang Minh An
 *------------------------------------------------------------------
 */	
class tkblib_model extends CI_Model
{
function __construct() 
	{	
		parent::__construct();
	}
//
//	
function export_excel($report_name,$data, $view_address)	
	{
		
		header("Content-type: application/vnd.ms-excel"); 
		header("Content-Disposition: attachment; filename=".$report_name);
		header("Pragma: no-cache");
		header("Expires: 0");
		print ($this->load->view($view_address,$data,TRUE));
	}

/**
 |====================================================================
 | DANH SACH CAC HAM DINH NGHIA THEM
 |====================================================================
 */
	
	

}
