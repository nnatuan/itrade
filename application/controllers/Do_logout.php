<?php	if (!defined('BASEPATH')) exit('No direct script access allowed');
/*
 * Tokaban Standard System
 *
 * Tokaban framework for PHP
 *
 * @package		tkb_standard_system
 * @author		Tokaban R&D Team
 * @copyright	Copyright (c) 2009, Tokaban, Inc. 
 * @since		Version 2.0
 *   
 */ 
   
// ------------------------------------------------------------------------
class do_logout extends CI_Controller 
{	
	var $m_nid_user 		= ''; 
		
	// ------------------------------------------------------------------------
	
/** 
 * Constructor
 *
 * Load cac thu vien can su dung cho class 
 *
 * @access	public 
 */	
function __construct()
	{ 
		// 
		// DINH NGHIA BAT BUOC TRONG TAT CA CAC CONTROLLER.
		// KHONG DUOC TU Y THAY DOI CAC DONG THONG TIN BEN DUOI. 
		//
		parent::__construct();  
		session_start();
		$this->load->database();
		$this->load->helper('ap_function');
		$this->load->helper('ap_db');
		$this->load->helper('ap_html');
		$this->load->helper('ap_object');		
				
		// BAT TRANG THAI DA DUOC LOGIN.
		// SU DUNG HOOK DE KIEM TRA.
		$this->config->check_system_login = '1'; 
		
		// 
		// CAC DINH NGHIA CAN THIET KHAC
		// 
	} 
	
	// ------------------------------------------------------------------------
	
/**
 * Goi tuan tu cac ham theo dung quy dinh ve luong du lieu
 * 
 * @access	public
 */		
function index()
	{
		$this->do_process();
	}		
	
	// ------------------------------------------------------------------------

/**
 * Goi tuan tu cac ham theo dung quy dinh ve luong du lieu
 * 
 * @access	public
 */		
private function do_process()
	{
		$this->get_data(); 
		$this->caculate_data(); 
		$this->do_business();
		$this->destroy_data();
	}		
	
/**
 * Khong can xu ly
 *  
 * @access	private
 */	
private function get_data()
	{		
		// your code start here
		$this->m_nid_user = Fget_userdata('session_nid_user');
	}

	// ------------------------------------------------------------------------
	
/**
 * Khong can xu ly
 *
 * @access	private
 */		
private function caculate_data()
	{				
		// your code start here
	}
	
	// ------------------------------------------------------------------------
	
/**
 * Thiet lap cac session dung chung cho toan he thong 
 * Redirect do_login controller
 *
 * @access	private
 */		
private function do_business()
	{	
	
			$arr_data =	array(			
			'cstatus' => '0',
			);
			$this->db->where('cid_session',Fget_userdata('session_working'));
			$this->db->update(Fget_ap_table('tsession'), $arr_data);
			
			if(isset($_SESSION['token']))
				$_SESSION['token'] = NULL;
			
			
		// Cap nhat thong tin dang nhap vao he thong
		/*$arr_data =	array(			
			'cstatus' => '1',
			);
			$this->db->where('cid_session',Fget_userdata('session_working'));
			$this->db->update(Fget_ap_table('tsession'), $arr_data);

			Fset_userdata('session_nid_user',$nid_user);
			Fset_userdata('session_user_name',$obj_user_row['cuserid']);
			Fset_userdata('session_user_full_name',$str_user_fullname);
			Fset_userdata('session_user_isadmin',$obj_user_row['cisadmin']);*/
				
			//Fset_userdata('session_user_permission','');
			//Fset_userdata('session_user_menu_permission','');
			//Fset_userdata('session_user_organization_permission','');
			//Fset_userdata('session_user_management','');				
				//return TRUE;
				
				
			/*	
			//session_destroy();
			
			//exit('logout');

			$_SESSION['session_nid_user'] = NULL;
			$_SESSION['session_user_name'] = NULL;
			$_SESSION['session_user_full_name'] = NULL;
			$_SESSION['session_user_isadmin'] = NULL;
			
			Fset_userdata('session_nid_user',NULL);
			Fset_userdata('session_user_name',NULL);
			Fset_userdata('session_user_full_name',NULL);
			Fset_userdata('session_user_isadmin',NULL);
			
			
			
			if(isset($_SESSION['session_nid_user'])) 
				exit ($_SESSION['session_nid_user'].'-1'); 
			exit('0');
			*/
		redirect ('do_init');
	}
		
	// ------------------------------------------------------------------------
	
/**
 * Khong can xy ly
 *
 * @access	private
 */	
private function destroy_data()
	{
		
	}

//
// DINH NGHIA CAC HAM LOGIC CAN THIET KHAC TAI DAY
//


// END do_init class
}		
/* End of file do_init.php */
/* Location: controller/do_init.php */