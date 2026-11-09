<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_login_client extends CI_Controller
{
    var $m_link_page = '';

    function __construct()
    {
        parent::__construct();
        session_start();
        $this->load->database();
        $this->load->helper('ap_db');
        $this->load->helper('ap_function');
        $this->load->helper('ap_html');
        
        // Trang đăng nhập phải thiết lập là 2 để vượt qua vòng gác của Hook
        $this->config->check_system_login = '2'; 
        $this->m_link_page = base_url() . 'index.php/do_login_client';
    }

    function index()
    {
        $data['error_message'] = '';
        $data['link_page'] = $this->m_link_page;

        // Nếu đã có Session chuẩn của Hook -> Đẩy thẳng vào Dashboard
        if (Fget_userdata('session_nid_user') != '' && Fget_userdata('session_crole') == 'patient') {
            redirect('do_client_dashboard');
        }

        if (isset($_POST['hidden_button']) && $_POST['hidden_button'] == 'btn_login') {
            $str_user = isset($_POST['txt_user_name']) ? trim($_POST['txt_user_name']) : '';
            $str_pass = isset($_POST['txt_password']) ? trim($_POST['txt_password']) : '';

            if ($str_user != '' && $str_pass != '') {
                
                // ĐỒNG BỘ LOGIC: Join tuser và tbot_client
                $this->db->select('u.nid AS user_nid, u.cuserid, u.cfullname, u.crole, b.nid AS client_nid, b.cmt5_account');
                $this->db->from(Fget_ap_table('tuser').' as u');
                $this->db->join(Fget_ap_table('tbot_client').' as b', 'u.nid = b.nuser_id', 'inner');
                
                $this->db->where('u.cuserid', $str_user);
                $this->db->where('u.cpassword', md5($str_pass)); 
                $this->db->where('u.crole', 'patient'); 
                $this->db->where('u.cdel', '0');
                $this->db->where('b.cdel', '0');
                
                $obj_auth_query = $this->db->get()->row_array();

                if (!empty($obj_auth_query)) {
                    // 1. THIẾT LẬP SESSION CHUẨN ĐỂ VƯỢT QUA HOOK BẢO MẬT HỆ THỐNG
                    $_SESSION['session_nid_user']       = $obj_auth_query['user_nid'];
                    $_SESSION['session_user_name']      = $obj_auth_query['cuserid'];
                    $_SESSION['session_user_full_name'] = $obj_auth_query['cfullname'];
                    $_SESSION['session_crole']          = $obj_auth_query['crole']; // Giá trị 'patient'
                    
                    // 2. THIẾT LẬP SESSION PHỤ DÀNH CHO TRUY VẤN BOT DASHBOARD
                    $_SESSION['session_client_nid']     = $obj_auth_query['client_nid']; // ID của bảng tbot_client
                    $_SESSION['session_client_mt5']     = $obj_auth_query['cmt5_account'];
                    
                    redirect('do_client_dashboard');
                } else {
                    $data['error_message'] = 'Tên đăng nhập Bot hoặc Mật khẩu không chính xác!';
                }
            } else {
                $data['error_message'] = 'Vui lòng nhập đầy đủ thông tin đăng nhập!';
            }
        }
        
        $data['txt_user_name'] = isset($_POST['txt_user_name']) ? $_POST['txt_user_name'] : '';
        $this->load->view('login_client_view/index', $data);
    }

    function f_logout()
    {
        // Xóa sạch cả cụm Session của Hook và của Client
        unset($_SESSION['session_nid_user']);
        unset($_SESSION['session_user_name']);
        unset($_SESSION['session_user_full_name']);
        unset($_SESSION['session_crole']);
        unset($_SESSION['session_client_nid']);
        unset($_SESSION['session_client_mt5']);
        
        redirect('do_login_client');
    }
}