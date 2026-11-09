<?php	if (!defined('BASEPATH')) exit('No direct script access allowed');
/*
 * Tokaban Standard System
 *
 * Tokaban framework for PHP
 *
 * @package		ap_standard_system
 * @author		Tokaban R&D Team
 * @copyright	Copyright (c) 2009, Tokaban, Inc.
 * @since		Version 2.0
 *  
 */
  
// ------------------------------------------------------------------------
class do_home extends CI_Controller 
{
	var $m_language 		= ''; 
	var $m_nid_user_login 	= ''; 
	
	var $m_event			= 'view';
		
	var $m_action			= ''; 	 
	var $m_frm_link_to_		= ''; 

	var $m_txt_user_name	= ''; 
	var $m_txt_password		= ''; 
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
		parent::__construct();  
		session_start();
		$this->load->database();
		$this->load->helper('ap_function');
		$this->load->helper('ap_db');
		$this->load->helper('ap_html');
		$this->load->helper('ap_object');
		$this->load->helper('ap_module');
		//$this->tokaban_system_check = '1';  
		$this->config->check_system_login = '1';
	}
	
	// ------------------------------------------------------------------------
	
/**
 * Goi tuan tu cac ham theo dung quy dinh ve luong du lieu
 * 
 * @access	public
 */		
function index()
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
		$this->m_nid_user_login = Fget_userdata('session_nid_user');
		$this->m_language = Fget_userdata('session_user_language');	
		// Load file ngon ngu can su dung.
		$this->load->language('ap', $this->m_language);
		
		// Your code at here		
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
    $data['menu_active'] = 'home';
    $data['event'] = $this->m_event;
    
    // 1. Lấy thông tin quyền hạn và ID của người đang đăng nhập từ Session
    $n_user_id = (int)$this->m_nid_user_login;
    $c_role    = Fget_userdata('session_user_role');
    if($c_role == '') $c_role = 'client';
    
    // 2. Nạp dữ liệu các khối thống kê (Truyền thêm ID và Quyền vào để lọc)
    $data['arr_stats'] = Obj_get_bot_dashboard_stats($n_user_id, $c_role);
    
    // 3. Nạp dữ liệu cho Top 5 tài khoản gồng lỗ và lợi nhuận (Lọc theo Sale)
    $data['arr_top_profit']   = Obj_get_top_profit_accounts(5, $n_user_id, $c_role);
    $data['arr_top_drawdown'] = Obj_get_top_drawdown_accounts(5, $n_user_id, $c_role);
    
    // 4. Nạp dữ liệu bảng danh sách tài khoản mới kết nối
    $data['arr_recent_clients'] = Obj_get_recent_connected_clients(5, $n_user_id, $c_role);
    
    // 5. Nhật ký hoạt động từ xa (Bảo mật: Sale chỉ xem được log của khách mình quản lý)
    $data['arr_system_activities'] = Obj_get_bot_system_activities(5, $n_user_id, $c_role);
    
    $this->load->view('home_view/index.php', $data);
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