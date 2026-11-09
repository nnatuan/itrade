<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_staff extends CI_Controller
{
    var $m_nid_user_login = '';
    var $m_nid            = ''; 
    var $m_event          = '';
    var $m_button_click   = '';
    var $m_link_page      = '';
    var $m_link_cancel    = '';
    var $m_form_title     = '';
    
    // Các trường dữ liệu tài khoản tuser nội bộ
    var $m_txt_cuserid    = '';
    var $m_txt_cpassword  = '';
    var $m_txt_cfullname  = '';
    var $m_txt_cemail     = '';
    var $m_txt_chandphone = '';
    var $m_txt_cgender    = 'Nam';
    var $m_txt_dbirthday  = '';
    
    // ĐỒNG BỘ TẠI ĐÂY: Thay đổi role mặc định ban đầu từ doctor sang sale
    var $m_cbof_crole     = 'sale';
    var $m_cbof_cstatus   = '1';
    
    var $m_error_msg      = '';

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
        
        $this->m_link_page   = base_url() . 'index.php/do_staff/do_process';
        $this->m_link_cancel = base_url() . 'index.php/do_staff_listview';
		
		// ĐỒNG BỘ BẢO MẬT: Nếu không phải admin thì lập tức quay về trang chủ
        $c_user_role = Fget_userdata('session_user_role');
        if ($c_user_role != 'admin') {
            redirect(base_url() . 'index.php/do_home');
        }
    }

    function index() {
        $this->f_add();
    }

    function f_add() {
        $this->m_event      = 'add';
        
        // ĐỒNG BỘ TẠI ĐÂY: Sửa tiêu đề form thêm mới nhân sự
        $this->m_form_title = 'Đăng ký Tài khoản Sale / Đại lý / Quản trị viên mới';
        $this->do_process();
    }

    function f_edit($nid) {
        $this->m_event      = 'edit';
        $this->m_nid        = $nid;
        $this->m_form_title = 'Chỉnh sửa Hồ sơ thông tin Nhân sự';
        $this->do_process();
    }

    function do_process()
    {
        $this->get_data();
        if ($this->m_button_click == 'btn_submit') {
            if ($this->check_data() == '1') {
                $this->do_business();
                return;
            }
        } else {
            $this->load_data();
        }
        $this->show_view();
    }

    private function get_data()
    {
        $this->m_nid_user_login = Fget_userdata('session_nid_user');
        $this->m_button_click   = isset($_POST['hidden_button']) ? $_POST['hidden_button'] : '';
        $this->m_event          = isset($_POST['hidden_event']) ? $_POST['hidden_event'] : $this->m_event;
        $this->m_nid            = isset($_POST['hidden_nid']) ? $_POST['hidden_nid'] : $this->m_nid;

        if ($this->m_button_click == 'btn_submit') {
            $this->m_txt_cuserid    = trim($_POST['txt_cuserid']);
            $this->m_txt_cpassword  = trim($_POST['txt_cpassword']);
            $this->m_txt_cfullname  = trim($_POST['txt_cfullname']);
            $this->m_txt_cemail     = trim($_POST['txt_cemail']);
            $this->m_txt_chandphone = trim($_POST['txt_chandphone']);
            $this->m_txt_cgender    = $_POST['cbof_cgender'];
            $this->m_txt_dbirthday  = $_POST['txt_dbirthday'];
            $this->m_cbof_crole     = $_POST['cbof_crole'];
            $this->m_cbof_cstatus   = $_POST['cbof_cstatus'];
        }
    }

    private function check_data()
    {
        if ($this->m_txt_cuserid == '') {
            $this->m_error_msg = 'Tên đăng nhập hệ thống không được để trống.'; return '0';
        }
        if ($this->m_event == 'add' && $this->m_txt_cpassword == '') {
            $this->m_error_msg = 'Vui lòng thiết lập mật khẩu khởi tạo cho tài khoản.'; return '0';
        }
        if ($this->m_txt_cfullname == '') {
            $this->m_error_msg = 'Vui lòng điền họ tên Nhân sự.'; return '0';
        }
        
        if ($this->m_event == 'add') {
            if (fbcheck_exists_key_addnew('tuser', 'cuserid', $this->m_txt_cuserid) == FALSE) {
                $this->m_error_msg = "Tên đăng nhập này đã tồn tại trên hệ thống.";
                return '0';
            }
        }
        return '1';
    }

    private function load_data()
    {
        if ($this->m_event == 'edit' && $this->m_nid != '') {
            $row = Obj_get_staff_row($this->m_nid);
            if (!empty($row)) {
                $this->m_txt_cuserid    = $row['cuserid'];
                $this->m_txt_cfullname  = $row['cfullname'];
                $this->m_txt_cemail     = $row['cemail'];
                $this->m_txt_chandphone = $row['chandphone'];
                $this->m_txt_cgender    = $row['cgender'];
                $this->m_txt_dbirthday  = $row['dbirthday'];
                $this->m_cbof_crole     = $row['crole'];
                $this->m_cbof_cstatus   = $row['cstatus'];
            }
        }
    }

    private function do_business()
    {
        $data_staff = array(
            'cuserid'    => $this->m_txt_cuserid,
            'cfullname'  => $this->m_txt_cfullname,
            'cemail'     => $this->m_txt_cemail,
            'chandphone' => $this->m_txt_chandphone,
            'cgender'    => $this->m_txt_cgender,
            'dbirthday'  => !empty($this->m_txt_dbirthday) ? $this->m_txt_dbirthday : NULL,
            'crole'      => $this->m_cbof_crole,
            'cstatus'    => $this->m_cbof_cstatus
        );

        if ($this->m_event == 'add') {
            $data_staff['cpassword']    = md5($this->m_txt_cpassword);
            
            // ĐỒNG BỘ TẠI ĐÂY: Tạo tài khoản nhân viên Sale thì nparent_id bằng 0 (Họ thuộc cấp cao không có ai quản lý trên)
            $data_staff['nparent_id']   = 0;
            
            $data_staff['cdel']         = '0';
            $data_staff['nuser_created'] = $this->m_nid_user_login;
            
            $res_action = $this->db->insert('tuser', $data_staff);
            $n_new_id = $this->db->insert_id();
            
            if($res_action === TRUE) {
                unset($data_staff['cpassword']);
                $log_desc = "INSERT_STAFF_SUCCESS: " . json_encode($data_staff, JSON_UNESCAPED_UNICODE);
                Fwrite_system_log('INSERT', 'tuser', $n_new_id, $log_desc);
            }
        } 
        elseif ($this->m_event == 'edit') {
            if ($this->m_txt_cpassword != '') {
                $data_staff['cpassword'] = md5($this->m_txt_cpassword);
            }
            $data_staff['nuser_updated'] = $this->m_nid_user_login;
            $data_staff['ddate_updated'] = date('Y-m-d H:i:s');
            
            $res_action = $this->db->where('nid', (int)$this->m_nid)->update('tuser', $data_staff);
            
            if($res_action === TRUE) {
                unset($data_staff['cpassword']);
                $log_desc = "UPDATE_STAFF_SUCCESS: " . json_encode($data_staff, JSON_UNESCAPED_UNICODE);
                Fwrite_system_log('UPDATE', 'tuser', $this->m_nid, $log_desc);
            }
        }

        redirect($this->m_link_cancel);
    }

    private function show_view()
    {
        $data['lbl_form_title']  = $this->m_form_title;
        $data['link_page']       = $this->m_link_page;
        $data['link_cancel']     = $this->m_link_cancel;
        $data['m_message']       = $this->m_error_msg;
        $data['nid']             = $this->m_nid;
        $data['event']           = $this->m_event;

        $data['txt_cuserid']     = $this->m_txt_cuserid;
        $data['txt_cfullname']   = $this->m_txt_cfullname;
        $data['txt_cemail']      = $this->m_txt_cemail;
        $data['txt_chandphone']  = $this->m_txt_chandphone;
        $data['cbof_cgender']    = $this->m_txt_cgender;
        $data['txt_dbirthday']   = $this->m_txt_dbirthday;
        $data['cbof_crole']      = $this->m_cbof_crole;
        $data['cbof_cstatus']    = $this->m_cbof_cstatus;

        $data['menu_active']     = 'staff';

        $this->load->view('staff_view/index.php', $data);
    }
}