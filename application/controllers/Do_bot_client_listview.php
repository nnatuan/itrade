<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_bot_client_listview extends CI_Controller
{ 	 
    var $m_nid_user_login   = ''; 
    var $m_link_page        = ''; 
    var $m_event            = 'view'; 
    var $m_where_clause     = ''; 
    
    var $m_total_row        = 0;  
    var $m_total_page       = 0;  
    var $m_current_page     = 1; 			
    var $m_row_per_page     = 10;  
    
    var $m_txtf_cmt5_account = ''; 
    var $m_txtf_cfullname    = ''; 
    var $m_cbof_cbot_status  = '';

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
        $this->m_link_page = base_url() . 'index.php/do_bot_client_listview/';
    }	
    
    private function f_set_cookie($cookie_name, $cookie_value) { 
        return dbset_cookie('cookie_bot_listview_' . $cookie_name, $cookie_value);
    }
    private function f_get_cookie($cookie_name) { 
        return dbget_cookie('cookie_bot_listview_' . $cookie_name);
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
                    $this->m_cbof_cbot_status  = isset($_POST['cbof_cbot_status']) ? $_POST['cbof_cbot_status'] : '';
                    
                    $this->f_set_cookie('m_txtf_cmt5_account', $this->m_txtf_cmt5_account);
                    $this->f_set_cookie('m_txtf_cfullname', $this->m_txtf_cfullname);
                    $this->f_set_cookie('m_cbof_cbot_status', $this->m_cbof_cbot_status);
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
                    redirect(base_url() . 'index.php/do_bot_client/f_add');
                    break;	
            }
        }
    } 
    
    private function caculate_data()
    {	   
        $this->m_txtf_cmt5_account = $this->f_get_cookie('m_txtf_cmt5_account');
        $this->m_txtf_cfullname    = $this->f_get_cookie('m_txtf_cfullname');
        $this->m_cbof_cbot_status  = $this->f_get_cookie('m_cbof_cbot_status');
        
        $str_result = ' WHERE c.cdel = "0" ';
        
        // ĐỒNG BỘ PHÂN QUYỀN: Kiểm tra vai trò của User đăng nhập hệ thống
        $c_user_role = Fget_userdata('session_user_role');
        if($c_user_role == 'sale') {
            // Nếu là Sale, chặn chết dữ liệu chỉ cho hiển thị khách thuộc quyền mình quản lý
            $str_result .= ' AND u.nparent_id = ' . (int)$this->m_nid_user_login . ' ';
        }

        if ($this->m_txtf_cmt5_account != '')
            $str_result .= ' AND c.cmt5_account like "%' . $this->db->escape_like_str($this->m_txtf_cmt5_account) . '%" ';
        if ($this->m_txtf_cfullname != '')
            $str_result .= ' AND u.cfullname like "%' . $this->db->escape_like_str($this->m_txtf_cfullname) . '%" ';
        if ($this->m_cbof_cbot_status != '')
            $str_result .= ' AND c.cbot_status = "' . $this->db->escape_like_str($this->m_cbof_cbot_status) . '" ';
            
        $this->m_where_clause = $str_result;	
        $this->m_total_row = Obj_get_bot_client_count($this->m_where_clause);		
        
        if ($this->m_row_per_page <= 0) $this->m_row_per_page = 10;			
        $this->m_total_page = Fget_total_page($this->m_row_per_page, $this->m_total_row);
        
        if ($this->m_current_page <= 0) $this->m_current_page = 1;		
        if ($this->m_current_page > $this->m_total_page) $this->m_current_page = $this->m_total_page;
        
        $n_start_row = ($this->m_current_page - 1) * $this->m_row_per_page;
        if($n_start_row < 0) $n_start_row = 0;

        $this->m_obj_data_view = Obj_get_bot_client_pagination($this->m_where_clause, $n_start_row, $this->m_row_per_page);
    }
       
    private function do_business()
    {	
        $data['lbl_form_title']     = "Hệ thống quản lý Giấy phép License EA & EA Trực tuyến";
        $data['link_page']          = $this->m_link_page;
        $data['btn_choose']         = "Chọn";
        $data['lbl_rows_per_page']  = "Số dòng hiển thị";
		
        $data['txt_row_per_page']   = $this->m_row_per_page;
        $data['txt_current_page']   = $this->m_current_page;
        $data['txt_total_page']     = $this->m_total_page;			
                
        $data['txtf_cmt5_account']  = $this->m_txtf_cmt5_account;
        $data['txtf_cfullname']     = $this->m_txtf_cfullname;
        $data['cbof_cbot_status']    = $this->m_cbof_cbot_status;
        
        $data['menu_active']        = 'bot_trade';
        $data['data_view']          = $this->m_obj_data_view; 
		$data['event']              = $this->m_event; 
		
        $this->load->view('bot_client_view/index.php', $data);
    }
    
    function f_delete($nid) {
        // ANTI-BYPASS: Bảo vệ an toàn dữ liệu, ngăn chặn Sale gọi xóa nhầm sang khách hàng của Sale khác
        $c_user_role = Fget_userdata('session_user_role');
        if($c_user_role == 'sale') {
            $check_owner = $this->db->select('c.nid')
                                    ->from('tbot_client c')
                                    ->join('tuser u', 'c.nuser_id = u.nid')
                                    ->where('c.nid', (int)$nid)
                                    ->where('u.nparent_id', (int)$this->m_nid_user_login)
                                    ->get()->row_array();
            if(empty($check_owner)) {
                echo "<script>alert('Lỗi bảo mật: Bạn không có quyền xóa tài khoản khách hàng này!'); window.history.back();</script>";
                return;
            }
        }

        $data_delete = array(
            'cdel'          => '1',
            'nuser_updated' => Fget_userdata('session_nid_user'),
            'ddate_updated' => date('Y-m-d H:i:s')
        );

        $res_delete = $this->db->where('nid', (int)$nid)->update('tbot_client', $data_delete);
        if ($res_delete === TRUE) {
            $log_desc = "DELETE_BOT_CLIENT_SUCCESS: " . json_encode($data_delete, JSON_UNESCAPED_UNICODE);
            Fwrite_system_log('DELETE', 'tbot_client', $nid, $log_desc);
        }
        redirect('do_bot_client_listview');
    }
	
	// 1. MÀN HÌNH DANH SÁCH TÀI KHOẢN ĐÃ XÓA (cdel = '1')
	function trash()
	{
		$data['event']        = 'trash';
		$data['menu_active']  = 'bot_trade'; 
		$data['lbl_title']    = "Thùng rác - Danh sách tài khoản Bot đã xóa";
		$data['link_back']    = base_url() . 'index.php/do_bot_client_listview';
		$data['link_action']  = base_url() . 'index.php/do_bot_client_listview/delete_permanently/';

		// Lọc lấy danh sách tài khoản đã bị đánh dấu xóa (cdel = '1')
		$this->db->select('c.nid, c.cmt5_account, c.cbroker_name, c.cbot_version, c.clicense_key, c.ddate_updated, u.cuserid, u.cfullname');
		$this->db->from('ea_tbot_client c');
		$this->db->join('ea_tuser u', 'u.nid = c.nuser_id', 'left');
		$this->db->where('c.cdel', '1');
		$this->db->order_by('c.nid', 'DESC');
		$data['list_trash'] = $this->db->get()->result_array();

		$this->load->view('bot_client_view/index.php', $data);
	}

	// 2. XỬ LÝ XÓA VĨNH VIỄN KHỎI CƠ SỞ DỮ LIỆU
	function delete_permanently($nid = 0)
	{
		$nid = (int)$nid;
		if ($nid <= 0) {
			redirect(base_url() . 'index.php/do_bot_client_listview/trash');
			return;
		}

		// Lấy nuser_id liên kết trước khi xóa bản ghi
		$client = $this->db->select('nuser_id, cmt5_account')->where('nid', $nid)->get('ea_tbot_client')->row_array();

		if (!empty($client)) {
			$this->db->trans_start();

			// Xóa cài đặt tham số bot liên kết
			$this->db->where('nclient_id', $nid)->delete('ea_tbot_settings');

			// Xóa lịch sử license liên kết
			$this->db->where('nclient_id', $nid)->delete('ea_tbot_license_history');

			// Xóa tài khoản client trong bảng ea_tbot_client
			$this->db->where('nid', $nid)->delete('ea_tbot_client');

			// Xóa luôn tài khoản đăng nhập bên bảng ea_tuser nếu có
			if (!empty($client['nuser_id'])) {
				$this->db->where('nid', (int)$client['nuser_id'])->delete('ea_tuser');
			}

			$this->db->trans_complete();

			if ($this->db->trans_status() === TRUE) {
				Fwrite_system_log('DELETE_PERMANENT', 'ea_tbot_client', $nid, "Xóa vĩnh viễn tài khoản MT5: " . $client['cmt5_account']);
			}
		}

		redirect(base_url() . 'index.php/do_bot_client_listview/trash');
	}
}