<?php
if (!defined('BASEPATH')) exit('No direct script access allowed');
/*
 * Tokaban Standard System 
 *
 * Tokaban framework for PHP
 *
 * @package		ap_standard_system.
 * @author		Tokaban R&D Team.
 * @copyright	Copyright (c) 2009, Tokaban, Inc.
 * @since		Version 2.0
 *    
 */     
// ------------------------------------------------------------------------

class do_init extends CI_Controller  
{	
	/**
	 * Constructor
	 *  
	 * Load cac thu vien can su dung cho class 
	 * 
	 * @access	public
	 */
	
	var $currentTimeoutInSecs	= 0;
	
	function __construct() 
	{  
		// default load library code
		parent::__construct();  
		session_cache_expire(1);
		session_start();		
		$this->currentTimeoutInSecs = ini_set('session.cookie_lifetime',5);
		//date_default_timezone_set('Asia/Ho_Chi_Minh');
		$this->load->database();
		
		// load other library  
		$this->load->helper('ap_function'); 
		$this->load->helper('ap_db');
		
		//
		// Kiem tra hooks dac biet voi tu khoa begin.
		// 
		//$this->tokaban_system_check = 'begin';
		$this->config->check_system_login = 'begin';
	}
	
	// ------------------------------------------------------------------------
	
	/**
	 * Goi tuan tu cac ham theo dung quy dinh ve luong du lieu
	 * 
	 * @access	public
	 */		
	function index()
	{
		$this->do_index(); 
	}		
 
	function do_index()
	{
		$this->get_data(); 
		$this->caculate_data(); 
		$this->do_business();
		$this->destroy_data();
	}		
	
	// ------------------------------------------------------------------------
	
	/**
	 * Khong can xu ly
	 *
	 * @access	private
	 */	
	private function get_data()
	{
		// Your code at here
		/* ------------------------------------------------------------------------ */
		// Bat co*` xac dinh cac doi tuong duoc khoi dong tu do_init.
		Fset_userdata('session_begin_application','1');
		// Xac dinh bien ngon ngu bat dau su dung cho he thong
		Fset_userdata('session_user_language','eng'); 
		// Dinh nghia tien to ten table su dung trong he thong
		Fset_userdata('session_ap_prefix', $this->config->item('system_ap_prefix'));		
		// 
		// Xac dinh so dong thong tin tren mot trang.
		// BAT BUOC PHAI DU`NG SESSION CHUAN CUA HTML SERVER. 
		//
		Fset_userdata('session_user_row_per_page', $this->config->item('system_row_per_page'));
		Fset_userdata('session_user_row_per_page01', $this->config->item('system_row_per_page01'));
		Fset_userdata('session_user_row_per_page02', $this->config->item('system_row_per_page02'));
		Fset_userdata('system_total_detail_row', $this->config->item('system_total_detail_row'));
		
		// Xac dinh bien thoi gian
		//	Dung de khoi tao phien bat dau lam viec
		Fset_userdata('session_working',date('Y_m_d').'_'.time());
		
		// 
		// Cac gia tri tuy chon ca nhan.
		// Thong tin se duoc bo sung day du sau khi da duoc login.
		//
		Fset_userdata('session_nid_user','');						// Xac dinh nid user dang nhap.
		Fset_userdata('session_user_name','');						// Xac dinh userid user dang nhap.
		Fset_userdata('session_user_full_name','');					// Xac dinh thong tin day du cua user.
		
		Fset_userdata('session_user_isadmin','');				// Xac dinh loai user. admin, quan ly, nhan vien, khach
		Fset_userdata('session_user_menu_permission','');			// Xac dinh danh sach cac menu duoc su dung.
		Fset_userdata('session_user_organization_permission','');	// Xac dinh danh sach cac don vi user duoc su dung.
		Fset_userdata('session_user_management','');				// Xac dinh danh sach cac user duoc quan ly.
				
	}

	// ------------------------------------------------------------------------
	
	/**
	 * Khong can xu ly
	 *
	 * @access	private
	 */		
	private function caculate_data()
	{
		// Your code at here				
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
		//
		// luu thong tin db_truy xuat he thong vao db.
		//
		//$arr_data =	array(			
//				'cid_session' 	=> Fget_userdata('session_working'),
//				'cstatus'		=> 0,
//				'nid_user'		=> 0,
//				'dsession_date'	=> date('Y_m_d'),
//				);
//		$this->db->insert(Fget_ap_table('tsession'), $arr_data);
		//
		// Xac dinh thong tin user la doi tuong khach GUEST.
		// Chi xac dinh duoc thanh vien trong truong hop nguoi su dung dang nhap he thong.
		// BAT BUOC PHAI DU`NG SESSION CHUAN CUA HTML SERVER
		//
		 		 
		// Kich hoat bien co khoi dong ung dung sau khi khoi tao thanh cong cac bien moi truong
		redirect('do_login');
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

// END do_init class		
}		
/* End of file do_init.php */
/* Location: controller/do_init.php */