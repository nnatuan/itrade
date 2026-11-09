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
        $license  = isset($_REQUEST['license'])  ? trim($_REQUEST['license']) : '';
        $account  = isset($_REQUEST['account'])  ? trim($_REQUEST['account']) : '';
        
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

        // CẬP NHẬT 3: Đóng gói mảng response trả về cho EA (bổ sung AllowGridNearEnd)
		$response = array(
			'status'         => 'success',
			'bot_active'     => (int)$bot_info['cbot_status'], 
			'bot_version'    => isset($bot_info['cbot_version']) ? $bot_info['cbot_version'] : 'RSI6_v33',
			'license_expiry' => $bot_info['dlicense_expiry'],
			'inputs' => array(
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
			)
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