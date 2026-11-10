<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Do_bot_api extends CI_Controller
{
    function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper('ap_db');
        $this->load->helper('ap_function');
        $this->load->helper('ap_module');
        
        // Cấu hình bỏ qua bộ lọc kiểm tra đăng nhập phiên web đối với cổng API
        $this->config->check_system_login = 'begin'; 
    }

    function check_license()
    {
        $license  = isset($_REQUEST['license'])  ? trim($_REQUEST['license']) : (isset($_REQUEST['license_key']) ? trim($_REQUEST['license_key']) : '');
        $account  = isset($_REQUEST['account'])  ? trim($_REQUEST['account']) : (isset($_REQUEST['account_number']) ? trim($_REQUEST['account_number']) : '');
        
        // Hứng toàn bộ chỉ số tài chính thời gian thực từ EA gửi về
        $balance  = isset($_REQUEST['balance'])  ? (double)$_REQUEST['balance'] : 0.0;
        $equity   = isset($_REQUEST['equity'])   ? (double)$_REQUEST['equity'] : 0.0;
        $drawdown = isset($_REQUEST['drawdown']) ? (double)$_REQUEST['drawdown'] : 0.0;
        $profit   = isset($_REQUEST['profit'])   ? (double)$_REQUEST['profit'] : 0.0;

        // CẬP NHẬT 1: Hứng tên sàn trade (Broker) gửi lên từ EA nếu có
        $broker   = isset($_REQUEST['broker'])   ? trim($_REQUEST['broker']) : '';

        if (empty($license) || empty($account)) {
            $this->output_json(array('status' => 'error', 'message' => 'Missing parameter'));
            return;
        }

        // Gọi hàm bóc tách dữ liệu SQL thuần từ hệ thống Module Helper
        $bot_info = Obj_get_bot_licensing_info($license, $account);

        if (empty($bot_info)) {
            $this->output_json(array('status' => 'invalid', 'message' => 'License or account incorrect'));
            return;
        }

        // Kiểm tra thời hạn giấy phép (License Key) bằng timestamps
        if (strtotime($bot_info['dlicense_expiry']) < time()) {
            $this->output_json(array('status' => 'expired', 'message' => 'License key has expired'));
            return;
        }

        // CẬP NHẬT 2: Lưu tên sàn nếu CSDL đang rỗng hoặc có dữ liệu mới
        $sql_broker_update = "";
        if (!empty($broker)) {
            $sql_broker_update = ", cbroker_name = " . $this->db->escape($broker);
        }

        // ĐỒNG BỘ: Cập nhật chỉ số tài sản, mức rủi ro, lợi nhuận và tên sàn về CSDL
        $str_update_sql = " UPDATE " . Fget_ap_table('tbot_client') . " 
                            SET fbalance = " . (double)$balance . ", 
                                fequity = " . (double)$equity . ", 
                                fdrawdown = " . (double)$drawdown . ",
                                fprofit = " . (double)$profit . "
                                " . $sql_broker_update . ",
                                ddate_updated = '" . date('Y-m-d H:i:s') . "' 
                            WHERE nid = " . (int)$bot_info['nid'];
                            
        $this->db->query($str_update_sql);

        // Giải mã chuỗi JSON khoảng cách chuỗi lưới lệnh động G1-G25
        $arr_steps = !empty($bot_info['cstep_distances']) ? json_decode($bot_info['cstep_distances'], true) : array();

        // CẬP NHẬT 3: Đóng gói mảng response trả về cho EA theo từng phiên bản Bot
        $bot_version = isset($bot_info['cbot_version']) ? $bot_info['cbot_version'] : 'RSI6_v33';

        if ($bot_version == 'Onefxhub_v38') {
            // Cấu hình đầy đủ cho Bot V38 từ bảng ea_tbot_settings_v38
            $inputs = array(
                'Initial_Lot'                   => isset($bot_info['finitial_lot']) ? (double)$bot_info['finitial_lot'] : 0.03,
                'Lot_Multi'                     => isset($bot_info['flot_multi']) ? (double)$bot_info['flot_multi'] : 1.50,
                'Max_Orders'                    => isset($bot_info['nmax_orders']) ? (int)$bot_info['nmax_orders'] : 26,
                'TP_Pips'                       => isset($bot_info['ftp_pips']) ? (double)$bot_info['ftp_pips'] : 10.0,
                'Basket_TP_PhanTram'            => isset($bot_info['fbasket_tp_phan_tram']) ? (double)$bot_info['fbasket_tp_phan_tram'] : 0.0,
                'Bat_Cong_Spread_TP'           => isset($bot_info['cbat_cong_spread_tp']) ? (int)$bot_info['cbat_cong_spread_tp'] : 1,
                'Khoang_Doi_SL'                 => isset($bot_info['fkhoang_doi_sl']) ? (double)$bot_info['fkhoang_doi_sl'] : 25.0,
                'So_Pip_Doi_SL'                 => isset($bot_info['fso_pip_doi_sl']) ? (double)$bot_info['fso_pip_doi_sl'] : 15.0,
                'Khoang_Trailing_SL'            => isset($bot_info['fkhoang_trailing_sl']) ? (double)$bot_info['fkhoang_trailing_sl'] : 10.0,
                'Bat_Cat_DD'                    => isset($bot_info['cbat_cat_dd']) ? (int)$bot_info['cbat_cat_dd'] : 0,
                'Cat_DD_PhanTram'               => isset($bot_info['fcat_dd_phan_tram']) ? (double)$bot_info['fcat_dd_phan_tram'] : 0.0,
                'DDLock_HedgeMagic'             => isset($bot_info['ndd_hedge_magic']) ? (int)$bot_info['ndd_hedge_magic'] : 888838,
                'RSI_Period'                    => isset($bot_info['nrsi_period']) ? (int)$bot_info['nrsi_period'] : 5,
                'RSI_TF'                        => isset($bot_info['crsi_tf']) ? $bot_info['crsi_tf'] : 'PERIOD_M1',
                'Magic'                         => isset($bot_info['nmagic']) ? (int)$bot_info['nmagic'] : 522345,
                'UseTimeFilter'                 => isset($bot_info['cuse_time_filter']) ? (int)$bot_info['cuse_time_filter'] : 1,
                'ServerGMT'                     => isset($bot_info['nserver_gmt']) ? (int)$bot_info['nserver_gmt'] : 3,
                'LocalGMT'                      => isset($bot_info['nlocal_gmt']) ? (int)$bot_info['nlocal_gmt'] : 7,
                'Enable_Asia'                   => isset($bot_info['cenable_asia']) ? (int)$bot_info['cenable_asia'] : 1,
                'Asia_StartHour'                => isset($bot_info['nasia_start_hour']) ? (int)$bot_info['nasia_start_hour'] : 5,
                'Asia_StartMinute'              => isset($bot_info['nasia_start_minute']) ? (int)$bot_info['nasia_start_minute'] : 0,
                'Asia_EndHour'                  => isset($bot_info['nasia_end_hour']) ? (int)$bot_info['nasia_end_hour'] : 14,
                'Asia_EndMinute'                => isset($bot_info['nasia_end_minute']) ? (int)$bot_info['nasia_end_minute'] : 0,
                'Enable_Europe'                 => isset($bot_info['cenable_europe']) ? (int)$bot_info['cenable_europe'] : 1,
                'Europe_StartHour'              => isset($bot_info['neurope_start_hour']) ? (int)$bot_info['neurope_start_hour'] : 14,
                'Europe_StartMinute'            => isset($bot_info['neurope_start_minute']) ? (int)$bot_info['neurope_start_minute'] : 0,
                'Europe_EndHour'                => isset($bot_info['neurope_end_hour']) ? (int)$bot_info['neurope_end_hour'] : 23,
                'Europe_EndMinute'              => isset($bot_info['neurope_end_minute']) ? (int)$bot_info['neurope_end_minute'] : 0,
                'Enable_US'                     => isset($bot_info['cenable_us']) ? (int)$bot_info['cenable_us'] : 1,
                'US_StartHour'                  => isset($bot_info['nus_start_hour']) ? (int)$bot_info['nus_start_hour'] : 19,
                'US_StartMinute'                => isset($bot_info['nus_start_minute']) ? (int)$bot_info['nus_start_minute'] : 0,
                'US_EndHour'                    => isset($bot_info['nus_end_hour']) ? (int)$bot_info['nus_end_hour'] : 4,
                'US_EndMinute'                  => isset($bot_info['nus_end_minute']) ? (int)$bot_info['nus_end_minute'] : 0,
                'MinBeforeClose'                => isset($bot_info['nmin_before_close']) ? (int)$bot_info['nmin_before_close'] : 60,
                'CloseProtect_MaxOrders'        => isset($bot_info['nclose_protect_max_orders']) ? (int)$bot_info['nclose_protect_max_orders'] : 8,
                'CloseProtect_UsePairACycleLossPct' => isset($bot_info['cclose_protect_use_loss_pct']) ? (int)$bot_info['cclose_protect_use_loss_pct'] : 1,
                'CloseProtect_PairACycleMaxLossPct' => isset($bot_info['fclose_protect_loss_pct']) ? (double)$bot_info['fclose_protect_loss_pct'] : 0.3,
                'Enable_DoubleConfirmation'     => isset($bot_info['cenable_double_confirm']) ? (int)$bot_info['cenable_double_confirm'] : 1,
                'ConfirmFromOrder'              => isset($bot_info['nconfirm_from_order']) ? (int)$bot_info['nconfirm_from_order'] : 19,
                'Entry_Strategy'                => isset($bot_info['nentry_strategy']) ? (int)$bot_info['nentry_strategy'] : 0,
                'GlobalGrid_OrdersPerGroup'     => isset($bot_info['nglobal_orders_per_group']) ? (int)$bot_info['nglobal_orders_per_group'] : 6,
                'GlobalGrid_BreakoutDistanceUSD'=> isset($bot_info['fglobal_breakout_distance_usd']) ? (double)$bot_info['fglobal_breakout_distance_usd'] : 3.0,
                'GlobalGrid_LocalDistancesPips' => isset($bot_info['cglobal_local_distances']) ? $bot_info['cglobal_local_distances'] : '4,4,8,8,12,12,16,16,20,20,24,24,28,28,32,32,36,36,40,40,44,44,48,48,52',
                'PairClose_Mode'                => isset($bot_info['npairclose_mode']) ? (int)$bot_info['npairclose_mode'] : 1,
                'PairClose_BatTat'              => isset($bot_info['cpair_close_bat_tat']) ? (int)$bot_info['cpair_close_bat_tat'] : 1,
                'PairClose_TuLenh'              => isset($bot_info['npair_close_tu_lenh']) ? (int)$bot_info['npair_close_tu_lenh'] : 12,
                'PairClose_SoUSD'               => isset($bot_info['fpair_close_so_usd']) ? (double)$bot_info['fpair_close_so_usd'] : 2.0,
                'PairClose_ChotDanVe'           => isset($bot_info['cpair_close_chot_dan_ve']) ? (int)$bot_info['cpair_close_chot_dan_ve'] : 1,
                'OriginalPairCloseStartOrder'   => isset($bot_info['noriginal_pairclose_start_order']) ? (int)$bot_info['noriginal_pairclose_start_order'] : 20,
                'RecursiveRebaseTargetLevel'    => isset($bot_info['nrecursive_rebase_target_level']) ? (int)$bot_info['nrecursive_rebase_target_level'] : 15,
                'Step_Distances'                => $arr_steps
            );
        } else {
            // Giữ nguyên 100% cho Bot V32 / V33
            $inputs = array(
                'Initial_Lot'        => (double)$bot_info['finitial_lot'],
                'Lot_Multi'          => (double)$bot_info['flot_multi'],
                'Max_Orders'         => (int)$bot_info['nmax_orders'],
                'TP_Mode'            => (int)$bot_info['ntp_mode'],
                'TP_Pips'            => (double)$bot_info['ftp_pips'],
                'TP_USD'             => (double)$bot_info['ftp_usd'],
                'RSI_Period'         => (int)$bot_info['nrsi_period'],
                'RSI_TF'             => $bot_info['crsi_tf'],
                'Magic_Num'          => (int)$bot_info['nmagic'],
                'UseTimeFilter'      => (int)$bot_info['cuse_time_filter'],
                'Session_Asia'       => isset($bot_info['csession_asia']) ? (int)$bot_info['csession_asia'] : 1,
                'Session_London'     => isset($bot_info['csession_london']) ? (int)$bot_info['csession_london'] : 1,
                'Session_NY'         => isset($bot_info['csession_ny']) ? (int)$bot_info['csession_ny'] : 1,
                'Time_Start_1'       => isset($bot_info['ctime_start_1']) ? $bot_info['ctime_start_1'] : '',
                'Time_End_1'         => isset($bot_info['ctime_end_1']) ? $bot_info['ctime_end_1'] : '',
                'Time_Start_2'       => isset($bot_info['ctime_start_2']) ? $bot_info['ctime_start_2'] : '',
                'Time_End_2'         => isset($bot_info['ctime_end_2']) ? $bot_info['ctime_end_2'] : '',
                'Time_Start_3'       => isset($bot_info['ctime_start_3']) ? $bot_info['ctime_start_3'] : '',
                'Time_End_3'         => isset($bot_info['ctime_end_3']) ? $bot_info['ctime_end_3'] : '',
                'StartHourLocal'     => (int)$bot_info['nstart_hour_local'],
                'EndHourLocal'       => (int)$bot_info['nend_hour_local'],
                'MinBeforeClose'     => (int)$bot_info['nmin_before_close'],
                'AllowGridNearEnd'   => isset($bot_info['callow_grid_near_end']) ? (int)$bot_info['callow_grid_near_end'] : 0,
                'ConfirmFromOrder'   => (int)$bot_info['nconfirm_from_order'],
                'PairClose_BatTat'   => (int)$bot_info['cpair_close_bat_tat'],
                'PairClose_TuLenh'   => (int)$bot_info['npair_close_tu_lenh'],
                'PairClose_SoUSD'    => (double)$bot_info['fpair_close_so_usd'],
                'PairClose_ChotDanVe'=> (int)$bot_info['cpair_close_chot_dan_ve'],
                'Basket_TP_PhanTram' => (double)$bot_info['fbasket_tp_phan_tram'],
                'Step_Distances'     => $arr_steps
            );
        }

        $response = array(
            'status'         => 'success',
            'bot_active'     => (int)$bot_info['cbot_status'], 
            'bot_version'    => $bot_version,
            'license_expiry' => $bot_info['dlicense_expiry'],
            'inputs'         => $inputs
        );

        $this->output_json($response);
    }

    private function output_json($data)
    {
        $this->output
             ->set_content_type('application/json', 'utf-8')
             ->set_output(json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
    }
}