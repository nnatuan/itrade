<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_bot_client extends CI_Controller
{
    var $m_nid_user_login = '';
    var $m_nid            = ''; 
    var $m_event          = '';
    var $m_button_click   = '';
    var $m_link_page      = '';
    var $m_link_cancel    = '';
    var $m_form_title     = '';
    
    // Thuộc tính tài khoản truy cập & Bản quyền
    var $m_txt_cuserid       = '';
    var $m_txt_cpassword     = '';
    var $m_txt_cfullname     = '';
    var $m_txt_cmt5_account  = '';
    var $m_txt_clicense_key  = '';
    var $m_txt_dlicense_expiry = '';
    var $m_cbof_cbot_status  = '0';

    // Thuộc tính tham số cấu hình EA (Ánh xạ 1:1 từ RSI6_v32_AM.mq5)
    var $m_txt_finitial_lot  = '0.01'; // [cite: 2]
    var $m_txt_flot_multi    = '1.5';  // [cite: 2]
    var $m_txt_nmax_orders   = '26';   // [cite: 3]
    var $m_cbof_ntp_mode     = '0';    // [cite: 5]
    var $m_txt_ftp_pips      = '10.0'; // [cite: 6]
    var $m_txt_ftp_usd       = '50.0'; // [cite: 7]
    var $m_txt_nrsi_period   = '14';   // [cite: 9]
    var $m_cbof_crsi_tf      = 'PERIOD_M1'; // [cite: 9]
    var $m_txt_nmagic        = '522345';     // [cite: 10]
    var $m_cbof_cuse_time_filter = '1';      // [cite: 12]
    var $m_txt_nstart_hour_local = '6';      // [cite: 15]
    var $m_txt_nend_hour_local   = '4';      // [cite: 16]
    var $m_txt_nmin_before_close = '60';     // [cite: 18]
    var $m_txt_nconfirm_from_order = '10';   // [cite: 19]
    var $m_cbof_cpair_close_bat_tat = '0';   // [cite: 20]
    var $m_txt_npair_close_tu_lenh   = '9';  // [cite: 21]
    var $m_txt_fpair_close_so_usd    = '2.0'; // [cite: 22]
    var $m_cbof_cpair_close_chot_dan_ve = '0'; // [cite: 23]
    var $m_txt_fbasket_tp_phan_tram  = '0.0';  // [cite: 25]
    var $m_arr_steps         = array();

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
        $this->load->helper('ap_module');
        $this->config->check_system_login = '1';
        
        // Khởi tạo mảng Step mặc định G1-G25 [cite: 27, 36]
        for($i=1; $i<=25; $i++){
            $this->m_arr_steps["G".$i] = $i * 10; 
        }
    }

    function f_add() {
        $this->m_event = 'add';
        $this->m_nid   = '0';
        $this->m_txt_clicense_key = strtoupper(substr(md5(uniqid(rand(), true)), 0, 16));
        $this->m_txt_dlicense_expiry = date('Y-m-d', strtotime('+1 year'));
        $this->do_process();
    }

    function f_update_add() {
        $this->m_event = 'update_add';
        $this->do_process();
    }

    function f_edit($nid) {
        $this->m_event = 'edit';
        $this->m_nid   = $nid;
        $this->do_process();
    }

    function f_update_edit() {
        $this->m_event = 'update_edit';
        $this->do_process();
    }

    function do_process()
    {
        $this->get_data();
        $this->caculate_data();
        $this->do_business();
    }

    private function get_data()
    {
        $this->m_nid_user_login = Fget_userdata('session_nid_user');
        
        if (isset($_POST['txt_cmt5_account'])) {
            $this->m_txt_cuserid       = trim($_POST['txt_cuserid']);
            $this->m_txt_cpassword     = trim($_POST['txt_cpassword']);
            $this->m_txt_cfullname     = trim($_POST['txt_cfullname']);
            $this->m_txt_cmt5_account  = trim($_POST['txt_cmt5_account']);
            $this->m_txt_clicense_key  = trim($_POST['txt_clicense_key']);
            $this->m_txt_dlicense_expiry = $_POST['txt_dlicense_expiry'];
            $this->m_cbof_cbot_status  = $_POST['cbof_cbot_status'];

            // Đọc các thông số điều khiển EA đầu vào
            $this->m_txt_finitial_lot  = $_POST['txt_finitial_lot'];
            $this->m_txt_flot_multi    = $_POST['txt_flot_multi'];
            $this->m_txt_nmax_orders   = $_POST['txt_nmax_orders'];
            $this->m_cbof_ntp_mode     = $_POST['cbof_ntp_mode'];
            $this->m_txt_ftp_pips      = $_POST['txt_ftp_pips'];
            $this->m_txt_ftp_usd       = $_POST['txt_ftp_usd'];
            $this->m_txt_nrsi_period   = $_POST['txt_nrsi_period'];
            $this->m_cbof_crsi_tf      = $_POST['cbof_crsi_tf'];
            $this->m_txt_nmagic        = $_POST['txt_nmagic'];
            $this->m_cbof_cuse_time_filter = isset($_POST['cbof_cuse_time_filter']) ? '1' : '0';
            $this->m_txt_nstart_hour_local = $_POST['txt_nstart_hour_local'];
            $this->m_txt_nend_hour_local   = $_POST['txt_nend_hour_local'];
            $this->m_txt_nmin_before_close = $_POST['txt_nmin_before_close'];
            $this->m_txt_nconfirm_from_order = $_POST['txt_nconfirm_from_order'];
            $this->m_cbof_cpair_close_bat_tat = isset($_POST['cbof_cpair_close_bat_tat']) ? '1' : '0';
            $this->m_txt_npair_close_tu_lenh   = $_POST['txt_npair_close_tu_lenh'];
            $this->m_txt_fpair_close_so_usd    = $_POST['txt_fpair_close_so_usd'];
            $this->m_cbof_cpair_close_chot_dan_ve = isset($_POST['cbof_cpair_close_chot_dan_ve']) ? '1' : '0';
            $this->m_txt_fbasket_tp_phan_tram  = $_POST['txt_fbasket_tp_phan_tram'];

            // Nạp mảng khoảng cách lưới từ G1 đến G25 [cite: 27, 36]
            for($i=1; $i<=25; $i++){
                if(isset($_POST['step_G'.$i])) {
                    $this->m_arr_steps['G'.$i] = (double)$_POST['step_G'.$i];
                }
            }
        }

        if (isset($_POST['hidden_nid']))    $this->m_nid = $_POST['hidden_nid'];
        if (isset($_POST['hidden_event']))  $this->m_event = $_POST['hidden_event'];
        if (isset($_POST['hidden_button'])) $this->m_button_click = $_POST['hidden_button'];
    }

    private function caculate_data()
    {
        $this->m_link_cancel = base_url() . 'index.php/do_bot_client_listview';
        
        switch ($this->m_event) {
            case 'add':
                $this->m_form_title = "Cấp mới Bản quyền & Cấu hình Tham số Robot";
                $this->m_link_page  = base_url() . 'index.php/do_bot_client/f_update_add';
                $this->m_event      = 'update_add';
                break;
                
            case 'edit':
                $this->m_form_title = "Chỉnh sửa Cấu hình Chiến lược và Bản quyền Bot";
                $this->m_link_page  = base_url() . 'index.php/do_bot_client/f_update_edit';
                
                $client = Obj_get_bot_client_row($this->m_nid);
                if (!empty($client)) {
                    $this->m_txt_cuserid         = $client['cuserid'];
                    $this->m_txt_cfullname       = $client['cfullname'];
                    $this->m_txt_cmt5_account    = $client['cmt5_account'];
                    $this->m_txt_clicense_key    = $client['clicense_key'];
                    $this->m_txt_dlicense_expiry = $client['dlicense_expiry'];
                    $this->m_cbof_cbot_status    = $client['cbot_status'];
                    
                    $settings = Obj_get_bot_settings_row($this->m_nid);
                    if(!empty($settings)) {
                        $this->m_txt_finitial_lot  = $settings['finitial_lot'];
                        $this->m_txt_flot_multi    = $settings['flot_multi'];
                        $this->m_txt_nmax_orders   = $settings['nmax_orders'];
                        $this->m_cbof_ntp_mode     = $settings['ntp_mode'];
                        $this->m_txt_ftp_pips      = $settings['ftp_pips'];
                        $this->m_txt_ftp_usd       = $settings['ftp_usd'];
                        $this->m_txt_nrsi_period   = $settings['nrsi_period'];
                        $this->m_cbof_crsi_tf      = $settings['crsi_tf'];
                        $this->m_txt_nmagic        = $settings['nmagic'];
                        $this->m_cbof_cuse_time_filter = $settings['cuse_time_filter'];
                        $this->m_txt_nstart_hour_local = $settings['nstart_hour_local'];
                        $this->m_txt_nend_hour_local   = $settings['nend_hour_local'];
                        $this->m_txt_nmin_before_close = isset($settings['nmin_before_close']) ? $settings['nmin_before_close'] : '60';
                        $this->m_txt_nconfirm_from_order = isset($settings['nconfirm_from_order']) ? $settings['nconfirm_from_order'] : '10';
                        $this->m_cbof_cpair_close_bat_tat = $settings['cpair_close_bat_tat'];
                        $this->m_txt_npair_close_tu_lenh   = $settings['npair_close_tu_lenh'];
                        $this->m_txt_fpair_close_so_usd    = $settings['fpair_close_so_usd'];
                        $this->m_cbof_cpair_close_chot_dan_ve = isset($settings['cpair_close_chot_dan_ve']) ? $settings['cpair_close_chot_dan_ve'] : '0';
                        $this->m_txt_fbasket_tp_phan_tram  = $settings['fbasket_tp_phan_tram'];
                        
                        if(!empty($settings['cstep_distances'])) {
                            $this->m_arr_steps = json_decode($settings['cstep_distances'], true);
                        }
                    }
                }
                $this->m_event = 'update_edit';
                break;
                
            case 'update_add':
                $this->m_form_title = "Cấp mới Bản quyền & Cấu hình Tham số Robot";
                if ($this->m_button_click == 'btn_submit') {
                    if ($this->insert_data() == TRUE) redirect('do_bot_client_listview');
                }
                break;
                
            case 'update_edit':
                $this->m_form_title = "Chỉnh sửa Cấu hình Chiến lược và Bản quyền Bot";
                if ($this->m_button_click == 'btn_submit') {
                    if ($this->update_data() == TRUE) redirect('do_bot_client_listview');
                }
                break;
        }
    }

    private function do_business()
    {
        $data['event']            = $this->m_event;
        $data['lbl_form_title']   = $this->m_form_title;
        $data['link_page']        = $this->m_link_page;
        $data['link_cancel']      = $this->m_link_cancel;
        $data['m_message']        = $this->m_error_msg;
        $data['nid']              = $this->m_nid;
        $data['menu_active']      = 'bot_trade';

        $data['txt_cuserid']         = $this->m_txt_cuserid;
        $data['txt_cfullname']       = $this->m_txt_cfullname;
        $data['txt_cmt5_account']    = $this->m_txt_cmt5_account;
        $data['txt_clicense_key']    = $this->m_txt_clicense_key;
        $data['txt_dlicense_expiry'] = $this->m_txt_dlicense_expiry;
        $data['cbof_cbot_status']    = $this->m_cbof_cbot_status;

        $data['txt_finitial_lot']    = $this->m_txt_finitial_lot;
        $data['txt_flot_multi']      = $this->m_txt_flot_multi;
        $data['txt_nmax_orders']     = $this->m_txt_nmax_orders;
        $data['cbof_ntp_mode']       = $this->m_cbof_ntp_mode;
        $data['txt_ftp_pips']        = $this->m_txt_ftp_pips;
        $data['txt_ftp_usd']         = $this->m_txt_ftp_usd;
        $data['txt_nrsi_period']     = $this->m_txt_nrsi_period;
        $data['cbof_crsi_tf']        = $this->m_cbof_crsi_tf;
        $data['txt_nmagic']          = $this->m_txt_nmagic;
        $data['cbof_cuse_time_filter'] = $this->m_cbof_cuse_time_filter;
        $data['txt_nstart_hour_local'] = $this->m_txt_nstart_hour_local;
        $data['txt_nend_hour_local']   = $this->m_txt_nend_hour_local;
        $data['txt_nmin_before_close'] = $this->m_txt_nmin_before_close;
        $data['txt_nconfirm_from_order'] = $this->m_txt_nconfirm_from_order;
        $data['cbof_cpair_close_bat_tat'] = $this->m_cbof_cpair_close_bat_tat;
        $data['txt_npair_close_tu_lenh']   = $this->m_txt_npair_close_tu_lenh;
        $data['txt_fpair_close_so_usd']    = $this->m_txt_fpair_close_so_usd;
        $data['cbof_cpair_close_chot_dan_ve'] = $this->m_cbof_cpair_close_chot_dan_ve;
        $data['txt_fbasket_tp_phan_tram']  = $this->m_txt_fbasket_tp_phan_tram;
        $data['arr_steps']           = $this->m_arr_steps;

        $this->load->view('bot_client_view/index.php', $data);
    }

    private function check_valid_not_null()
    {
        if ($this->m_txt_cuserid == '') {
            $this->m_error_msg = "Tên tài khoản truy cập hệ thống không được để trống"; return FALSE;
        }
        if ($this->m_txt_cmt5_account == '') {
            $this->m_error_msg = "Số tài khoản giao dịch MT5 bắt buộc phải nhập"; return FALSE;
        }
        return TRUE;
    }

    private function insert_data()
    {
        if ($this->check_valid_not_null() == FALSE) return FALSE;

        if (fbcheck_exists_key_addnew('tuser', 'cuserid', $this->m_txt_cuserid) == FALSE) {
            $this->m_error_msg = "Tên tài khoản này đã tồn tại trên hệ thống"; return FALSE;
        }
        if (fbcheck_exists_key_addnew('tbot_client', 'cmt5_account', $this->m_txt_cmt5_account) == FALSE) {
            $this->m_error_msg = "Số tài khoản MT5 này đang được cấu hình cho bot khác"; return FALSE;
        }

        $this->db->trans_start();

        $data_user = array(
            'cuserid'      => $this->m_txt_cuserid,
            'cpassword'    => md5($this->m_txt_cpassword != '' ? $this->m_txt_cpassword : '123456b'),
            'cfullname'    => $this->m_txt_cfullname != '' ? $this->m_txt_cfullname : $this->m_txt_cuserid,
            'crole'        => 'patient',
            'cstatus'      => '1',
            'cdel'         => '0',
            'nuser_created'=> $this->m_nid_user_login
        );
        $this->db->insert('tuser', $data_user);
        $n_user_id = $this->db->insert_id();

        $data_client = array(
            'nuser_id'         => $n_user_id,
            'cmt5_account'     => $this->m_txt_cmt5_account,
            'clicense_key'     => $this->m_txt_clicense_key,
            'dlicense_expiry'  => $this->m_txt_dlicense_expiry,
            'cbot_status'      => $this->m_cbof_cbot_status,
            'cdel'             => '0',
            'nuser_created'    => $this->m_nid_user_login
        );
        $this->db->insert('tbot_client', $data_client);
        $n_client_id = $this->db->insert_id();

        $data_settings = array(
            'nclient_id'           => $n_client_id,
            'finitial_lot'         => (double)$this->m_txt_finitial_lot,
            'flot_multi'           => (double)$this->m_txt_flot_multi,
            'nmax_orders'          => (int)$this->m_txt_nmax_orders,
            'ntp_mode'             => (int)$this->m_cbof_ntp_mode,
            'ftp_pips'             => (double)$this->m_txt_ftp_pips,
            'ftp_usd'              => (double)$this->m_txt_ftp_usd,
            'nrsi_period'          => (int)$this->m_txt_nrsi_period,
            'crsi_tf'              => $this->m_cbof_crsi_tf,
            'nmagic'               => (int)$this->m_txt_nmagic,
            'cuse_time_filter'     => $this->m_cbof_cuse_time_filter,
            'nstart_hour_local'    => (int)$this->m_txt_nstart_hour_local,
            'nend_hour_local'      => (int)$this->m_txt_nend_hour_local,
            'nmin_before_close'    => (int)$this->m_txt_nmin_before_close,
            'nconfirm_from_order'  => (int)$this->m_txt_nconfirm_from_order,
            'cpair_close_bat_tat'  => $this->m_cbof_cpair_close_bat_tat,
            'npair_close_tu_lenh'   => (int)$this->m_txt_npair_close_tu_lenh,
            'fpair_close_so_usd'    => (double)$this->m_txt_fpair_close_so_usd,
            'cpair_close_chot_dan_ve'=> $this->m_cbof_cpair_close_chot_dan_ve,
            'fbasket_tp_phan_tram' => (double)$this->m_txt_fbasket_tp_phan_tram,
            'cstep_distances'      => json_encode($this->m_arr_steps)
        );
        $this->db->insert('tbot_settings', $data_settings);

        $this->db->trans_complete();
        
        if ($this->db->trans_status() === TRUE) {
            $arr_full_log = array_merge($data_client, $data_settings);
            Fwrite_system_log('INSERT', 'tbot_client', $n_client_id, "CREATE_BOT_STRATEGY: " . json_encode($arr_full_log));
        }
        return $this->db->trans_status();
    }

    private function update_data()
    {
        if ($this->check_valid_not_null() == FALSE) return FALSE;

        $this->db->trans_start();

        // Cập nhật thông tin client trực tiếp không gắn prefix chuỗi thủ công
        $data_client = array(
            'cmt5_account'     => $this->m_txt_cmt5_account,
            'clicense_key'     => $this->m_txt_clicense_key,
            'dlicense_expiry'  => $this->m_txt_dlicense_expiry,
            'cbot_status'      => $this->m_cbof_cbot_status,
            'nuser_updated'    => $this->m_nid_user_login,
            'ddate_updated'    => date('Y-m-d H:i:s')
        );
        $this->db->where('nid', (int)$this->m_nid)->update('tbot_client', $data_client);

        // Cập nhật thông số EA trực tiếp không gắn prefix chuỗi thủ công
        $data_settings = array(
            'finitial_lot'         => (double)$this->m_txt_finitial_lot,
            'flot_multi'           => (double)$this->m_txt_flot_multi,
            'nmax_orders'          => (int)$this->m_txt_nmax_orders,
            'ntp_mode'             => (int)$this->m_cbof_ntp_mode,
            'ftp_pips'             => (double)$this->m_txt_ftp_pips,
            'ftp_usd'              => (double)$this->m_txt_ftp_usd,
            'nrsi_period'          => (int)$this->m_txt_nrsi_period,
            'crsi_tf'              => $this->m_cbof_crsi_tf,
            'nmagic'               => (int)$this->m_txt_nmagic,
            'cuse_time_filter'     => $this->m_cbof_cuse_time_filter,
            'nstart_hour_local'    => (int)$this->m_txt_nstart_hour_local,
            'nend_hour_local'      => (int)$this->m_txt_nend_hour_local,
            'nmin_before_close'    => (int)$this->m_txt_nmin_before_close,
            'nconfirm_from_order'  => (int)$this->m_txt_nconfirm_from_order,
            'cpair_close_bat_tat'  => $this->m_cbof_cpair_close_bat_tat,
            'npair_close_tu_lenh'   => (int)$this->m_txt_npair_close_tu_lenh,
            'fpair_close_so_usd'    => (double)$this->m_txt_fpair_close_so_usd,
            'cpair_close_chot_dan_ve'=> $this->m_cbof_cpair_close_chot_dan_ve,
            'fbasket_tp_phan_tram' => (double)$this->m_txt_fbasket_tp_phan_tram,
            'cstep_distances'      => json_encode($this->m_arr_steps)
        );
        $this->db->where('nclient_id', (int)$this->m_nid)->update('tbot_settings', $data_settings);

        $this->db->trans_complete();
        
        if ($this->db->trans_status() === TRUE) {
            $arr_full_log = array_merge($data_client, $data_settings);
            Fwrite_system_log('UPDATE', 'tbot_client', $this->m_nid, "UPDATE_BOT_STRATEGY: " . json_encode($arr_full_log));
        }
        return $this->db->trans_status();
    }
}