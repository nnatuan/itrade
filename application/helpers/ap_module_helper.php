<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

/**
 * ===================================================================
 * EXPERT ADVISOR (EA) MANAGEMENT SYSTEM - OBJECT HELPERS
 * ===================================================================
 */

/**
 * Tự động lưu vết toàn bộ hành động truy cập và thay đổi dữ liệu hệ thống (Module Bảo mật)
 */
function Fwrite_system_log($c_action, $c_table_name, $n_record_id, $c_content_log)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    // Lấy ID người dùng đang đăng nhập từ Session hệ thống
    $n_user_id = (int)Fget_userdata('session_nid_user');
    if($n_user_id <= 0) $n_user_id = 1; // Mặc định hệ thống hoặc tài khoản gốc nếu chạy ngầm
    
    // Tự động bắt địa chỉ IP máy mạng của bác sĩ thao tác
    $c_ip = $obj_helper->input->ip_address();
    
    $data_log = array(
        'nuser_id'     => $n_user_id,
        'caction'      => $c_action,
        'ctable_name'  => $c_table_name,
        'nrecord_id'   => (int)$n_record_id,
        'ccontent_log' => $c_content_log,
        'cip_address'  => $c_ip,
        'ddate_created'=> date('Y-m-d H:i:s')
    );
    
    // Chèn dữ liệu sử dụng bảng động qua cơ chế hệ thống
    return $obj_helper->db->insert('tsystem_log', $data_log);
}

/**
 * Lấy số liệu thống kê tổng quan trạng thái Robot hiển thị trên Widget Trang Chủ
 */
/* 
function Obj_get_bot_dashboard_stats()
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    $stats = array(
        'ntotal_clients'   => 0,
        'nactive_bots'     => 0,
        'ftotal_balance'   => 0,
        'nexpired_license' => 0
    );
    
    // 1. Tổng số tài khoản khách hàng đăng ký sử dụng hệ thống
    $str_sql1 = " SELECT COUNT(nid) as total FROM " . Fget_ap_table('tbot_client') . " WHERE cdel = '0' ";
    $query1   = $obj_helper->db->query($str_sql1)->row_array();
    $stats['ntotal_clients'] = isset($query1['total']) ? (int)$query1['total'] : 0;
    
    // 2. Số lượng bot đang ở trạng thái Khởi chạy trực tuyến (cbot_status = '1')
    $str_sql2 = " SELECT COUNT(nid) as total FROM " . Fget_ap_table('tbot_client') . " WHERE cbot_status = '1' AND cdel = '0' ";
    $query2   = $obj_helper->db->query($str_sql2)->row_array();
    $stats['nactive_bots'] = isset($query2['total']) ? (int)$query2['total'] : 0;
    
    // 3. Tổng số vốn quỹ (Balance) đang quản lý thực tế trên toàn hệ thống
    $str_sql3 = " SELECT SUM(fbalance) as total_bal FROM " . Fget_ap_table('tbot_client') . " WHERE cdel = '0' ";
    $query3   = $obj_helper->db->query($str_sql3)->row_array();
    $stats['ftotal_balance'] = isset($query3['total_bal']) ? round($query3['total_bal'], 2) : 0;
    
    // 4. Số lượng giấy phép quá hạn tính đến thời điểm hiện tại của MySQL (CURRENT_DATE())
    $str_sql4 = " SELECT COUNT(nid) as total FROM " . Fget_ap_table('tbot_client') . " WHERE dlicense_expiry < CURRENT_DATE() AND cdel = '0' ";
    $query4   = $obj_helper->db->query($str_sql4)->row_array();
    $stats['nexpired_license'] = isset($query4['total']) ? (int)$query4['total'] : 0;
    
    return $stats;
}
*/

/**
 * 1. Lấy chỉ số thống kê tổng quan (Top 4 khối Widget) trên Dashboard
 */
function Obj_get_bot_dashboard_stats($n_user_id = 0, $c_role = 'admin')
{
    $obj_helper =& get_instance();
    $obj_helper->load->database();

    // Thiết lập chuỗi điều kiện lọc động theo phân cấp quyền
    $str_where_role = "";
    if($c_role == 'sale') {
        $str_where_role = " AND u.nparent_id = " . (int)$n_user_id;
    }

    $str_sql = " SELECT 
                    COUNT(c.nid) as ntotal_clients,
                    SUM(CASE WHEN c.cbot_status = '1' THEN 1 ELSE 0 END) as nactive_bots,
                    SUM(c.fbalance) as ftotal_balance,
                    SUM(CASE WHEN c.fequity IS NULL OR c.fequity = 0.00 THEN c.fbalance ELSE c.fequity END) as ftotal_equity,
                    SUM(CASE WHEN c.dlicense_expiry < CURDATE() THEN 1 ELSE 0 END) as nexpired_license,
                    SUM(CASE WHEN c.fdrawdown < 10.00 THEN 1 ELSE 0 END) as n_safe_count,
                    SUM(CASE WHEN c.fdrawdown >= 10.00 AND c.fdrawdown < 30.00 THEN 1 ELSE 0 END) as n_warning_count,
                    SUM(CASE WHEN c.fdrawdown >= 30.00 THEN 1 ELSE 0 END) as n_danger_count
                 FROM " . Fget_ap_table('tbot_client') . " c 
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON c.nuser_id = u.nid
                 WHERE c.cdel = '0' " . $str_where_role;

    $row = $obj_helper->db->query($str_sql)->row_array();
    return array(
        'ntotal_clients'   => isset($row['ntotal_clients']) ? (int)$row['ntotal_clients'] : 0,
        'nactive_bots'     => isset($row['nactive_bots']) ? (int)$row['nactive_bots'] : 0,
        'ftotal_balance'   => isset($row['ftotal_balance']) ? (double)$row['ftotal_balance'] : 0.00,
        'ftotal_equity'    => isset($row['ftotal_equity']) ? (double)$row['ftotal_equity'] : 0.00,
        'nexpired_license' => isset($row['nexpired_license']) ? (int)$row['nexpired_license'] : 0,
        'n_safe_count'     => isset($row['n_safe_count']) ? (int)$row['n_safe_count'] : 0,
        'n_warning_count'  => isset($row['n_warning_count']) ? (int)$row['n_warning_count'] : 0,
        'n_danger_count'   => isset($row['n_danger_count']) ? (int)$row['n_danger_count'] : 0
    );
}

/**
 * 2 Lấy danh sách Top tài khoản có LỢI NHUẬN DƯƠNG (Profit % > 0) & Top tài khoản đang GỒNG LỖ ÂM (Drawdown % > 0) cao nhấtcao nhất hệ thống
 */
function Obj_get_top_profit_accounts($n_limit = 5, $n_user_id = 0, $c_role = 'admin')
{
    $obj_helper =& get_instance();
    $obj_helper->load->database();

    $str_where_role = "";
    if($c_role == 'sale') {
        $str_where_role = " AND u.nparent_id = " . (int)$n_user_id;
    }

    $str_sql = " SELECT c.cmt5_account, c.fprofit, c.fbalance, u.cfullname,
                        IF(c.fbalance > 0, ROUND((c.fprofit / c.fbalance) * 100, 2), 0.00) as fprofit_percent
                 FROM " . Fget_ap_table('tbot_client') . " c
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON c.nuser_id = u.nid
                 WHERE c.cdel = '0' AND c.cbot_status = '1' AND c.fprofit > 0 " . $str_where_role . "
                 ORDER BY c.fprofit DESC LIMIT " . (int)$n_limit;

    return $obj_helper->db->query($str_sql)->result_array();
}

function Obj_get_top_drawdown_accounts($n_limit = 5, $n_user_id = 0, $c_role = 'admin')
{
    $obj_helper =& get_instance();
    $obj_helper->load->database();

    $str_where_role = "";
    if($c_role == 'sale') {
        $str_where_role = " AND u.nparent_id = " . (int)$n_user_id;
    }

    $str_sql = " SELECT c.cmt5_account, c.fdrawdown, u.cfullname 
                 FROM " . Fget_ap_table('tbot_client') . " c
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON c.nuser_id = u.nid
                 WHERE c.cdel = '0' AND c.cbot_status = '1' AND c.fdrawdown > 0 " . $str_where_role . "
                 ORDER BY c.fdrawdown DESC LIMIT " . (int)$n_limit;

    return $obj_helper->db->query($str_sql)->result_array();
}

/**
 * 3. Lấy 5 tài khoản có tương tác kiểm tra License hoặc update tick gần nhất cho trang chủ
 */
function Obj_get_recent_connected_clients($n_limit = 5, $n_user_id = 0, $c_role = 'admin')
{
    $obj_helper =& get_instance();
    $obj_helper->load->database();

    $str_where_role = "";
    if($c_role == 'sale') {
        $str_where_role = " AND u.nparent_id = " . (int)$n_user_id;
    }

    $str_sql = " SELECT c.cmt5_account, c.fbalance, c.fdrawdown, c.cbot_status, u.cfullname,
                        IF(c.fequity IS NULL OR c.fequity = 0.00, c.fbalance, c.fequity) as fequity
                 FROM " . Fget_ap_table('tbot_client') . " c
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON c.nuser_id = u.nid
                 WHERE c.cdel = '0' " . $str_where_role . "
                 ORDER BY c.ddate_updated DESC, c.nid DESC LIMIT " . (int)$n_limit;

    return $obj_helper->db->query($str_sql)->result_array();
}

/**
 * 4. Lấy nhật ký kết nối API/Hệ thống thời gian thực từ bảng ea_tsystem_log
 Đối với phần Log bảo mật, khi Sale hành động tạo/sửa cấu hình thì hệ thống đã ghi nhận nuser_id chính là ID của Sale. Nên câu SQL ta sẽ lọc theo l.nuser_id
 */
function Obj_get_bot_system_activities($n_limit = 5, $n_user_id = 0, $c_role = 'admin')
{
    $obj_helper =& get_instance();
    $obj_helper->load->database();

    $str_where_role = "";
    if($c_role == 'sale') {
        $str_where_role = " WHERE l.nuser_id = " . (int)$n_user_id;
    }

    $str_sql = " SELECT l.caction as action, l.ctable_name as title, l.ccontent_log as description, l.ddate_created as time 
                 FROM " . Fget_ap_table('tsystem_log') . " l " . $str_where_role . "
                 ORDER BY l.nid DESC LIMIT " . (int)$n_limit;

    $res = $obj_helper->db->query($str_sql)->result_array();
    if(empty($res)) return array();
    
    $arr_result = array();
    foreach($res as $row) {
        $arr_result[] = array(
            'action' => $row['action'],
            'title'  => $row['title'],
            'desc'   => substr(strip_tags($row['description']), 0, 80),
            'time'   => $row['time']
        );
    }
    return $arr_result; 
}

/**
 * Đếm tổng số tài khoản nội bộ (Admin/Bác sĩ/Trợ lý) dựa theo bộ lọc tĩnh
 */
function Obj_get_staff_count($str_where_clause)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    $str_query = ' SELECT COUNT(nid) as total_rows FROM ' . Fget_ap_table('tuser') . $str_where_clause;
    $obj_result = $obj_helper->db->query($str_query);  
    $row = $obj_result->row_array();
    return isset($row['total_rows']) ? (int)$row['total_rows'] : 0;
}

/**
 * Lấy danh sách tài khoản nội bộ phân trang (Chỉ hiển thị vai trò quản trị/y tế, loại trừ bệnh nhân)
 */
function Obj_get_staff_pagination($str_where_clause, $n_start_row, $n_row_per_page)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    // TỐI ƯU SELECT: Chỉ lấy đích danh các trường cần render trên bảng danh sách
    $str_query = ' SELECT nid, cuserid, cfullname, cemail, chandphone, crole, cstatus ';
    $str_query .= ' FROM ' . Fget_ap_table('tuser') . $str_where_clause;
    $str_query .= ' ORDER BY nid DESC ';
    $str_query .= ' LIMIT ' . (int)$n_start_row . ', ' . (int)$n_row_per_page;
    
    $obj_result = $obj_helper->db->query($str_query);  
    return $obj_result->result_array();
}

/**
 * Lấy thông tin chi tiết một tài khoản nhân sự phục vụ sửa đổi (Edit mode)
 */
function Obj_get_staff_row($nid)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    $str_query = ' SELECT * FROM ' . Fget_ap_table('tuser') . ' WHERE nid = ' . (int)$nid;
    $obj_result = $obj_helper->db->query($str_query);  
    return $obj_result->row_array();
}

/**
 * Lấy thông tin chi tiết một tài khoản Client kết hợp dữ liệu bảng ea_tuser (Edit mode)
 */
function Obj_get_bot_client_row($nid)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    // Sử dụng SQL thuần bọc Fget_ap_table() kết hợp INNER JOIN căn lề thẳng hàng tăm tắp
    $str_sql = " SELECT c.*, u.cfullname, u.cuserid, u.cemail, u.chandphone 
                 FROM " . Fget_ap_table('tbot_client') . " c 
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON c.nuser_id = u.nid 
                 WHERE c.nid = " . (int)$nid;
                 
    $obj_result = $obj_helper->db->query($str_sql);  
    return $obj_result->row_array();
}

/**
 * Lấy thông tin cấu hình tham số đầu vào (Inputs) của robot theo ID Client
 */
function Obj_get_bot_settings_row($n_client_id)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    $str_sql = " SELECT * FROM " . Fget_ap_table('tbot_settings') . " WHERE nclient_id = " . (int)$n_client_id;
    $obj_result = $obj_helper->db->query($str_sql);  
    return $obj_result->row_array();
}

/**
 * Đếm tổng số lượng tài khoản chạy Bot dựa theo bộ lọc tĩnh phục vụ phân trang (Tối ưu SELECT)
 */
function Obj_get_bot_client_count($str_where_clause)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    // Chỉ select COUNT(c.nid) để MySQL xử lý nhanh nhất giống hàm Obj_get_patient_list_count
    $str_sql = " SELECT COUNT(c.nid) as total_rows 
                 FROM " . Fget_ap_table('tbot_client') . " c 
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON c.nuser_id = u.nid " . $str_where_clause;
                 
    $obj_result = $obj_helper->db->query($str_sql);  
    $row = $obj_result->row_array();
    return isset($row['total_rows']) ? (int)$row['total_rows'] : 0;
}

/**
 * Lấy danh sách tài khoản chạy Bot giới hạn phân trang phục vụ Listview (Tối ưu trường hiển thị)
 */
function Obj_get_bot_client_pagination($str_where_clause, $n_start_row, $n_row_per_page)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();

    // ĐỒNG BỘ TẠI ĐÂY: Thêm trường tính toán Equity thông minh khớp 100% với Trang Chủ
    $str_sql = " SELECT c.nid, c.cmt5_account, c.clicense_key, c.dlicense_expiry, c.fbalance, c.fdrawdown,
                        IF(c.fequity IS NULL OR c.fequity = 0.00, c.fbalance, c.fequity) as fequity, 
                        c.cbot_status, u.cfullname, u.cuserid 
                 FROM " . Fget_ap_table('tbot_client') . " c 
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON c.nuser_id = u.nid " . $str_where_clause . " 
                 ORDER BY c.nid DESC 
                 LIMIT " . (int)$n_start_row . ", " . (int)$n_row_per_page;

    $obj_result = $obj_helper->db->query($str_sql);  
    return $obj_result->result_array();
}

/**
 * Truy vấn kiểm tra chứng thực License giao dịch thời gian thực cho EA (Bot API Mode)
 */
function Obj_get_bot_licensing_info($str_license, $str_account)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    // Đổi c.* thành chỉ định rõ nét trường c.nid để tách biệt khóa chính với bảng settings
    $str_sql = " SELECT c.nid, c.cmt5_account, c.clicense_key, c.dlicense_expiry, c.cbot_status, s.* FROM " . Fget_ap_table('tbot_client') . " c 
                 INNER JOIN " . Fget_ap_table('tbot_settings') . " s ON c.nid = s.nclient_id 
                 WHERE c.clicense_key = '" . $obj_helper->db->escape_str($str_license) . "' 
                   AND c.cmt5_account = '" . $obj_helper->db->escape_str($str_account) . "' 
                   AND c.cdel         = '0' 
                 LIMIT 1 ";
                
    $obj_result = $obj_helper->db->query($str_sql); 
    return $obj_result->row_array();
}

/**
 * Đếm tổng số lượt cấp/gia hạn bản quyền phục vụ phân trang lịch sử License
 */
function Obj_get_license_history_count($str_where_clause)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    $str_sql = " SELECT COUNT(h.nid) as total_rows 
                 FROM " . Fget_ap_table('tbot_license_history') . " h 
                 INNER JOIN " . Fget_ap_table('tbot_client') . " c ON h.nclient_id = c.nid 
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON c.nuser_id = u.nid " . $str_where_clause;
                 
    $row = $obj_helper->db->query($str_sql)->row_array();
    return isset($row['total_rows']) ? (int)$row['total_rows'] : 0;
}

/**
 * Lấy danh sách lịch sử cấp/gia hạn License giới hạn phân trang
 */
function Obj_get_license_history_pagination($str_where_clause, $n_start_row, $n_row_per_page)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    $str_sql = " SELECT h.*, u.cfullname, u.cuserid 
                 FROM " . Fget_ap_table('tbot_license_history') . " h 
                 INNER JOIN " . Fget_ap_table('tbot_client') . " c ON h.nclient_id = c.nid 
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON c.nuser_id = u.nid " . $str_where_clause . " 
                 ORDER BY h.nid DESC 
                 LIMIT " . (int)$n_start_row . ", " . (int)$n_row_per_page;
                 
    return $obj_helper->db->query($str_sql)->result_array();
}

/**
 * Đếm tổng số dòng nhật ký bảo mật phục vụ phân trang (Module Bảo mật hệ thống)
 */
function Obj_get_system_log_count($str_where_clause)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    // Sử dụng cơ chế Fget_ap_table() để bao bọc tên bảng chuẩn hệ thống
    $str_sql = " SELECT COUNT(l.nid) as total_rows 
                 FROM " . Fget_ap_table('tsystem_log') . " l 
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON l.nuser_id = u.nid " . $str_where_clause;
                 
    $row = $obj_helper->db->query($str_sql)->row_array();
    return isset($row['total_rows']) ? (int)$row['total_rows'] : 0;
}

/**
 * Lấy danh sách nhật ký bảo mật giới hạn phân trang kết hợp INNER JOIN lấy danh tính user
 */
function Obj_get_system_log_pagination($str_where_clause, $n_start_row, $n_row_per_page)
{
    $obj_helper =& get_instance(); 
    $obj_helper->load->database();
    
    $str_sql = " SELECT l.*, u.cuserid, u.cfullname 
                 FROM " . Fget_ap_table('tsystem_log') . " l 
                 INNER JOIN " . Fget_ap_table('tuser') . " u ON l.nuser_id = u.nid " . $str_where_clause . " 
                 ORDER BY l.nid DESC 
                 LIMIT " . (int)$n_start_row . ", " . (int)$n_row_per_page;
                 
    return $obj_helper->db->query($str_sql)->result_array();
}