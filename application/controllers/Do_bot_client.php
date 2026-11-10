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
    var $m_txt_cmt5_password = '';
    var $m_txt_cbroker_name  = ''; 
    var $m_cbof_cbot_version = 'RSI6_v33'; // BỔ SUNG: Phiên bản Bot
    var $m_cbof_callow_grid_near_end = '0'; // BỔ SUNG: Cho phép nhồi lệnh sát phiên
    var $m_txt_clicense_key  = '';
    var $m_txt_dlicense_expiry = '';
    var $m_cbof_cbot_status  = '0';

    // Thuộc tính tham số cấu hình EA (Ánh xạ 1:1 từ RSI6_v32_AM.mq5)
    var $m_txt_finitial_lot  = '0.01';
    var $m_txt_flot_multi    = '1.5'; 
    var $m_txt_nmax_orders   = '26';  
    var $m_cbof_ntp_mode     = '0';   
    var $m_txt_ftp_pips      = '10.0';
    var $m_txt_ftp_usd       = '50.0';
    var $m_txt_nrsi_period   = '14';  
    var $m_cbof_crsi_tf      = 'PERIOD_M1';
    var $m_txt_nmagic        = '522345';    
    var $m_cbof_cuse_time_filter = '1';     
    var $m_cbof_csession_asia    = '1'; // Sydney - Tokyo (05:00 - 14:00)
    var $m_cbof_csession_london  = '1'; // London (14:00 - 23:00)
    var $m_cbof_csession_ny      = '1'; // New York (19:00 - 04:00)
    var $m_txt_ctime_start_1     = '';  // Trade Hour 1 Start (HH:mm)
    var $m_txt_ctime_end_1       = '';  // Trade Hour 1 End (HH:mm)
    var $m_txt_ctime_start_2     = '';  // Trade Hour 2 Start (HH:mm)
    var $m_txt_ctime_end_2       = '';  // Trade Hour 2 End (HH:mm)
    var $m_txt_ctime_start_3     = '';  // Trade Hour 3 Start (HH:mm)
    var $m_txt_ctime_end_3       = '';  // Trade Hour 3 End (HH:mm)
    var $m_txt_nstart_hour_local = '6';     
    var $m_txt_nend_hour_local   = '4';     
    var $m_txt_nmin_before_close = '60';    
    var $m_txt_nconfirm_from_order = '10';  
    var $m_cbof_cpair_close_bat_tat = '0';  
    var $m_txt_npair_close_tu_lenh   = '9'; 
    var $m_txt_fpair_close_so_usd    = '2.0';
    var $m_cbof_cpair_close_chot_dan_ve = '0';
    var $m_txt_fbasket_tp_phan_tram  = '0.0'; 
    var $m_arr_steps         = array();

    // Thuộc tính cấu hình chuyên biệt cho V38 (Onefxhub_v38.38 Safety R3)
    var $m_cbat_cong_spread_tp           = '1';
    var $m_fkhoang_doi_sl                = '25.0';
    var $m_fso_pip_doi_sl                = '15.0';
    var $m_fkhoang_trailing_sl           = '10.0';
    var $m_cbat_cat_dd                   = '0';
    var $m_fcat_dd_phan_tram             = '0.0';
    var $m_ndd_hedge_magic               = '888838';
    var $m_nserver_gmt                   = '3';
    var $m_nlocal_gmt                    = '7';
    var $m_cenable_asia                  = '1';
    var $m_nasia_start_hour              = '5';
    var $m_nasia_start_minute            = '0';
    var $m_nasia_end_hour                = '14';
    var $m_nasia_end_minute              = '0';
    var $m_cenable_europe                = '1';
    var $m_neurope_start_hour            = '14';
    var $m_neurope_start_minute          = '0';
    var $m_neurope_end_hour              = '23';
    var $m_neurope_end_minute            = '0';
    var $m_cenable_us                    = '1';
    var $m_nus_start_hour                = '19';
    var $m_nus_start_minute              = '0';
    var $m_nus_end_hour                  = '4';
    var $m_nus_end_minute                = '0';
    var $m_nclose_protect_max_orders     = '8';
    var $m_cclose_protect_use_loss_pct   = '1';
    var $m_fclose_protect_loss_pct       = '0.3';
    var $m_cenable_double_confirm        = '1';
    var $m_nentry_strategy               = '0';
    var $m_nglobal_orders_per_group      = '6';
    var $m_fglobal_breakout_distance_usd = '3.0';
    var $m_cglobal_local_distances       = '4,4,8,8,12,12,16,16,20,20,24,24,28,28,32,32,36,36,40,40,44,44,48,48,52';
    var $m_npairclose_mode               = '1';
    var $m_noriginal_pairclose_start_order = '20';
    var $m_nrecursive_rebase_target_level = '15';

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
        
        for($i=1; $i<=25; $i++){
            $this->m_arr_steps["G".$i] = $i * 10;
        }

        $this->m_link_page   = base_url() . 'index.php/do_bot_client/do_process';
        $this->m_link_cancel = base_url() . 'index.php/do_bot_client_listview';
    }

    function index() { $this->f_add(); }

    function f_add() {
        $this->m_event      = 'add';
        $this->m_nid        = '0';
        $this->m_form_title = "Cấp mới Bản quyền & Cấu hình Tham số Robot";
        $this->m_txt_clicense_key = strtoupper(substr(md5(uniqid(rand(), true)), 0, 16));
        $this->m_txt_dlicense_expiry = date('Y-m-d', strtotime('+1 year'));
        $this->do_process();
    }

    function f_edit($nid) {
        $this->m_event      = 'edit';
        $this->m_nid        = $nid;
        $this->m_form_title = "Chỉnh sửa Cấu hình Chiến lược và Bản quyền Bot";
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
            $this->m_txt_cuserid            = trim($_POST['txt_cuserid']);
            $this->m_txt_cpassword          = trim($_POST['txt_cpassword']);
            $this->m_txt_cfullname          = trim($_POST['txt_cfullname']);
            $this->m_txt_cmt5_account       = trim($_POST['txt_cmt5_account']);
            $this->m_txt_cmt5_password      = trim($_POST['txt_cmt5_password']);
            $this->m_txt_cbroker_name       = trim($_POST['txt_cbroker_name']);
            
            // BỔ SUNG BẮT DỮ LIỆU TỪ FORM SUBMIT
            $this->m_cbof_cbot_version          = isset($_POST['cbof_cbot_version']) ? $_POST['cbof_cbot_version'] : 'RSI6_v33';
            $this->m_cbof_callow_grid_near_end  = isset($_POST['cbof_callow_grid_near_end']) ? '1' : '0';
            
            $this->m_txt_clicense_key       = trim($_POST['txt_clicense_key']);
            $this->m_txt_dlicense_expiry    = $_POST['txt_dlicense_expiry'];
            $this->m_cbof_cbot_status       = $_POST['cbof_cbot_status'];

            $this->m_txt_finitial_lot       = $_POST['txt_finitial_lot'];
            $this->m_txt_flot_multi         = $_POST['txt_flot_multi'];
            $this->m_txt_nmax_orders        = $_POST['txt_nmax_orders'];
            $this->m_cbof_ntp_mode          = $_POST['cbof_ntp_mode'];
            $this->m_txt_ftp_pips           = $_POST['txt_ftp_pips'];
            $this->m_txt_ftp_usd            = $_POST['txt_ftp_usd'];
            $this->m_txt_nrsi_period        = $_POST['txt_nrsi_period'];
            $this->m_cbof_crsi_tf           = $_POST['cbof_crsi_tf'];
            $this->m_txt_nmagic             = $_POST['txt_nmagic'];
            $this->m_cbof_cuse_time_filter  = isset($_POST['cbof_cuse_time_filter']) ? '1' : '0';
            $this->m_cbof_csession_asia    = isset($_POST['cbof_csession_asia']) ? '1' : '0';
            $this->m_cbof_csession_london  = isset($_POST['cbof_csession_london']) ? '1' : '0';
            $this->m_cbof_csession_ny      = isset($_POST['cbof_csession_ny']) ? '1' : '0';
            $this->m_txt_ctime_start_1     = isset($_POST['txt_ctime_start_1']) ? trim($_POST['txt_ctime_start_1']) : '';
            $this->m_txt_ctime_end_1       = isset($_POST['txt_ctime_end_1']) ? trim($_POST['txt_ctime_end_1']) : '';
            $this->m_txt_ctime_start_2     = isset($_POST['txt_ctime_start_2']) ? trim($_POST['txt_ctime_start_2']) : '';
            $this->m_txt_ctime_end_2       = isset($_POST['txt_ctime_end_2']) ? trim($_POST['txt_ctime_end_2']) : '';
            $this->m_txt_ctime_start_3     = isset($_POST['txt_ctime_start_3']) ? trim($_POST['txt_ctime_start_3']) : '';
            $this->m_txt_ctime_end_3       = isset($_POST['txt_ctime_end_3']) ? trim($_POST['txt_ctime_end_3']) : '';
            $this->m_txt_nstart_hour_local  = isset($_POST['txt_nstart_hour_local']) ? $_POST['txt_nstart_hour_local'] : '6';
            $this->m_txt_nend_hour_local    = isset($_POST['txt_nend_hour_local']) ? $_POST['txt_nend_hour_local'] : '4';
            $this->m_txt_nmin_before_close  = $_POST['txt_nmin_before_close'];
            $this->m_txt_nconfirm_from_order = $_POST['txt_nconfirm_from_order'];
            $this->m_cbof_cpair_close_bat_tat = isset($_POST['cbof_cpair_close_bat_tat']) ? '1' : '0';
            $this->m_txt_npair_close_tu_lenh   = $_POST['txt_npair_close_tu_lenh'];
            $this->m_txt_fpair_close_so_usd    = $_POST['txt_fpair_close_so_usd'];
            $this->m_cbof_cpair_close_chot_dan_ve = isset($_POST['cbof_cpair_close_chot_dan_ve']) ? '1' : '0';
            $this->m_txt_fbasket_tp_phan_tram  = $_POST['txt_fbasket_tp_phan_tram'];

            // BỔ SUNG BẮT DỮ LIỆU CẤU HÌNH V38
            $this->m_cbat_cong_spread_tp           = isset($_POST['cbat_cong_spread_tp']) ? '1' : '0';
            $this->m_fkhoang_doi_sl                = isset($_POST['fkhoang_doi_sl']) ? $_POST['fkhoang_doi_sl'] : $this->m_fkhoang_doi_sl;
            $this->m_fso_pip_doi_sl                = isset($_POST['fso_pip_doi_sl']) ? $_POST['fso_pip_doi_sl'] : $this->m_fso_pip_doi_sl;
            $this->m_fkhoang_trailing_sl           = isset($_POST['fkhoang_trailing_sl']) ? $_POST['fkhoang_trailing_sl'] : $this->m_fkhoang_trailing_sl;
            $this->m_cbat_cat_dd                   = isset($_POST['cbat_cat_dd']) ? '1' : '0';
            $this->m_fcat_dd_phan_tram             = isset($_POST['fcat_dd_phan_tram']) ? $_POST['fcat_dd_phan_tram'] : $this->m_fcat_dd_phan_tram;
            $this->m_ndd_hedge_magic               = isset($_POST['ndd_hedge_magic']) ? $_POST['ndd_hedge_magic'] : $this->m_ndd_hedge_magic;
            $this->m_nserver_gmt                   = isset($_POST['nserver_gmt']) ? $_POST['nserver_gmt'] : $this->m_nserver_gmt;
            $this->m_nlocal_gmt                    = isset($_POST['nlocal_gmt']) ? $_POST['nlocal_gmt'] : $this->m_nlocal_gmt;
            $this->m_cenable_asia                  = isset($_POST['cenable_asia']) ? '1' : '0';
            $this->m_nasia_start_hour              = isset($_POST['nasia_start_hour']) ? $_POST['nasia_start_hour'] : $this->m_nasia_start_hour;
            $this->m_nasia_start_minute            = isset($_POST['nasia_start_minute']) ? $_POST['nasia_start_minute'] : $this->m_nasia_start_minute;
            $this->m_nasia_end_hour                = isset($_POST['nasia_end_hour']) ? $_POST['nasia_end_hour'] : $this->m_nasia_end_hour;
            $this->m_nasia_end_minute              = isset($_POST['nasia_end_minute']) ? $_POST['nasia_end_minute'] : $this->m_nasia_end_minute;
            $this->m_cenable_europe                = isset($_POST['cenable_europe']) ? '1' : '0';
            $this->m_neurope_start_hour            = isset($_POST['neurope_start_hour']) ? $_POST['neurope_start_hour'] : $this->m_neurope_start_hour;
            $this->m_neurope_start_minute          = isset($_POST['neurope_start_minute']) ? $_POST['neurope_start_minute'] : $this->m_neurope_start_minute;
            $this->m_neurope_end_hour              = isset($_POST['neurope_end_hour']) ? $_POST['neurope_end_hour'] : $this->m_neurope_end_hour;
            $this->m_neurope_end_minute            = isset($_POST['neurope_end_minute']) ? $_POST['neurope_end_minute'] : $this->m_neurope_end_minute;
            $this->m_cenable_us                    = isset($_POST['cenable_us']) ? '1' : '0';
            $this->m_nus_start_hour                = isset($_POST['nus_start_hour']) ? $_POST['nus_start_hour'] : $this->m_nus_start_hour;
            $this->m_nus_start_minute              = isset($_POST['nus_start_minute']) ? $_POST['nus_start_minute'] : $this->m_nus_start_minute;
            $this->m_nus_end_hour                  = isset($_POST['nus_end_hour']) ? $_POST['nus_end_hour'] : $this->m_nus_end_hour;
            $this->m_nus_end_minute                = isset($_POST['nus_end_minute']) ? $_POST['nus_end_minute'] : $this->m_nus_end_minute;
            $this->m_nclose_protect_max_orders     = isset($_POST['nclose_protect_max_orders']) ? $_POST['nclose_protect_max_orders'] : $this->m_nclose_protect_max_orders;
            $this->m_cclose_protect_use_loss_pct   = isset($_POST['cclose_protect_use_loss_pct']) ? '1' : '0';
            $this->m_fclose_protect_loss_pct       = isset($_POST['fclose_protect_loss_pct']) ? $_POST['fclose_protect_loss_pct'] : $this->m_fclose_protect_loss_pct;
            $this->m_cenable_double_confirm        = isset($_POST['cenable_double_confirm']) ? '1' : '0';
            $this->m_nentry_strategy               = isset($_POST['nentry_strategy']) ? $_POST['nentry_strategy'] : $this->m_nentry_strategy;
            $this->m_nglobal_orders_per_group      = isset($_POST['nglobal_orders_per_group']) ? $_POST['nglobal_orders_per_group'] : $this->m_nglobal_orders_per_group;
            $this->m_fglobal_breakout_distance_usd = isset($_POST['fglobal_breakout_distance_usd']) ? $_POST['fglobal_breakout_distance_usd'] : $this->m_fglobal_breakout_distance_usd;
            $this->m_cglobal_local_distances       = isset($_POST['cglobal_local_distances']) ? trim($_POST['cglobal_local_distances']) : $this->m_cglobal_local_distances;
            $this->m_npairclose_mode               = isset($_POST['npairclose_mode']) ? $_POST['npairclose_mode'] : $this->m_npairclose_mode;
            $this->m_noriginal_pairclose_start_order = isset($_POST['noriginal_pairclose_start_order']) ? $_POST['noriginal_pairclose_start_order'] : $this->m_noriginal_pairclose_start_order;
            $this->m_nrecursive_rebase_target_level = isset($_POST['nrecursive_rebase_target_level']) ? $_POST['nrecursive_rebase_target_level'] : $this->m_nrecursive_rebase_target_level;

            if ($this->m_cbof_cbot_version == 'Onefxhub_v38') {
                if (isset($_POST['v38_txt_finitial_lot'])) $this->m_txt_finitial_lot = $_POST['v38_txt_finitial_lot'];
                if (isset($_POST['v38_txt_flot_multi'])) $this->m_txt_flot_multi = $_POST['v38_txt_flot_multi'];
                if (isset($_POST['v38_txt_nmax_orders'])) $this->m_txt_nmax_orders = $_POST['v38_txt_nmax_orders'];
                if (isset($_POST['v38_txt_ftp_pips'])) $this->m_txt_ftp_pips = $_POST['v38_txt_ftp_pips'];
                if (isset($_POST['v38_txt_fbasket_tp_phan_tram'])) $this->m_txt_fbasket_tp_phan_tram = $_POST['v38_txt_fbasket_tp_phan_tram'];
                if (isset($_POST['v38_txt_nrsi_period'])) $this->m_txt_nrsi_period = $_POST['v38_txt_nrsi_period'];
                if (isset($_POST['v38_cbof_crsi_tf'])) $this->m_cbof_crsi_tf = $_POST['v38_cbof_crsi_tf'];
                if (isset($_POST['v38_txt_nmagic'])) $this->m_txt_nmagic = $_POST['v38_txt_nmagic'];
                if (isset($_POST['v38_cbof_cuse_time_filter'])) $this->m_cbof_cuse_time_filter = '1';
                else if (isset($_POST['v38_hidden_time_filter_marker'])) $this->m_cbof_cuse_time_filter = '0';
                if (isset($_POST['v38_txt_nmin_before_close'])) $this->m_txt_nmin_before_close = $_POST['v38_txt_nmin_before_close'];
                if (isset($_POST['v38_txt_nconfirm_from_order'])) $this->m_txt_nconfirm_from_order = $_POST['v38_txt_nconfirm_from_order'];
                if (isset($_POST['v38_cbof_cpair_close_bat_tat'])) $this->m_cbof_cpair_close_bat_tat = '1';
                else if (isset($_POST['v38_hidden_pair_close_marker'])) $this->m_cbof_cpair_close_bat_tat = '0';
                if (isset($_POST['v38_txt_npair_close_tu_lenh'])) $this->m_txt_npair_close_tu_lenh = $_POST['v38_txt_npair_close_tu_lenh'];
                if (isset($_POST['v38_txt_fpair_close_so_usd'])) $this->m_txt_fpair_close_so_usd = $_POST['v38_txt_fpair_close_so_usd'];
                if (isset($_POST['v38_cbof_cpair_close_chot_dan_ve'])) $this->m_cbof_cpair_close_chot_dan_ve = '1';
                else if (isset($_POST['v38_hidden_pair_close_danve_marker'])) $this->m_cbof_cpair_close_chot_dan_ve = '0';

                for($i=1; $i<=25; $i++){
                    if(isset($_POST['v38_step_G'.$i])) {
                        $this->m_arr_steps['G'.$i] = (double)$_POST['v38_step_G'.$i];
                    } elseif(isset($_POST['step_G'.$i])) {
                        $this->m_arr_steps['G'.$i] = (double)$_POST['step_G'.$i];
                    }
                }
            } else {
                for($i=1; $i<=25; $i++){
                    if(isset($_POST['step_G'.$i])) {
                        $this->m_arr_steps['G'.$i] = (double)$_POST['step_G'.$i];
                    }
                }
            }
        }
    }

    private function check_data()
    {
        if ($this->m_txt_cuserid == '') {
            $this->m_error_msg = 'Tên tài khoản truy cập hệ thống không được để trống.'; return '0';
        }
        if ($this->m_event == 'add' && $this->m_txt_cpassword == '') {
            $this->m_error_msg = 'Vui lòng thiết lập mật khẩu khởi tạo hệ thống cho khách.'; return '0';
        }
        if ($this->m_txt_cmt5_account == '') {
            $this->m_error_msg = 'Số tài khoản giao dịch MT5 bắt buộc phải nhập.'; return '0';
        }
        if ($this->m_event == 'add' && $this->m_txt_cmt5_password == '') {
            $this->m_error_msg = 'Mật khẩu tài khoản sàn MT5 bắt buộc phải nhập để hệ thống VPS kết nối.'; return '0';
        }
        if ($this->m_txt_cbroker_name == '') {
            $this->m_error_msg = 'Tên sàn giao dịch (Broker) không được để trống.'; return '0';
        }
        if ($this->m_event == 'add') {
            if (fbcheck_exists_key_addnew('tuser', 'cuserid', $this->m_txt_cuserid) == FALSE) {
                $this->m_error_msg = "Tên đăng nhập truy cập này đã tồn tại trên hệ thống."; return '0';
            }
            if (fbcheck_exists_key_addnew('tbot_client', 'cmt5_account', $this->m_txt_cmt5_account) == FALSE) {
                $this->m_error_msg = "Số tài khoản MT5 này đã được phân phối License cho bot khác."; return '0';
            }
        }
        return '1';
    }

    private function load_data()
    {
        if ($this->m_event == 'edit' && $this->m_nid != '') {
            $client = Obj_get_bot_client_row($this->m_nid);
            if (!empty($client)) {
                $this->m_txt_cuserid         = $client['cuserid'];
                $this->m_txt_cfullname       = $client['cfullname'];
                $this->m_txt_cmt5_account    = $client['cmt5_account'];
                $this->m_txt_cmt5_password   = $client['cmt5_password'];
                $this->m_txt_cbroker_name    = isset($client['cbroker_name']) ? $client['cbroker_name'] : '';
                
                // BỔ SUNG LOAD DỮ LIỆU CŨ TỪ BẢNG tbot_client
                $this->m_cbof_cbot_version          = isset($client['cbot_version']) ? $client['cbot_version'] : 'RSI6_v33';
                $this->m_cbof_callow_grid_near_end  = isset($client['callow_grid_near_end']) ? $client['callow_grid_near_end'] : '0';
                
                $this->m_txt_clicense_key    = $client['clicense_key'];
                $this->m_txt_dlicense_expiry = $client['dlicense_expiry'];
                $this->m_cbof_cbot_status    = $client['cbot_status'];
                
                if ($this->m_cbof_cbot_version == 'Onefxhub_v38') {
                    $settings_v38 = Obj_get_bot_settings_v38_row($this->m_nid);
                    if(!empty($settings_v38)) {
                        $this->m_txt_finitial_lot  = $settings_v38['finitial_lot'];
                        $this->m_txt_flot_multi    = $settings_v38['flot_multi'];
                        $this->m_txt_nmax_orders   = $settings_v38['nmax_orders'];
                        $this->m_txt_ftp_pips      = $settings_v38['ftp_pips'];
                        $this->m_txt_fbasket_tp_phan_tram = $settings_v38['fbasket_tp_phan_tram'];
                        $this->m_cbat_cong_spread_tp = $settings_v38['cbat_cong_spread_tp'];
                        $this->m_fkhoang_doi_sl    = $settings_v38['fkhoang_doi_sl'];
                        $this->m_fso_pip_doi_sl    = $settings_v38['fso_pip_doi_sl'];
                        $this->m_fkhoang_trailing_sl = $settings_v38['fkhoang_trailing_sl'];
                        $this->m_cbat_cat_dd       = $settings_v38['cbat_cat_dd'];
                        $this->m_fcat_dd_phan_tram = $settings_v38['fcat_dd_phan_tram'];
                        $this->m_ndd_hedge_magic   = $settings_v38['ndd_hedge_magic'];
                        $this->m_txt_nrsi_period   = $settings_v38['nrsi_period'];
                        $this->m_cbof_crsi_tf      = $settings_v38['crsi_tf'];
                        $this->m_txt_nmagic        = $settings_v38['nmagic'];
                        $this->m_cbof_cuse_time_filter = $settings_v38['cuse_time_filter'];
                        $this->m_nserver_gmt       = $settings_v38['nserver_gmt'];
                        $this->m_nlocal_gmt        = $settings_v38['nlocal_gmt'];
                        $this->m_cenable_asia      = $settings_v38['cenable_asia'];
                        $this->m_nasia_start_hour  = $settings_v38['nasia_start_hour'];
                        $this->m_nasia_start_minute = $settings_v38['nasia_start_minute'];
                        $this->m_nasia_end_hour    = $settings_v38['nasia_end_hour'];
                        $this->m_nasia_end_minute  = $settings_v38['nasia_end_minute'];
                        $this->m_cenable_europe    = $settings_v38['cenable_europe'];
                        $this->m_neurope_start_hour = $settings_v38['neurope_start_hour'];
                        $this->m_neurope_start_minute = $settings_v38['neurope_start_minute'];
                        $this->m_neurope_end_hour  = $settings_v38['neurope_end_hour'];
                        $this->m_neurope_end_minute = $settings_v38['neurope_end_minute'];
                        $this->m_cenable_us        = $settings_v38['cenable_us'];
                        $this->m_nus_start_hour    = $settings_v38['nus_start_hour'];
                        $this->m_nus_start_minute  = $settings_v38['nus_start_minute'];
                        $this->m_nus_end_hour      = $settings_v38['nus_end_hour'];
                        $this->m_nus_end_minute    = $settings_v38['nus_end_minute'];
                        $this->m_txt_nmin_before_close = $settings_v38['nmin_before_close'];
                        $this->m_nclose_protect_max_orders = $settings_v38['nclose_protect_max_orders'];
                        $this->m_cclose_protect_use_loss_pct = $settings_v38['cclose_protect_use_loss_pct'];
                        $this->m_fclose_protect_loss_pct = $settings_v38['fclose_protect_loss_pct'];
                        $this->m_cenable_double_confirm = $settings_v38['cenable_double_confirm'];
                        $this->m_txt_nconfirm_from_order = $settings_v38['nconfirm_from_order'];
                        $this->m_nentry_strategy   = $settings_v38['nentry_strategy'];
                        $this->m_nglobal_orders_per_group = $settings_v38['nglobal_orders_per_group'];
                        $this->m_fglobal_breakout_distance_usd = $settings_v38['fglobal_breakout_distance_usd'];
                        $this->m_cglobal_local_distances = $settings_v38['cglobal_local_distances'];
                        $this->m_npairclose_mode   = $settings_v38['npairclose_mode'];
                        $this->m_cbof_cpair_close_bat_tat = $settings_v38['cpair_close_bat_tat'];
                        $this->m_txt_npair_close_tu_lenh = $settings_v38['npair_close_tu_lenh'];
                        $this->m_txt_fpair_close_so_usd = $settings_v38['fpair_close_so_usd'];
                        $this->m_cbof_cpair_close_chot_dan_ve = $settings_v38['cpair_close_chot_dan_ve'];
                        $this->m_noriginal_pairclose_start_order = $settings_v38['noriginal_pairclose_start_order'];
                        $this->m_nrecursive_rebase_target_level = $settings_v38['nrecursive_rebase_target_level'];
                        
                        if(!empty($settings_v38['cstep_distances'])) {
                            $this->m_arr_steps = json_decode($settings_v38['cstep_distances'], true);
                        }
                    }
                } else {
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
                        $this->m_cbof_csession_asia    = isset($settings['csession_asia']) ? $settings['csession_asia'] : '1';
                        $this->m_cbof_csession_london  = isset($settings['csession_london']) ? $settings['csession_london'] : '1';
                        $this->m_cbof_csession_ny      = isset($settings['csession_ny']) ? $settings['csession_ny'] : '1';
                        $this->m_txt_ctime_start_1     = isset($settings['ctime_start_1']) ? $settings['ctime_start_1'] : '';
                        $this->m_txt_ctime_end_1       = isset($settings['ctime_end_1']) ? $settings['ctime_end_1'] : '';
                        $this->m_txt_ctime_start_2     = isset($settings['ctime_start_2']) ? $settings['ctime_start_2'] : '';
                        $this->m_txt_ctime_end_2       = isset($settings['ctime_end_2']) ? $settings['ctime_end_2'] : '';
                        $this->m_txt_ctime_start_3     = isset($settings['ctime_start_3']) ? $settings['ctime_start_3'] : '';
                        $this->m_txt_ctime_end_3       = isset($settings['ctime_end_3']) ? $settings['ctime_end_3'] : '';
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
            }
        }
    }

    private function do_business()
	{
		$str_check_sql = " SELECT nid FROM " . Fget_ap_table('tuser') . " WHERE cuserid = ? AND cdel = '0' ";
		
		if ($this->m_event == 'add') {
			$query_check = $this->db->query($str_check_sql, array($this->m_txt_cuserid));
			if ($query_check->num_rows() > 0) {
				$this->db->trans_rollback();
				echo "<script>alert('Lỗi: Tên đăng nhập này đã tồn tại trên hệ thống! Vui lòng chọn tên khác.'); window.history.back();</script>";
				return;
			}
		} 
		elseif ($this->m_event == 'edit') {
			$current_client = $this->db->select('nuser_id, dlicense_expiry')->where('nid', (int)$this->m_nid)->get('tbot_client')->row_array();
			$str_old_expiry = !empty($current_client) ? $current_client['dlicense_expiry'] : NULL;
			$n_user_id      = !empty($current_client) ? (int)$current_client['nuser_id'] : 0;
			
			if ($n_user_id > 0) {
				$str_check_edit = $str_check_sql . " AND nid <> " . (int)$n_user_id;
				$query_check = $this->db->query($str_check_edit, array($this->m_txt_cuserid));
				if ($query_check->num_rows() > 0) {
					echo "<script>alert('Lỗi: Không thể đổi thành Tên đăng nhập này vì một khách hàng khác đang sử dụng!'); window.history.back();</script>";
					return;
				}
			}
		}

		$this->db->trans_start();

		if ($this->m_event == 'add') {
			$data_user = array(
				'cuserid'      => $this->m_txt_cuserid,
				'cpassword'    => md5($this->m_txt_cpassword),
				'cfullname'    => $this->m_txt_cfullname != '' ? $this->m_txt_cfullname : $this->m_txt_cuserid,
                'crole'        => 'client',
                'nparent_id'   => (int)$this->m_nid_user_login,
				'cstatus'      => '1',
				'cdel'         => '0',
				'nuser_created'=> $this->m_nid_user_login
			);
			$this->db->insert('tuser', $data_user);
			$n_user_id = $this->db->insert_id();

			$data_client = array(
				'nuser_id'              => $n_user_id,
				'cmt5_account'          => $this->m_txt_cmt5_account,
                'cmt5_password'         => $this->m_txt_cmt5_password,
                'cbroker_name'          => $this->m_txt_cbroker_name,
                'cbot_version'          => $this->m_cbof_cbot_version,         // BỔ SUNG LƯU SQL
                'callow_grid_near_end'  => $this->m_cbof_callow_grid_near_end,// BỔ SUNG LƯU SQL
				'clicense_key'          => $this->m_txt_clicense_key,
				'dlicense_expiry'       => $this->m_txt_dlicense_expiry,
				'cbot_status'           => $this->m_cbof_cbot_status,
				'cdel'                  => '0',
				'nuser_created'         => $this->m_nid_user_login
			);
			$this->db->insert('tbot_client', $data_client);
			$n_client_id = $this->db->insert_id();

			if ($this->m_cbof_cbot_version == 'Onefxhub_v38') {
				$data_settings = array(
					'nclient_id'                    => $n_client_id,
					'finitial_lot'                  => (double)$this->m_txt_finitial_lot,
					'flot_multi'                    => (double)$this->m_txt_flot_multi,
					'nmax_orders'                   => (int)$this->m_txt_nmax_orders,
					'ftp_pips'                      => (double)$this->m_txt_ftp_pips,
					'fbasket_tp_phan_tram'          => (double)$this->m_txt_fbasket_tp_phan_tram,
					'cbat_cong_spread_tp'           => $this->m_cbat_cong_spread_tp,
					'fkhoang_doi_sl'                => (double)$this->m_fkhoang_doi_sl,
					'fso_pip_doi_sl'                => (double)$this->m_fso_pip_doi_sl,
					'fkhoang_trailing_sl'           => (double)$this->m_fkhoang_trailing_sl,
					'cbat_cat_dd'                   => $this->m_cbat_cat_dd,
					'fcat_dd_phan_tram'             => (double)$this->m_fcat_dd_phan_tram,
					'ndd_hedge_magic'               => (int)$this->m_ndd_hedge_magic,
					'nrsi_period'                   => (int)$this->m_txt_nrsi_period,
					'crsi_tf'                       => $this->m_cbof_crsi_tf,
					'nmagic'                        => (int)$this->m_txt_nmagic,
					'cuse_time_filter'              => $this->m_cbof_cuse_time_filter,
					'nserver_gmt'                   => (int)$this->m_nserver_gmt,
					'nlocal_gmt'                    => (int)$this->m_nlocal_gmt,
					'cenable_asia'                  => $this->m_cenable_asia,
					'nasia_start_hour'              => (int)$this->m_nasia_start_hour,
					'nasia_start_minute'            => (int)$this->m_nasia_start_minute,
					'nasia_end_hour'                => (int)$this->m_nasia_end_hour,
					'nasia_end_minute'              => (int)$this->m_nasia_end_minute,
					'cenable_europe'                => $this->m_cenable_europe,
					'neurope_start_hour'            => (int)$this->m_neurope_start_hour,
					'neurope_start_minute'          => (int)$this->m_neurope_start_minute,
					'neurope_end_hour'              => (int)$this->m_neurope_end_hour,
					'neurope_end_minute'            => (int)$this->m_neurope_end_minute,
					'cenable_us'                    => $this->m_cenable_us,
					'nus_start_hour'                => (int)$this->m_nus_start_hour,
					'nus_start_minute'              => (int)$this->m_nus_start_minute,
					'nus_end_hour'                  => (int)$this->m_nus_end_hour,
					'nus_end_minute'                => (int)$this->m_nus_end_minute,
					'nmin_before_close'             => (int)$this->m_txt_nmin_before_close,
					'nclose_protect_max_orders'     => (int)$this->m_nclose_protect_max_orders,
					'cclose_protect_use_loss_pct'   => $this->m_cclose_protect_use_loss_pct,
					'fclose_protect_loss_pct'       => (double)$this->m_fclose_protect_loss_pct,
					'cenable_double_confirm'        => $this->m_cenable_double_confirm,
					'nconfirm_from_order'           => (int)$this->m_txt_nconfirm_from_order,
					'nentry_strategy'               => (int)$this->m_nentry_strategy,
					'nglobal_orders_per_group'      => (int)$this->m_nglobal_orders_per_group,
					'fglobal_breakout_distance_usd' => (double)$this->m_fglobal_breakout_distance_usd,
					'cglobal_local_distances'       => $this->m_cglobal_local_distances,
					'npairclose_mode'               => (int)$this->m_npairclose_mode,
					'cpair_close_bat_tat'           => $this->m_cbof_cpair_close_bat_tat,
					'npair_close_tu_lenh'           => (int)$this->m_txt_npair_close_tu_lenh,
					'fpair_close_so_usd'            => (double)$this->m_txt_fpair_close_so_usd,
					'cpair_close_chot_dan_ve'       => $this->m_cbof_cpair_close_chot_dan_ve,
					'noriginal_pairclose_start_order'=> (int)$this->m_noriginal_pairclose_start_order,
					'nrecursive_rebase_target_level' => (int)$this->m_nrecursive_rebase_target_level,
					'cstep_distances'               => json_encode($this->m_arr_steps)
				);
				$this->db->insert('tbot_settings_v38', $data_settings);
			} else {
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
					'csession_asia'        => $this->m_cbof_csession_asia,
					'csession_london'      => $this->m_cbof_csession_london,
					'csession_ny'          => $this->m_cbof_csession_ny,
					'ctime_start_1'        => $this->m_txt_ctime_start_1,
					'ctime_end_1'          => $this->m_txt_ctime_end_1,
					'ctime_start_2'        => $this->m_txt_ctime_start_2,
					'ctime_end_2'          => $this->m_txt_ctime_end_2,
					'ctime_start_3'        => $this->m_txt_ctime_start_3,
					'ctime_end_3'          => $this->m_txt_ctime_end_3,
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
			}

			$data_history = array(
				'nclient_id'    => $n_client_id,
				'cmt5_account'  => $this->m_txt_cmt5_account,
				'clicense_key'  => $this->m_txt_clicense_key,
				'dold_expiry'   => NULL,
				'dnew_expiry'   => $this->m_txt_dlicense_expiry,
				'naction_type'  => 1,
				'cnote'         => 'Khởi tạo tài khoản hệ thống và cấp khóa License Key 12 tháng mặc định.',
				'nuser_created' => $this->m_nid_user_login
			);
			$this->db->insert('tbot_license_history', $data_history);

			$this->db->trans_complete();
			if ($this->db->trans_status() === TRUE) {
				$arr_full_log = array_merge($data_client, $data_settings);
				Fwrite_system_log('INSERT', 'tbot_client', $n_client_id, "CREATE_BOT_STRATEGY: " . json_encode($arr_full_log, JSON_UNESCAPED_UNICODE));
			}
		} 
		elseif ($this->m_event == 'edit') {
			if ($n_user_id > 0) {
				$data_user = array(
					'cuserid'       => $this->m_txt_cuserid,
					'cfullname'     => $this->m_txt_cfullname != '' ? $this->m_txt_cfullname : $this->m_txt_cuserid,
					'nuser_updated' => $this->m_nid_user_login,
					'ddate_updated' => date('Y-m-d H:i:s')
				);
				if ($this->m_txt_cpassword != '') {
					$data_user['cpassword'] = md5($this->m_txt_cpassword);
				}
				$this->db->where('nid', $n_user_id)->update('tuser', $data_user);
			}

			$data_client = array(
				'cmt5_account'          => $this->m_txt_cmt5_account,
                'cmt5_password'         => $this->m_txt_cmt5_password,
                'cbroker_name'          => $this->m_txt_cbroker_name,
                'cbot_version'          => $this->m_cbof_cbot_version,         // BỔ SUNG CẬP NHẬT SQL
                'callow_grid_near_end'  => $this->m_cbof_callow_grid_near_end,// BỔ SUNG CẬP NHẬT SQL
				'clicense_key'          => $this->m_txt_clicense_key,
				'dlicense_expiry'       => $this->m_txt_dlicense_expiry,
				'cbot_status'           => $this->m_cbof_cbot_status,
				'nuser_updated'         => $this->m_nid_user_login,
				'ddate_updated'         => date('Y-m-d H:i:s')
			);
			$this->db->where('nid', (int)$this->m_nid)->update('tbot_client', $data_client);

			if ($this->m_cbof_cbot_version == 'Onefxhub_v38') {
				$data_settings = array(
					'finitial_lot'                  => (double)$this->m_txt_finitial_lot,
					'flot_multi'                    => (double)$this->m_txt_flot_multi,
					'nmax_orders'                   => (int)$this->m_txt_nmax_orders,
					'ftp_pips'                      => (double)$this->m_txt_ftp_pips,
					'fbasket_tp_phan_tram'          => (double)$this->m_txt_fbasket_tp_phan_tram,
					'cbat_cong_spread_tp'           => $this->m_cbat_cong_spread_tp,
					'fkhoang_doi_sl'                => (double)$this->m_fkhoang_doi_sl,
					'fso_pip_doi_sl'                => (double)$this->m_fso_pip_doi_sl,
					'fkhoang_trailing_sl'           => (double)$this->m_fkhoang_trailing_sl,
					'cbat_cat_dd'                   => $this->m_cbat_cat_dd,
					'fcat_dd_phan_tram'             => (double)$this->m_fcat_dd_phan_tram,
					'ndd_hedge_magic'               => (int)$this->m_ndd_hedge_magic,
					'nrsi_period'                   => (int)$this->m_txt_nrsi_period,
					'crsi_tf'                       => $this->m_cbof_crsi_tf,
					'nmagic'                        => (int)$this->m_txt_nmagic,
					'cuse_time_filter'              => $this->m_cbof_cuse_time_filter,
					'nserver_gmt'                   => (int)$this->m_nserver_gmt,
					'nlocal_gmt'                    => (int)$this->m_nlocal_gmt,
					'cenable_asia'                  => $this->m_cenable_asia,
					'nasia_start_hour'              => (int)$this->m_nasia_start_hour,
					'nasia_start_minute'            => (int)$this->m_nasia_start_minute,
					'nasia_end_hour'                => (int)$this->m_nasia_end_hour,
					'nasia_end_minute'              => (int)$this->m_nasia_end_minute,
					'cenable_europe'                => $this->m_cenable_europe,
					'neurope_start_hour'            => (int)$this->m_neurope_start_hour,
					'neurope_start_minute'          => (int)$this->m_neurope_start_minute,
					'neurope_end_hour'              => (int)$this->m_neurope_end_hour,
					'neurope_end_minute'            => (int)$this->m_neurope_end_minute,
					'cenable_us'                    => $this->m_cenable_us,
					'nus_start_hour'                => (int)$this->m_nus_start_hour,
					'nus_start_minute'              => (int)$this->m_nus_start_minute,
					'nus_end_hour'                  => (int)$this->m_nus_end_hour,
					'nus_end_minute'                => (int)$this->m_nus_end_minute,
					'nmin_before_close'             => (int)$this->m_txt_nmin_before_close,
					'nclose_protect_max_orders'     => (int)$this->m_nclose_protect_max_orders,
					'cclose_protect_use_loss_pct'   => $this->m_cclose_protect_use_loss_pct,
					'fclose_protect_loss_pct'       => (double)$this->m_fclose_protect_loss_pct,
					'cenable_double_confirm'        => $this->m_cenable_double_confirm,
					'nconfirm_from_order'           => (int)$this->m_txt_nconfirm_from_order,
					'nentry_strategy'               => (int)$this->m_nentry_strategy,
					'nglobal_orders_per_group'      => (int)$this->m_nglobal_orders_per_group,
					'fglobal_breakout_distance_usd' => (double)$this->m_fglobal_breakout_distance_usd,
					'cglobal_local_distances'       => $this->m_cglobal_local_distances,
					'npairclose_mode'               => (int)$this->m_npairclose_mode,
					'cpair_close_bat_tat'           => $this->m_cbof_cpair_close_bat_tat,
					'npair_close_tu_lenh'           => (int)$this->m_txt_npair_close_tu_lenh,
					'fpair_close_so_usd'            => (double)$this->m_txt_fpair_close_so_usd,
					'cpair_close_chot_dan_ve'       => $this->m_cbof_cpair_close_chot_dan_ve,
					'noriginal_pairclose_start_order'=> (int)$this->m_noriginal_pairclose_start_order,
					'nrecursive_rebase_target_level' => (int)$this->m_nrecursive_rebase_target_level,
					'cstep_distances'               => json_encode($this->m_arr_steps)
				);
				$exists_v38 = $this->db->where('nclient_id', (int)$this->m_nid)->count_all_results('tbot_settings_v38');
				if ($exists_v38 > 0) {
					$this->db->where('nclient_id', (int)$this->m_nid)->update('tbot_settings_v38', $data_settings);
				} else {
					$data_settings['nclient_id'] = (int)$this->m_nid;
					$this->db->insert('tbot_settings_v38', $data_settings);
				}
			} else {
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
					'csession_asia'        => $this->m_cbof_csession_asia,
					'csession_london'      => $this->m_cbof_csession_london,
					'csession_ny'          => $this->m_cbof_csession_ny,
					'ctime_start_1'        => $this->m_txt_ctime_start_1,
					'ctime_end_1'          => $this->m_txt_ctime_end_1,
					'ctime_start_2'        => $this->m_txt_ctime_start_2,
					'ctime_end_2'          => $this->m_txt_ctime_end_2,
					'ctime_start_3'        => $this->m_txt_ctime_start_3,
					'ctime_end_3'          => $this->m_txt_ctime_end_3,
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
				$exists_v33 = $this->db->where('nclient_id', (int)$this->m_nid)->count_all_results('tbot_settings');
				if ($exists_v33 > 0) {
					$this->db->where('nclient_id', (int)$this->m_nid)->update('tbot_settings', $data_settings);
				} else {
					$data_settings['nclient_id'] = (int)$this->m_nid;
					$this->db->insert('tbot_settings', $data_settings);
				}
			}

			if ($str_old_expiry !== NULL && $str_old_expiry != $this->m_txt_dlicense_expiry) {
				$data_history = array(
					'nclient_id'    => (int)$this->m_nid,
					'cmt5_account'  => $this->m_txt_cmt5_account,
					'clicense_key'  => $this->m_txt_clicense_key,
					'dold_expiry'   => $str_old_expiry,
					'dnew_expiry'   => $this->m_txt_dlicense_expiry,
					'naction_type'  => 2,
					'cnote'         => 'Gia hạn thời hạn sử dụng Robot. Thay đổi ngày hết hạn từ trường lưu cũ.',
					'nuser_created' => $this->m_nid_user_login
				);
				$this->db->insert('tbot_license_history', $data_history);
			}

			$this->db->trans_complete();
			if ($this->db->trans_status() === TRUE) {
				$arr_full_log = array_merge($data_client, $data_settings);
				Fwrite_system_log('UPDATE', 'tbot_client', $this->m_nid, "UPDATE_BOT_STRATEGY: " . json_encode($arr_full_log, JSON_UNESCAPED_UNICODE));
			}
		}

		redirect($this->m_link_cancel);
	}

    private function show_view()
    {
        $data['lbl_form_title']   = $this->m_form_title;
        $data['link_page']        = $this->m_link_page;
        $data['link_cancel']      = $this->m_link_cancel;
        $data['m_message']        = $this->m_error_msg;
        $data['nid']              = $this->m_nid;
        $data['event']            = $this->m_event;
        $data['menu_active']      = 'bot_trade';

        $data['txt_cuserid']            = $this->m_txt_cuserid;
        $data['txt_cpassword']          = $this->m_txt_cpassword;
        $data['txt_cfullname']          = $this->m_txt_cfullname;
        $data['txt_cmt5_account']       = $this->m_txt_cmt5_account;
        $data['txt_cmt5_password']      = $this->m_txt_cmt5_password;
        $data['txt_cbroker_name']       = $this->m_txt_cbroker_name;
        
        // BỔ SUNG TRUYỀN DỮ LIỆU SANG VIEW
        $data['cbof_cbot_version']          = $this->m_cbof_cbot_version;
        $data['cbof_callow_grid_near_end']  = $this->m_cbof_callow_grid_near_end;
        
        $data['txt_clicense_key']       = $this->m_txt_clicense_key;
        $data['txt_dlicense_expiry']    = $this->m_txt_dlicense_expiry;
        $data['cbof_cbot_status']       = $this->m_cbof_cbot_status;

        $data['txt_finitial_lot']       = $this->m_txt_finitial_lot;
        $data['txt_flot_multi']         = $this->m_txt_flot_multi;
        $data['txt_nmax_orders']        = $this->m_txt_nmax_orders;
        $data['cbof_ntp_mode']          = $this->m_cbof_ntp_mode;
        $data['txt_ftp_pips']           = $this->m_txt_ftp_pips;
        $data['txt_ftp_usd']            = $this->m_txt_ftp_usd;
        $data['txt_nrsi_period']        = $this->m_txt_nrsi_period;
        $data['cbof_crsi_tf']           = $this->m_cbof_crsi_tf;
        $data['txt_nmagic']             = $this->m_txt_nmagic;
        $data['cbof_cuse_time_filter']  = $this->m_cbof_cuse_time_filter;
        $data['cbof_csession_asia']     = $this->m_cbof_csession_asia;
        $data['cbof_csession_london']   = $this->m_cbof_csession_london;
        $data['cbof_csession_ny']       = $this->m_cbof_csession_ny;
        $data['txt_ctime_start_1']      = $this->m_txt_ctime_start_1;
        $data['txt_ctime_end_1']        = $this->m_txt_ctime_end_1;
        $data['txt_ctime_start_2']      = $this->m_txt_ctime_start_2;
        $data['txt_ctime_end_2']        = $this->m_txt_ctime_end_2;
        $data['txt_ctime_start_3']      = $this->m_txt_ctime_start_3;
        $data['txt_ctime_end_3']        = $this->m_txt_ctime_end_3;
        $data['txt_nstart_hour_local']  = $this->m_txt_nstart_hour_local;
        $data['txt_nend_hour_local']    = $this->m_txt_nend_hour_local;
        $data['txt_nmin_before_close']  = $this->m_txt_nmin_before_close;
        $data['txt_nconfirm_from_order'] = $this->m_txt_nconfirm_from_order;
        $data['cbof_cpair_close_bat_tat'] = $this->m_cbof_cpair_close_bat_tat;
        $data['txt_npair_close_tu_lenh']   = $this->m_txt_npair_close_tu_lenh;
        $data['txt_fpair_close_so_usd']    = $this->m_txt_fpair_close_so_usd;
        $data['cbof_cpair_close_chot_dan_ve'] = $this->m_cbof_cpair_close_chot_dan_ve;
        $data['txt_fbasket_tp_phan_tram']  = $this->m_txt_fbasket_tp_phan_tram;
        $data['arr_steps']              = $this->m_arr_steps;

        // BỔ SUNG TRUYỀN DỮ LIỆU CẤU HÌNH V38 SANG VIEW
        $data['cbat_cong_spread_tp']           = $this->m_cbat_cong_spread_tp;
        $data['fkhoang_doi_sl']                = $this->m_fkhoang_doi_sl;
        $data['fso_pip_doi_sl']                = $this->m_fso_pip_doi_sl;
        $data['fkhoang_trailing_sl']           = $this->m_fkhoang_trailing_sl;
        $data['cbat_cat_dd']                   = $this->m_cbat_cat_dd;
        $data['fcat_dd_phan_tram']             = $this->m_fcat_dd_phan_tram;
        $data['ndd_hedge_magic']               = $this->m_ndd_hedge_magic;
        $data['nserver_gmt']                   = $this->m_nserver_gmt;
        $data['nlocal_gmt']                    = $this->m_nlocal_gmt;
        $data['cenable_asia']                  = $this->m_cenable_asia;
        $data['nasia_start_hour']              = $this->m_nasia_start_hour;
        $data['nasia_start_minute']            = $this->m_nasia_start_minute;
        $data['nasia_end_hour']                = $this->m_nasia_end_hour;
        $data['nasia_end_minute']              = $this->m_nasia_end_minute;
        $data['cenable_europe']                = $this->m_cenable_europe;
        $data['neurope_start_hour']            = $this->m_neurope_start_hour;
        $data['neurope_start_minute']          = $this->m_neurope_start_minute;
        $data['neurope_end_hour']              = $this->m_neurope_end_hour;
        $data['neurope_end_minute']            = $this->m_neurope_end_minute;
        $data['cenable_us']                    = $this->m_cenable_us;
        $data['nus_start_hour']                = $this->m_nus_start_hour;
        $data['nus_start_minute']              = $this->m_nus_start_minute;
        $data['nus_end_hour']                  = $this->m_nus_end_hour;
        $data['nus_end_minute']                = $this->m_nus_end_minute;
        $data['nclose_protect_max_orders']     = $this->m_nclose_protect_max_orders;
        $data['cclose_protect_use_loss_pct']   = $this->m_cclose_protect_use_loss_pct;
        $data['fclose_protect_loss_pct']       = $this->m_fclose_protect_loss_pct;
        $data['cenable_double_confirm']        = $this->m_cenable_double_confirm;
        $data['nentry_strategy']               = $this->m_nentry_strategy;
        $data['nglobal_orders_per_group']      = $this->m_nglobal_orders_per_group;
        $data['fglobal_breakout_distance_usd'] = $this->m_fglobal_breakout_distance_usd;
        $data['cglobal_local_distances']       = $this->m_cglobal_local_distances;
        $data['npairclose_mode']               = $this->m_npairclose_mode;
        $data['noriginal_pairclose_start_order'] = $this->m_noriginal_pairclose_start_order;
        $data['nrecursive_rebase_target_level'] = $this->m_nrecursive_rebase_target_level;

        $v38_defaults_G = array(
            1=>4, 2=>4, 3=>8, 4=>8, 5=>12, 6=>12, 7=>16, 8=>16, 9=>20, 10=>20,
            11=>24, 12=>24, 13=>28, 14=>28, 15=>32, 16=>32, 17=>36, 18=>36, 19=>40, 20=>40,
            21=>44, 22=>44, 23=>48, 24=>48, 25=>52
        );
        $data['arr_steps_v38'] = array();
        for($i=1; $i<=25; $i++){
            $data['arr_steps_v38']['G'.$i] = isset($this->m_arr_steps['G'.$i]) && $this->m_cbof_cbot_version == 'Onefxhub_v38' ? $this->m_arr_steps['G'.$i] : $v38_defaults_G[$i];
        }

        $this->load->view('bot_client_view/index.php', $data);
    }
}