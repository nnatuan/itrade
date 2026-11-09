<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_bot_license_history extends CI_Controller
{
    var $m_nid_user_login   = ''; 
    var $m_link_page        = ''; 
    var $m_event            = 'bot_license_history';
    var $m_where_clause     = ''; 
    
    var $m_total_row        = 0;  
    var $m_total_page       = 0;  
    var $m_current_page     = 1; 			
    var $m_row_per_page     = 10;  
    
    // Bộ lọc tìm kiếm lịch sử
    var $m_txtf_cmt5_account = ''; 
	var $m_txtf_cfullname    = '';
    var $m_txtf_clicense_key = '';
    var $m_cbof_action_type  = '';

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
        $this->m_link_page = base_url() . 'index.php/do_bot_license_history/';
    }	
    
    private function f_set_cookie($cookie_name, $cookie_value) { 
        return dbset_cookie('cookie_bot_license_history_' . $cookie_name, $cookie_value);
    }
    private function f_get_cookie($cookie_name) { 
        return dbget_cookie('cookie_bot_license_history_' . $cookie_name);
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
                    $this->m_txtf_clicense_key = isset($_POST['txtf_clicense_key']) ? trim($_POST['txtf_clicense_key']) : '';
                    $this->m_cbof_action_type  = isset($_POST['cbof_action_type']) ? $_POST['cbof_action_type'] : '';
                    
                    $this->f_set_cookie('m_txtf_cmt5_account', $this->m_txtf_cmt5_account);
                    $this->f_set_cookie('m_txtf_cfullname', $this->m_txtf_cfullname);
                    $this->f_set_cookie('m_txtf_clicense_key', $this->m_txtf_clicense_key);
                    $this->f_set_cookie('m_cbof_action_type', $this->m_cbof_action_type);
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
        $this->m_txtf_clicense_key = $this->f_get_cookie('m_txtf_clicense_key');
        $this->m_cbof_action_type  = $this->f_get_cookie('m_cbof_action_type');
        
        $str_result = ' WHERE c.cdel = "0" ';
        
        // ĐỒNG BỘ PHÂN QUYỀN: Nếu Sale đang đăng nhập, ép chết luồng chỉ bốc lịch sử của khách hàng mình
        $c_user_role = Fget_userdata('session_user_role');
        if($c_user_role == 'sale') {
            $str_result .= ' AND u.nparent_id = ' . (int)$this->m_nid_user_login . ' ';
        }

        if ($this->m_txtf_cmt5_account != '')
            $str_result .= ' AND h.cmt5_account like "%' . $this->db->escape_like_str($this->m_txtf_cmt5_account) . '%" ';
        if ($this->m_txtf_cfullname != '')
            $str_result .= ' AND u.cfullname like "%' . $this->db->escape_like_str($this->m_txtf_cfullname) . '%" ';
        if ($this->m_txtf_clicense_key != '')
            $str_result .= ' AND h.clicense_key like "%' . $this->db->escape_like_str($this->m_txtf_clicense_key) . '%" ';
        if ($this->m_cbof_action_type != '')
            $str_result .= ' AND h.naction_type = "' . $this->db->escape_like_str($this->m_cbof_action_type) . '" ';
            
        $this->m_where_clause = $str_result;	
        $this->m_total_row = Obj_get_license_history_count($this->m_where_clause);		
        
        if ($this->m_row_per_page <= 0) $this->m_row_per_page = 10;			
        $this->m_total_page = Fget_total_page($this->m_row_per_page, $this->m_total_row);
        
        if ($this->m_current_page <= 0) $this->m_current_page = 1;		
        if ($this->m_current_page > $this->m_total_page) $this->m_current_page = $this->m_total_page;
        
        $n_start_row = ($this->m_current_page - 1) * $this->m_row_per_page;
        if($n_start_row < 0) $n_start_row = 0;

        $this->m_obj_data_view = Obj_get_license_history_pagination($this->m_where_clause, $n_start_row, $this->m_row_per_page);
    }
       
    private function do_business()
    {	
        $data['lbl_form_title']      = "Nhật ký lịch sử Cấp mới & Gia hạn Bản quyền Bot";
        $data['link_page']           = $this->m_link_page;
        $data['btn_choose']          = "Chọn";
        $data['lbl_rows_per_page']   = "Số dòng hiển thị";
		
        $data['txt_row_per_page']    = $this->m_row_per_page;
        $data['txt_current_page']    = $this->m_current_page;
        $data['txt_total_page']      = $this->m_total_page;			
                
        $data['txtf_cmt5_account']   = $this->m_txtf_cmt5_account;
		$data['txtf_cfullname']     = $this->m_txtf_cfullname;
        $data['txtf_clicense_key']   = $this->m_txtf_clicense_key;
        $data['cbof_action_type']    = $this->m_cbof_action_type;
        
        $data['menu_active']         = 'bot_license_history';
        $data['data_view']           = $this->m_obj_data_view; 
        $data['event']               = $this->m_event; 
		
        $this->load->view('bot_client_view/index.php', $data);
    }
}