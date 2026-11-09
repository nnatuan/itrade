<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_staff_listview extends CI_Controller
{ 	 
    var $m_nid_user_login   = ''; 
    var $m_link_page        = ''; 
    var $m_event            = 'view';
    var $m_where_clause     = ''; 
    
    var $m_total_row        = 0;  
    var $m_total_page       = 0;  
    var $m_current_page     = 1; 			
    var $m_row_per_page     = 10;  
    
    // Bộ lọc tìm kiếm
    var $m_txtf_cuserid     = ''; 
    var $m_txtf_cfullname   = ''; 
    var $m_txtf_cemail      = ''; 
    var $m_txtf_chandphone  = ''; 
    var $m_cbof_crole       = '';

    function __construct()
    { 
        parent::__construct();
        session_start();
        $this->load->database();	
        $this->load->helper('ap_db');	
        $this->load->helper('ap_function');
        $this->load->helper('ap_html'); 	
        $this->load->helper('ap_view'); 	
        $this->load->helper('ap_object');	
        $this->load->helper('ap_module_helper');
        $this->config->check_system_login = '1'; 	
        $this->m_link_page = base_url() . 'index.php/do_staff_listview/';
		
		// ĐỒNG BỘ BẢO MẬT: Nếu không phải admin thì lập tức quay về trang chủ
        $c_user_role = Fget_userdata('session_user_role');
        if ($c_user_role != 'admin') {
            redirect(base_url() . 'index.php/do_home');
        }
    }	
    
    private function f_set_cookie($cookie_name, $cookie_value) { 
        return dbset_cookie('cookie_staff_listview_' . $cookie_name, $cookie_value);
    }
    private function f_get_cookie($cookie_name) { 
        return dbget_cookie('cookie_staff_listview_' . $cookie_name);
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
                    $this->m_txtf_cuserid   = isset($_POST['txtf_cuserid']) ? trim($_POST['txtf_cuserid']) : '';
                    $this->m_txtf_cfullname = isset($_POST['txtf_cfullname']) ? trim($_POST['txtf_cfullname']) : '';
                    $this->m_txtf_cemail    = isset($_POST['txtf_cemail']) ? trim($_POST['txtf_cemail']) : '';
                    $this->m_txtf_chandphone = isset($_POST['txtf_chandphone']) ? trim($_POST['txtf_chandphone']) : '';
                    $this->m_cbof_crole     = isset($_POST['cbof_crole']) ? $_POST['cbof_crole'] : '';
                    
                    $this->f_set_cookie('m_txtf_cuserid', $this->m_txtf_cuserid);
                    $this->f_set_cookie('m_txtf_cfullname', $this->m_txtf_cfullname);
                    $this->f_set_cookie('m_txtf_cemail', $this->m_txtf_cemail);
                    $this->f_set_cookie('m_txtf_chandphone', $this->m_txtf_chandphone);
                    $this->f_set_cookie('m_cbof_crole', $this->m_cbof_crole);
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
                
                case "btn_add":
                    redirect(base_url() . 'index.php/do_staff/f_add');
                    break;
            }
        }
    } 
    
    private function caculate_data()
    {	   
        $this->m_txtf_cuserid   = $this->f_get_cookie('m_txtf_cuserid');
        $this->m_txtf_cfullname = $this->f_get_cookie('m_txtf_cfullname');
        $this->m_txtf_cemail    = $this->f_get_cookie('m_txtf_cemail');
        $this->m_txtf_chandphone = $this->f_get_cookie('m_txtf_chandphone');
        $this->m_cbof_crole     = $this->f_get_cookie('m_cbof_crole');
        
        // ĐỒNG BỘ: Quét tài khoản nhân sự có vai trò quản trị (admin) hoặc kinh doanh (sale)
        $str_result = ' WHERE cdel = "0" AND crole IN ("admin", "sale") ';
        
        if ($this->m_txtf_cuserid != '')
            $str_result .= ' AND cuserid like "%' . $this->db->escape_like_str($this->m_txtf_cuserid) . '%" ';
        if ($this->m_txtf_cfullname != '')
            $str_result .= ' AND cfullname like "%' . $this->db->escape_like_str($this->m_txtf_cfullname) . '%" ';
        if ($this->m_txtf_cemail != '')
            $str_result .= ' AND cemail like "%' . $this->db->escape_like_str($this->m_txtf_cemail) . '%" ';
        if ($this->m_txtf_chandphone != '')
            $str_result .= ' AND chandphone like "%' . $this->db->escape_like_str($this->m_txtf_chandphone) . '%" ';
        if ($this->m_cbof_crole != '')
            $str_result .= ' AND crole = "' . $this->db->escape_like_str($this->m_cbof_crole) . '" ';
            
        $this->m_where_clause = $str_result;	
        
        $this->m_total_row = Obj_get_staff_count($this->m_where_clause);		
        
        if ($this->m_row_per_page <= 0) $this->m_row_per_page = 10;			
        $this->m_total_page = Fget_total_page($this->m_row_per_page, $this->m_total_row);
        
        if ($this->m_current_page <= 0) $this->m_current_page = 1;		
        if ($this->m_current_page > $this->m_total_page) $this->m_current_page = $this->m_total_page;
        
        $n_start_row = ($this->m_current_page - 1) * $this->m_row_per_page;
        if($n_start_row < 0) $n_start_row = 0;

        $this->m_obj_data_view = Obj_get_staff_pagination($this->m_where_clause, $n_start_row, $this->m_row_per_page);
    }
       
    private function do_business()
    {	
        $data['lbl_form_title']     = "Quản lý Tài khoản";
        $data['link_page']          = $this->m_link_page;
        $data['btn_choose']         = "Chọn";
        $data['lbl_rows_per_page']  = "Số dòng hiển thị";
        
        $data['txt_row_per_page']   = $this->m_row_per_page;
        $data['txt_current_page']   = $this->m_current_page;
        $data['txt_total_page']     = $this->m_total_page;			              
        
        $data['cbof_crole']         = $this->m_cbof_crole;
        $data['txtf_cuserid']       = $this->m_txtf_cuserid; 
		$data['txtf_cfullname']     = $this->m_txtf_cfullname;
        $data['txtf_cemail']        = $this->m_txtf_cemail; 
        $data['txtf_chandphone']    = $this->m_txtf_chandphone; 
		
        $data['menu_active']        = 'staff';
        $data['data_view']          = $this->m_obj_data_view; 
        $data['event']              = $this->m_event; 

        $this->load->view('staff_view/index.php', $data);
    }
    
    function f_delete($nid) {
        $this->m_nid_user_login = Fget_userdata('session_nid_user');

        $data_delete = array(
            'cdel'          => '1',
            'nuser_updated' => $this->m_nid_user_login,
            'ddate_updated' => date('Y-m-d H:i:s')
        );

        $res_delete = $this->db->where('nid', (int)$nid)->update('tuser', $data_delete);
        
        if ($res_delete === TRUE) {
            $log_desc = "DELETE_STAFF_ACCOUNT_SUCCESS: " . json_encode($data_delete, JSON_UNESCAPED_UNICODE);
            Fwrite_system_log('DELETE', 'tuser', $nid, $log_desc);
        }

        redirect('do_staff_listview');
    }
}