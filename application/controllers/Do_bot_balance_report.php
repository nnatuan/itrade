<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_bot_balance_report extends CI_Controller
{ 	
    var $m_nid_user_login    = ''; 
    var $m_link_page         = ''; 
    var $m_event             = 'balance_report';
    var $m_where_clause      = ''; 
    
    var $m_total_row         = 0;  
    var $m_total_page        = 0;  
    var $m_current_page      = 1; 			
    var $m_row_per_page      = 10;  
    
    // Bộ lọc tìm kiếm chuyên dụng cho phân hệ quản trị rủi ro tài chính
    var $m_txtf_cmt5_account = ''; 
    var $m_txtf_cfullname    = ''; 
    var $m_cbof_risk_status  = '';

    function __construct()
    { 
        parent::__construct();
        session_start();
        $this->load->database();	
        $this->load->helper('ap_db');	
        $this->load->helper('ap_function');
        $this->load->helper('ap_html'); 	
        $this->load->helper('ap_view'); 	
        $this->load->helper('ap_module');
        $this->config->check_system_login = '1'; 	
        $this->m_link_page = base_url() . 'index.php/do_bot_balance_report/';
    }	
    
    private function f_set_cookie($cookie_name, $cookie_value) { 
        return dbset_cookie('cookie_balance_report_' . $cookie_name, $cookie_value);
    }
    private function f_get_cookie($cookie_name) { 
        return dbget_cookie('cookie_balance_report_' . $cookie_name);
    }				
    
    function index() {				
        $this->do_process();
    }    
            
    function do_process() {
        $this->get_data(); 		
        $this->caculate_data(); 		
        $this->do_business(); 		
    } 

    private function get_data()
    {        
        $this->m_nid_user_login = Fget_userdata('session_nid_user');
        
        if (isset($_POST['hidden_button'])) {
            $hidden_button = $_POST['hidden_button'];
            switch ($hidden_button) {
                case "btn_filter":
                    $this->m_txtf_cmt5_account = isset($_POST['txtf_cmt5_account']) ? trim($_POST['txtf_cmt5_account']) : '';
                    $this->m_txtf_cfullname    = isset($_POST['txtf_cfullname']) ? trim($_POST['txtf_cfullname']) : '';
                    $this->m_cbof_risk_status  = isset($_POST['cbof_risk_status']) ? $_POST['cbof_risk_status'] : '';
                    
                    $this->f_set_cookie('m_txtf_cmt5_account', $this->m_txtf_cmt5_account);
                    $this->f_set_cookie('m_txtf_cfullname', $this->m_txtf_cfullname);
                    $this->f_set_cookie('m_cbof_risk_status', $this->m_cbof_risk_status);
                    $this->m_current_page = 1;
                    break;			
    
                case "btn_row_per_page":
                    if (isset($_POST['txt_row_per_page'])) $this->m_row_per_page = (int)$_POST['txt_row_per_page'];
                    break;
                    
                case "btn_page_number":
                    if (isset($_POST['txt_current_page'])) $this->m_current_page = (int)$_POST['txt_current_page'];
                    break;	
                
                case "btn_next":
                    $this->m_current_page = (int)$_POST['txt_current_page'] + 1;
                    break;	
                
                case "btn_previous":
                    $this->m_current_page = (int)$_POST['txt_current_page'] - 1;
                    break;	
            }
        }
    } 
    
    private function caculate_data()
    {	   
        $this->m_txtf_cmt5_account = $this->f_get_cookie('m_txtf_cmt5_account');
        $this->m_txtf_cfullname    = $this->f_get_cookie('m_txtf_cfullname');
        $this->m_cbof_risk_status  = $this->f_get_cookie('m_cbof_risk_status');
        
        $str_result = ' WHERE c.cdel = "0" ';
        
        // ĐỒNG BỘ PHÂN QUYỀN: Cô lập dữ liệu nếu tài khoản đăng nhập là Sale
        $c_user_role = Fget_userdata('session_user_role');
        if($c_user_role == 'sale') {
            $str_result .= ' AND u.nparent_id = ' . (int)$this->m_nid_user_login . ' ';
        }

        if ($this->m_txtf_cmt5_account != '')
            $str_result .= ' AND c.cmt5_account like "%' . $this->db->escape_like_str($this->m_txtf_cmt5_account) . '%" ';
        if ($this->m_txtf_cfullname != '')
            $str_result .= ' AND u.cfullname like "%' . $this->db->escape_like_str($this->m_txtf_cfullname) . '%" ';
            
        // Bộ lọc phân loại mức độ rủi ro tài khoản đang gồng lệnh âm thực tế
        if ($this->m_cbof_risk_status != '') {
            switch ($this->m_cbof_risk_status) {
                case 'safe':
                    $str_result .= ' AND c.fdrawdown < 10.00 ';
                    break;
                case 'warning':
                    $str_result .= ' AND c.fdrawdown >= 10.00 AND c.fdrawdown < 30.00 ';
                    break;
                case 'danger':
                    $str_result .= ' AND c.fdrawdown >= 30.00 ';
                    break;
            }
        }
            
        $this->m_where_clause = $str_result;	
        
        // Gọi hàm đếm tổng dòng từ ap_module_helper.php
        $this->m_total_row = Obj_get_bot_client_count($this->m_where_clause);		
        
        if ($this->m_row_per_page <= 0) $this->m_row_per_page = 10;			
        $this->m_total_page = Fget_total_page($this->m_row_per_page, $this->m_total_row);
        
        if ($this->m_current_page <= 0) $this->m_current_page = 1;		
        if ($this->m_current_page > $this->m_total_page) $this->m_current_page = $this->m_total_page;
        
        $n_start_row = ($this->m_current_page - 1) * $this->m_row_per_page;
        if($n_start_row < 0) $n_start_row = 0;

        // Gọi hàm phân trang từ ap_module_helper.php
        $this->m_obj_data_view = Obj_get_bot_client_pagination($this->m_where_clause, $n_start_row, $this->m_row_per_page);
    }
       
    private function do_business()
    {	
        $data['lbl_form_title']      = "Báo cáo & Giám sát Trạng thái Quỹ Giao dịch trực tuyến";
        $data['link_page']           = $this->m_link_page;
        $data['btn_choose']          = "Chọn";
        $data['lbl_rows_per_page']   = "Số dòng hiển thị";
		
        $data['txt_row_per_page']    = $this->m_row_per_page;
        $data['txt_current_page']    = $this->m_current_page;
        $data['txt_total_page']      = $this->m_total_page;			
                
        $data['txtf_cmt5_account']   = $this->m_txtf_cmt5_account;
        $data['txtf_cfullname']      = $this->m_txtf_cfullname;
        $data['cbof_risk_status']    = $this->m_cbof_risk_status;
        
        // ĐỒNG BỘ PHÂN QUYỀN: Truyền thêm ID và Vai trò để Widget đếm số chính xác theo từng Sale
        $c_user_role = Fget_userdata('session_user_role');
        $data['bot_stats']           = Obj_get_bot_dashboard_stats((int)$this->m_nid_user_login, $c_user_role);
        
        $data['menu_active']         = 'bot_balance_report';
        $data['data_view']           = $this->m_obj_data_view; 
        $data['event']               = $this->m_event; 
		
        $this->load->view('bot_client_view/index.php', $data);
    }
}