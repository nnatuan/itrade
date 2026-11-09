<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_system_log extends CI_Controller
{
    var $m_nid_user_login   = ''; 
    var $m_link_page        = ''; 
    var $m_event            = 'system_log';
    var $m_where_clause     = ''; 
    
    var $m_total_row        = 0;  
    var $m_total_page       = 0;  
    var $m_current_page     = 1; 			
    var $m_row_per_page     = 15;  
    
    // Biến lưu trữ cookie bộ lọc tìm kiếm nhật ký
    var $m_txtf_cuserid     = ''; 
    var $m_cbof_caction     = '';
    var $m_txtf_ctable_name = '';

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
        $this->m_link_page = base_url() . 'index.php/do_system_log/';
    }	
    
    private function f_set_cookie($cookie_name, $cookie_value) { 
        return dbset_cookie('cookie_system_log_' . $cookie_name, $cookie_value);
    }
    private function f_get_cookie($cookie_name) { 
        return dbget_cookie('cookie_system_log_' . $cookie_name);
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
                    $this->m_txtf_cuserid     = isset($_POST['txtf_cuserid']) ? trim($_POST['txtf_cuserid']) : '';
                    $this->m_cbof_caction     = isset($_POST['cbof_caction']) ? $_POST['cbof_caction'] : '';
                    $this->m_txtf_ctable_name = isset($_POST['txtf_ctable_name']) ? trim($_POST['txtf_ctable_name']) : '';
                    
                    $this->f_set_cookie('m_txtf_cuserid', $this->m_txtf_cuserid);
                    $this->f_set_cookie('m_cbof_caction', $this->m_cbof_caction);
                    $this->f_set_cookie('m_txtf_ctable_name', $this->m_txtf_ctable_name);
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
        $this->m_txtf_cuserid     = $this->f_get_cookie('m_txtf_cuserid');
        $this->m_cbof_caction     = $this->f_get_cookie('m_cbof_caction');
        $this->m_txtf_ctable_name = $this->f_get_cookie('m_txtf_ctable_name');

        $str_result = ' WHERE 1=1 ';
		/*WHERE 1=1 là một mẹo kỹ thuật (trick) kinh điển của các lập trình viên khi viết code xử lý database động. Về mặt toán học, biểu thức 1=1 luôn luôn đúng (Luôn trả về giá trị TRUE). Vì vậy, khi kẹp WHERE 1=1 vào câu lệnh SQL, nó không làm thay đổi kết quả truy vấn. Nếu không có mốc neo đầu tiên, sẽ phải viết code kiểm tra rất phức tạp:

		.Điều kiện đầu tiên xuất hiện thì phải dùng chữ WHERE.
		.Từ điều kiện thứ hai trở đi mới được dùng chữ AND.
		
		// Code PHP sẽ bị phức tạp và dễ lỗi cú pháp:
		$sql = "SELECT * FROM ea_tbot_client";

		if ($cmt5_account != '') {
			// Phải kiểm tra xem trước đó đã có chữ WHERE chưa?
			$sql .= " WHERE cmt5_account = '12345'";
		}
		if ($cfullname != '') {
			// Lại phải kiểm tra tiếp xem có phải dùng WHERE hay AND?
			$sql .= " AND cfullname LIKE '%Tuan%'"; 
		}		
		Nếu người dùng bỏ trống ô Số tài khoản mà chỉ nhập ô Họ tên, câu lệnh sẽ bị lỗi cú pháp ngay lập tức: SELECT * FROM ea_tbot_client AND cfullname LIKE '%Tuan%' (Lỗi vì thiếu chữ WHERE).
		
		=> Tóm lại: WHERE 1=1 sinh ra không phải để phục vụ cho Database, mà là để giúp code PHP (Controller) của anh ngắn gọn hơn, sạch sẽ hơn, và tuyệt đối không bao giờ bị rủi ro lỗi cú pháp SQL (SQL Syntax Error) khi ghép các bộ lọc tìm kiếm động với nhau.
		*/
        
        // ĐỒNG BỘ PHÂN QUYỀN: Nếu tài khoản là Sale, giới hạn chỉ xem log do mình thực hiện
        $c_user_role = Fget_userdata('session_user_role');
        if($c_user_role == 'sale') {
            $str_result .= ' AND l.nuser_id = ' . (int)$this->m_nid_user_login . ' ';
        }

        if ($this->m_txtf_cuserid != '')
            $str_result .= ' AND u.cuserid like "%' . $this->db->escape_like_str($this->m_txtf_cuserid) . '%" ';
        if ($this->m_cbof_caction != '')
            $str_result .= ' AND l.caction = "' . $this->db->escape_like_str($this->m_cbof_caction) . '" ';
        if ($this->m_txtf_ctable_name != '')
            $str_result .= ' AND l.ctable_name like "%' . $this->db->escape_like_str($this->m_txtf_ctable_name) . '%" ';
            
        $this->m_where_clause = $str_result;	
        $this->m_total_row = Obj_get_system_log_count($this->m_where_clause);		
        
        if ($this->m_row_per_page <= 0) $this->m_row_per_page = 15;			
        $this->m_total_page = Fget_total_page($this->m_row_per_page, $this->m_total_row);
        
        if ($this->m_current_page <= 0) $this->m_current_page = 1;		
        if ($this->m_current_page > $this->m_total_page) $this->m_current_page = $this->m_total_page;
        
        $n_start_row = ($this->m_current_page - 1) * $this->m_row_per_page;
        if($n_start_row < 0) $n_start_row = 0;

        $this->m_obj_data_view = Obj_get_system_log_pagination($this->m_where_clause, $n_start_row, $this->m_row_per_page);
    }
       
    private function do_business()
    {	
        $data['lbl_form_title']      = "Nhật Ký Bảo Mật Hệ Thống (System Security Log)";
        $data['link_page']           = $this->m_link_page;
        $data['btn_choose']          = "Chọn";
        $data['lbl_rows_per_page']   = "Số dòng hiển thị";
		
        $data['txt_row_per_page']    = $this->m_row_per_page;
        $data['txt_current_page']    = $this->m_current_page;
        $data['txt_total_page']      = $this->m_total_page;			
                
        $data['txtf_cuserid']        = $this->m_txtf_cuserid;
        $data['cbof_caction']        = $this->m_cbof_caction;
        $data['txtf_ctable_name']    = $this->m_txtf_ctable_name;
        
        $data['menu_active']         = 'system_log';
        $data['data_view']           = $this->m_obj_data_view; 
        $data['event']               = $this->m_event; 
		
        $this->load->view('system_log_view/index.php', $data);
    }
}