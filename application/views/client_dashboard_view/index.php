<?php 
	$this->load->view('header');
	$this->load->view('header_end');
	//$this->load->view('modules/mod_header'); 
?>
<div class="right_col" role="main">
    <div class="">
        <div class="clearfix"></div>
        <div class="row">
            <div class="col-md-12 col-sm-12">
                <div class="x_panel qcare-form-panel">
                    <div class="x_title">
                        <h2 class="qcare-form-main-title">
                            <i class="fa fa-dashboard"></i> BẢNG ĐIỀU KHIỂN KHÁCH HÀNG (CLIENT DASHBOARD)
                        </h2>
                        
                        <div class="pull-right" style="display: flex; align-items: center; margin-top: 5px;">
                            <span style="margin-right: 15px; font-size: 15px; font-weight: 500; color: #1abb9c;">
                                <i class="fa fa-user-circle-o"></i> Xin chào, <strong><?php echo Fget_userdata('session_user_full_name'); ?></strong>
                            </span>
                            <a href="<?php echo base_url().'index.php/do_login_client/f_logout'; ?>" class="btn btn-sm btn-default" style="margin: 0;">
                                <i class="fa fa-sign-out"></i> Đăng xuất
                            </a>
                        </div>
                        
                        <div class="clearfix"></div>
                    </div>
                    <div class="x_content">
                        <br />
                        <?php if($m_message != ''): ?>
                            <div class="alert alert-<?php echo isset($msg_type) ? $msg_type : 'danger'; ?> alert-dismissible" role="alert">
                                <strong>Thông báo:</strong> <?php echo $m_message; ?>
                            </div>
                        <?php endif; ?>

                        <form name="form_status" method="post" action="<?php echo $link_page; ?>" class="form-horizontal form-label-left" style="background-color: #f8d7da; padding: 20px; border-radius: 8px; margin-bottom: 30px; border: 1px solid #f5c6cb;">
                            <input type="hidden" name="hidden_button" value="btn_save_status" />
                            <h5 style="color: #721c24; font-weight: bold; margin-bottom: 15px;"><i class="fa fa-warning"></i> ĐIỀU KHIỂN BOT KHẨN CẤP</h5>
                            
                            <div class="item form-group">
                                <label class="col-form-label col-md-3 col-sm-3 label-align" style="color: #721c24;">Trạng thái chạy lệnh <span class="required">*</span></label>
                                <div class="col-md-6 col-sm-6">
                                    <select name="cbof_cbot_status" class="form-control">
                                        <option value="1" <?php echo (isset($bot_info['cbot_status']) && $bot_info['cbot_status'] == '1') ? 'selected' : ''; ?>>1: Khởi chạy từ xa (EA được phép mở lệnh)</option>
                                        <option value="0" <?php echo (isset($bot_info['cbot_status']) && $bot_info['cbot_status'] == '0') ? 'selected' : ''; ?>>0: Tạm ngừng từ xa (EA lập tức chặn vào lệnh)</option>
                                    </select>
                                </div>
                                <div class="col-md-3 col-sm-3">
                                    <button type="submit" class="btn btn-danger"><i class="fa fa-power-off"></i> CẬP NHẬT TRẠNG THÁI</button>
                                </div>
                            </div>
                        </form>

                        <form class="form-horizontal form-label-left">
                            <h5 class="qcare-form-section-title section-blue">I. THÔNG TIN KHÁCH HÀNG & BẢN QUYỀN LICENSE</h5>
                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Tên đăng nhập</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" value="<?php echo isset($bot_info['cuserid']) ? $bot_info['cuserid'] : ''; ?>" class="form-control qcare-form-input-readonly" readonly>
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Mật khẩu Web</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="password" value="********" class="form-control qcare-form-input-readonly" readonly>
                                </div>
                            </div>
                            
                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Họ tên khách hàng</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" value="<?php echo isset($bot_info['cfullname']) ? $bot_info['cfullname'] : ''; ?>" class="form-control qcare-form-input-readonly" readonly>
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Số TK MT5</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" value="<?php echo isset($bot_info['cmt5_account']) ? $bot_info['cmt5_account'] : ''; ?>" class="form-control qcare-form-input-readonly" readonly>
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Mã License Key</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" value="<?php echo isset($bot_info['clicense_key']) ? $bot_info['clicense_key'] : ''; ?>" class="form-control qcare-form-input-readonly" readonly style="font-weight: bold; color: #d9534f;">
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Ngày hết hạn</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="date" value="<?php echo isset($bot_info['dlicense_expiry']) ? date('Y-m-d', strtotime($bot_info['dlicense_expiry'])) : ''; ?>" class="form-control qcare-form-input-readonly" readonly>
                                </div>
                            </div>

                            <h5 class="qcare-form-section-title section-teal">II. THIẾT LẬP THAM SỐ CHIẾN LƯỢC ROBOT TRADING</h5>
                            <div class="alert alert-info">
                                <i class="fa fa-info-circle"></i> Các thông số quản lý vốn và khoảng cách lưới dưới đây chỉ ở chế độ <strong>Xem (Read-only)</strong>. Vui lòng liên hệ Admin nếu bạn muốn thay đổi chiến lược giao dịch.
                            </div>
                            
                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Initial Lot</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['finitial_lot']) ? $bot_info['finitial_lot'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-1 col-sm-1 label-align">Lot Multi</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['flot_multi']) ? $bot_info['flot_multi'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-1 col-sm-1 label-align">Max Orders</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['nmax_orders']) ? $bot_info['nmax_orders'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Chế độ TP Mode</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo (isset($bot_info['ntp_mode']) && $bot_info['ntp_mode'] == '1') ? '1: Theo USD ($)' : '0: Theo Pip'; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-1 col-sm-1 label-align">TP Pips</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['ftp_pips']) ? $bot_info['ftp_pips'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-1 col-sm-1 label-align">TP USD ($)</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['ftp_usd']) ? $bot_info['ftp_usd'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">RSI Period</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['nrsi_period']) ? $bot_info['nrsi_period'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-1 col-sm-1 label-align">RSI TF</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['crsi_tf']) ? $bot_info['crsi_tf'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-1 col-sm-1 label-align">Magic Num</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['nmagic']) ? $bot_info['nmagic'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                            </div>

                            <h5 class="qcare-form-section-title section-amber">III. KHUNG GIỜ GIAO DỊCH & XÁC NHẬN CHỐNG BÃO GIÁ</h5>
                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Sử dụng bộ lọc giờ</label>
                                <div class="col-md-2 col-sm-2 pt-2">
                                    <input type="checkbox" <?php echo (isset($bot_info['cuse_time_filter']) && $bot_info['cuse_time_filter'] == '1') ? 'checked' : ''; ?> disabled style="transform: scale(1.3);">
                                </div>
                                <label class="col-form-label col-md-1 col-sm-1 label-align">Giờ bắt đầu</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['nstart_hour_local']) ? $bot_info['nstart_hour_local'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-1 col-sm-1 label-align">Giờ kết thúc</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['nend_hour_local']) ? $bot_info['nend_hour_local'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Phút khóa sát phiên</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['nmin_before_close']) ? $bot_info['nmin_before_close'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Xác nhận kép từ lệnh</label>
                                <div class="col-md-4 col-sm-4">
                                    <div class="input-group">
                                        <span class="input-group-addon" style="padding: 6px 12px; font-size: 14px; background-color: #eee; border: 1px solid #ccc;">Từ lệnh thứ N =</span>
                                        <input type="text" value="<?php echo isset($bot_info['nconfirm_from_order']) ? $bot_info['nconfirm_from_order'] : ''; ?>" class="form-control" disabled>
                                    </div>
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Bật chức năng chốt cặp</label>
                                <div class="col-md-1 col-sm-1 pt-2">
                                    <input type="checkbox" <?php echo (isset($bot_info['cpair_close_bat_tat']) && $bot_info['cpair_close_bat_tat'] == '1') ? 'checked' : ''; ?> disabled style="transform: scale(1.3);">
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Áp dụng từ tầng</label>
                                <div class="col-md-1 col-sm-1">
                                    <input type="text" value="<?php echo isset($bot_info['npair_close_tu_lenh']) ? $bot_info['npair_close_tu_lenh'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Lợi nhuận cặp ($)</label>
                                <div class="col-md-1 col-sm-1">
                                    <input type="text" value="<?php echo isset($bot_info['fpair_close_so_usd']) ? $bot_info['fpair_close_so_usd'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                                <label class="col-form-label col-md-1 col-sm-1 label-align">Chốt dần về</label>
                                <div class="col-md-1 col-sm-1 pt-2">
                                    <input type="checkbox" <?php echo (isset($bot_info['cpair_close_chot_dan_ve']) && $bot_info['cpair_close_chot_dan_ve'] == '1') ? 'checked' : ''; ?> disabled style="transform: scale(1.3);">
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Basket Trailing (%)</label>
                                <div class="col-md-2 col-sm-2">
                                    <input type="text" value="<?php echo isset($bot_info['fbasket_tp_phan_tram']) ? $bot_info['fbasket_tp_phan_tram'] : ''; ?>" class="form-control text-center" disabled>
                                </div>
                            </div>

                            <h5 class="qcare-form-section-title" style="background: #73879c; color: #fff;">IV. CẤU HÌNH KHOẢNG CÁCH LƯỚI GRID ĐỘNG (PIPS)</h5>
                            <div class="item form-group" style="background: #f2f5f7; padding: 15px; border-radius: 6px; border: 1px solid #e0e4e6;">
                                <div class="row" style="margin: 0;">
                                    <?php 
                                    for($i=1; $i<=25; $i++): 
                                    ?>
                                        <div class="col-md-2 col-sm-3 col-xs-6" style="margin-bottom: 12px;">
                                            <div class="input-group" style="margin-bottom: 0;">
                                                <span class="input-group-addon" style="padding:0;line-height: 38px;height: 38px;width: 38px; background: #34495e; color: #fff; border: 1px solid #34495e; font-weight: bold; font-size: 12px;">G<?php echo $i; ?></span>
                                                <input type="text" value="<?php echo isset($arr_steps['G'.$i]) ? $arr_steps['G'.$i] : ''; ?>" class="form-control input-sm text-center" style="font-weight: bold; color: #73879c;" disabled>
                                            </div>
                                        </div>
                                    <?php endfor; ?>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<?php
	//$this->load->view('modules/mod_footer');
	$this->load->view('footer');
?>