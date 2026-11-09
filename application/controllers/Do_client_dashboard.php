<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_client_dashboard extends CI_Controller 
{	
    var $m_client_nid = '';
    var $m_link_page = '';

    function __construct()
    { 
        parent::__construct();  
        session_start();
        $this->load->database();
        $this->load->helper('ap_db');
        $this->load->helper('ap_function');
        $this->load->helper('ap_html');
        
        // Sửa thành '1' để bật tính năng bảo vệ Controller bằng Hook chuẩn của hệ thống
        $this->config->check_system_login = '1'; 
        
        $this->m_link_page = base_url().'index.php/do_client_dashboard';
    } 
    
    function index()
    {
        // Nhờ check_system_login = '1', ta không cần viết lệnh if check session ở đây nữa.
        // Hệ thống Hook đã tự chặn và đẩy ra ngoài nếu chưa đăng nhập.

        $this->m_client_nid = Fget_userdata('session_client_nid'); // ID của bảng tbot_client
        $event = isset($_POST['hidden_button']) ? $_POST['hidden_button'] : '';
        $data['m_message'] = '';
        $data['msg_type']  = 'danger';

        // 1. XỬ LÝ LƯU TRẠNG THÁI KHẨN CẤP
        if ($event == 'btn_save_status') {
            $new_status = isset($_POST['cbof_cbot_status']) ? trim($_POST['cbof_cbot_status']) : '0';
            
            $this->db->where('nid', (int)$this->m_client_nid);
            $this->db->update('tbot_client', array(
                'cbot_status'   => $new_status,
                'nuser_updated' => Fget_userdata('session_nid_user'), // Lấy ID user từ Hook
                'ddate_updated' => date('Y-m-d H:i:s')
            ));
            
            $data['m_message'] = "Đã cập nhật trạng thái hoạt động của Bot thành công! Hệ thống MT5 sẽ đồng bộ sau tối đa 60 giây.";
            $data['msg_type']  = "success";
        }

        // 2. ĐỌC DỮ LIỆU ĐỔ RA VIEW (JOIN 3 BẢNG tbot_client, tbot_settings, tuser)
        $this->db->select('b.*, s.*, u.cuserid, u.cfullname');
        $this->db->from('tbot_client as b');
        $this->db->join('tbot_settings as s', 'b.nid = s.nclient_id', 'inner');
        $this->db->join('tuser as u', 'u.nid = b.nuser_id', 'inner');
        $this->db->where('b.nid', (int)$this->m_client_nid);
        $this->db->where('b.cdel', '0');
        
        $bot_info = $this->db->get()->row_array();
        
        // 3. Giải mã chuỗi JSON Lưới G1-G25
        $data['arr_steps'] = array();
        if (!empty($bot_info) && $bot_info['cstep_distances'] != '') {
            $data['arr_steps'] = json_decode($bot_info['cstep_distances'], true);
        }

        $data['bot_info']  = $bot_info;
        $data['link_page'] = $this->m_link_page;
        
        // Render View
		$this->load->view('client_dashboard_view/index', $data);
    }
}