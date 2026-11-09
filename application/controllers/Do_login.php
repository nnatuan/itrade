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
 * */ 
   
// ------------------------------------------------------------------------
class do_login extends CI_Controller 
{	
	var $m_language 		= ''; 
	var $m_nid_user 		= ''; 
			 
	var $m_link_page		= ''; 
	var $m_event_index		= ''; 
	var $m_view_index		= '';
	 
	var $m_error_message	= '';
	var $m_form_title		= '';
	var $m_txt_user_name	= ''; 
	var $m_txt_password		= ''; 
	// ------------------------------------------------------------------------
	
/** * Constructor
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
				
		// BAT TRANG THAI DA DUOC LOGIN.
		// SU DUNG HOOK DE KIEM TRA.
		$this->config->check_system_login = '2';
	} 
	
	// ------------------------------------------------------------------------
	
/**
 * Goi tuan tu cac ham theo dung quy dinh ve luong du lieu
 * * @access	public
 */		
function index()
	{
		$this->do_process();
	}		
	
	// ------------------------------------------------------------------------

/**
 * Goi tuan tu cac ham theo dung quy dinh ve luong du lieu
 * * @access	public
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
 * * @access	private
 */	
private function get_data()
	{		
		$this->m_language = Fget_userdata('session_user_language');										
		$this->m_nid_user = Fget_userdata('session_nid_user');
		
		if(isset($_POST['txt_user_name']))
				$this->m_txt_user_name 		= trim($_POST['txt_user_name']);
	
		if(isset($_POST['txt_password']))
				$this->m_txt_password 		= trim($_POST['txt_password']);
				
		if(isset($_POST['hidden_button']))
				$this->m_event_index 		= $_POST['hidden_button'];		
	}

	// ------------------------------------------------------------------------
	
/**
 * Khong can xu ly
 *
 * @access	private
 */		
private function caculate_data()
	{		
		$this->load->language('ap',$this->m_language);
					
		$this->m_view_index 	= 'login_view';
		$this->m_link_page 		= base_url().'index.php/do_login';
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
		if(trim($this->m_event_index)=='btn_login')
			if($this->check_valid_login()===TRUE) 
				redirect ('do_home');
		
		$data['link_page']        		= $this->m_link_page;
		
		$data['lbl_form_title']        	= $this->lang->line('lbl.0001.FormTitle');
		$data['lbl_form_slogan']       	= $this->lang->line('lbl.0001.FormSlogan');
		
		$data['lbl_user_name']			= $this->lang->line('lbl.0001.UserName');
		$data['lbl_password']			= $this->lang->line('lbl.0001.Password');
		
		$data['btn_login']      	 	= $this->lang->line('btn.0001.Login');
				
		$data['error_message'] 			= $this->m_error_message;
		
		$data['txt_user_name'] 			= $this->m_txt_user_name;
		$data['event'] 			= 'login';
		$data['txt_password'] 			= '';
		$data['fr_img']               = Fstr_replace('admin/', '', base_url());
		$data['menu_active']			= 'login';
		$data['base_url_admin']	= Fstr_replace(Fget_admin_folder(),'',base_url());

		$this->load->view('login_view/index', $data);
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
// DINH NGHIA CAC HAM LOGIC XÁC THỰC PHÂN QUYỀN MỚI TẠI ĐÂY
//
private function check_valid_login()
	{
		// Kiem tra user dang nhap khong duoc phep rong
		if (trim($this->m_txt_user_name)=='')
		{
			$this->m_error_message = "Vui lòng nhập ID tài khoản hoặc Email đăng nhập";
			return FALSE;
		}
		// Kiem tra thong tin mat khau khong duoc phep rong
		if (trim($this->m_txt_password)=='')
		{
			$this->m_error_message = "Vui lòng nhập mật khẩu truy cập hệ thống";
			return FALSE;
		}
				
		$str_userid_verified = $this->m_txt_user_name;

		// Kiểm tra nếu thông tin đăng nhập nhập vào là định dạng Email
		if (filter_var($this->m_txt_user_name, FILTER_VALIDATE_EMAIL)) 
		{
			$this->db->select('cuserid');
			$this->db->where('cemail', $this->m_txt_user_name);
			$this->db->where('cdel', '0');
			$this->db->where('cstatus', '1');
			
			// ĐỒNG BỘ: Đổi bộ lọc kiểm tra email sang nhóm quyền quản trị (admin) và kinh doanh (sale)
			$this->db->where_in('crole', array('admin', 'sale'));
			
			$obj_email_query = $this->db->get('tuser')->row_array();

			if (!empty($obj_email_query)) 
			{
				$str_userid_verified = $obj_email_query['cuserid']; // Lấy ID tài khoản liên kết với email
			} 
			else 
			{
				$this->m_error_message = "Địa chỉ email này không tồn tại hoặc đã bị khóa trên hệ thống";
				return FALSE;
			}
		}

		// Tiến hành xác thực cặp tài khoản (cuserid) và mật khẩu (MD5) trong bảng tuser mới
		$this->db->select('nid, cuserid, cfullname, crole');
		$this->db->where('cuserid', $str_userid_verified);
		$this->db->where('cpassword', md5($this->m_txt_password));
		$this->db->where('cdel', '0');
		$this->db->where('cstatus', '1');
		
		// ĐỒNG BỘ: Chấp nhận xác thực đăng nhập vào bảng điều khiển cho cả Admin và Sale/Đại lý
		$this->db->where_in('crole', array('admin', 'sale'));
		$obj_auth_query = $this->db->get('tuser')->row_array();

		if (empty($obj_auth_query))
		{
			$this->m_error_message = "Tên đăng nhập, email hoặc mật khẩu không chính xác";
			return FALSE;
		}
		else // Xu ly truong hop dang nhap thong tin thanh cong
		{
			$nid_user = $obj_auth_query['nid'];

			// Cap nhat thong tin dang nhap vao he thong session database
			$arr_data =	array(
				'nid_user'			=> $nid_user,
				'cstatus'			=> '1',
				);
			$this->db->where('cid_session', Fget_userdata('session_working'));
			$this->db->update(Fget_ap_table('tsession'), $arr_data);
			
			// Đồng bộ chuỗi họ tên hiển thị lên thanh topbar điều hướng
			$str_user_fullname = !empty($obj_auth_query['cfullname']) ? $obj_auth_query['cfullname'] : $obj_auth_query['cuserid'];

			// Thiết lập các thông tin Session cốt lõi lên hệ thống
			Fset_userdata('session_nid_user', $nid_user);
			Fset_userdata('session_user_name', $obj_auth_query['cuserid']);
			Fset_userdata('session_user_full_name', $str_user_fullname);
			
			// Lưu phân quyền chuỗi (admin, sale) để check ẩn hiện menu và phân tách tệp khách hàng
			Fset_userdata('session_user_role', $obj_auth_query['crole']);
			
			return TRUE;
		}							
	}

// END do_login class
}		
/* End of file do_login.php */
/* Location: controllers/do_login.php */