<div class="right_col" role="main">
    <div class="">
        <div class="clearfix"></div>
        <div class="row">
            <div class="col-md-12 col-sm-12">
                <div class="x_panel qcare-form-panel">
                    <div class="x_title">
                        <h2 class="qcare-form-main-title"><i class="fa fa-sliders"></i> <?php echo $lbl_form_title; ?></h2>
                        <div class="clearfix"></div>
                    </div>
                    <div class="x_content">
                        <br />
                        <?php if($m_message != ''): ?>
                            <div class="alert alert-danger alert-dismissible" role="alert">
                                <strong>Lưu ý:</strong> <?php echo $m_message; ?>
                            </div>
                        <?php endif; ?>

                        <form name="form_main" method="post" action="<?php echo $link_page; ?>" class="form-horizontal form-label-left">
                            
                            <h5 class="qcare-form-section-title section-blue">I. THÔNG TIN KHÁCH HÀNG & BẢN QUYỀN LICENSE</h5>
                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Tên đăng nhập <span class="required">*</span></label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" name="txt_cuserid" value="<?php echo $txt_cuserid; ?>" required="required" class="form-control <?php echo ($event == 'edit') ? 'qcare-form-input-readonly' : ''; ?>" <?php echo ($event == 'edit') ? 'readonly' : ''; ?> placeholder="Ví dụ: hoangle88" oninput="this.value = this.value.toLowerCase().replace(/[^a-z0-9_]/g, '');">
                                </div>
								<label class="col-form-label col-md-2 col-sm-2 label-align">Mật khẩu Web</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="password" name="txt_cpassword" value="" class="form-control" placeholder="<?php echo ($event == 'edit') ? 'Bỏ trống nếu không đổi' : 'Mật khẩu đăng nhập vào EA HUB'; ?>">
                                </div>                             
                            </div>
                            
                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Họ tên khách hàng</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" name="txt_cfullname" value="<?php echo $txt_cfullname; ?>" class="form-control" placeholder="Nhập họ tên đầy đủ">
                                </div>
								<label class="col-form-label col-md-2 col-sm-2 label-align">Số TK MT5 <span class="required">*</span></label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" name="txt_cmt5_account" value="<?php echo $txt_cmt5_account; ?>" required="required" class="form-control" placeholder="Ví dụ: 8824511" oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                                </div>  
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Tên sàn Trade <span class="required">*</span></label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" name="txt_cbroker_name" value="<?php echo $txt_cbroker_name; ?>" required="required" class="form-control" placeholder="Ví dụ: Exness, IC Markets, XM...">
                                </div>
								<label class="col-form-label col-md-2 col-sm-2 label-align">Mật khẩu MT5 <span class="required">*</span></label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" name="txt_cmt5_password" value="<?php echo $txt_cmt5_password; ?>" required="required" class="form-control" placeholder="Mật khẩu giao dịch của MT5">
                                </div>
                            </div>

                            <!-- CHỌN PHIÊN BẢN BOT EA -->
                            <div class="item form-group">
								<label class="col-form-label col-md-2 col-sm-2 label-align" style="color: #26b99a; font-weight: bold;">Phiên bản Bot EA <span class="required">*</span></label>
								<div class="col-md-3 col-sm-3">
									<select name="cbof_cbot_version" id="cbof_cbot_version" class="form-control" style="border: 2px solid #26b99a; font-weight: bold; color: #16a085;">
										<option value="Onefxhub_v38" <?php echo (isset($cbof_cbot_version) && $cbof_cbot_version == 'Onefxhub_v38') ? 'selected' : ''; ?>>Onefxhub V38.38 (RPA + Global Grid + T1/T2 + DD Lock)</option>
										<option value="RSI6_v33" <?php echo (isset($cbof_cbot_version) && $cbof_cbot_version == 'RSI6_v33') ? 'selected' : ''; ?>>Grid + Bảo vệ sát phiên (V33)</option>
										<option value="RSI6_v32" <?php echo (isset($cbof_cbot_version) && $cbof_cbot_version == 'RSI6_v32') ? 'selected' : ''; ?>>Grid tiêu chuẩn (V32)</option>
									</select>
								</div>
								<label class="col-form-label col-md-2 col-sm-2 label-align">Trạng thái chạy lệnh</label>
								<div class="col-md-3 col-sm-3">
									<select name="cbof_cbot_status" class="form-control">
										<option value="1" <?php echo ($cbof_cbot_status == '1') ? 'selected' : ''; ?>>Khởi chạy từ xa (Cho phép mở lệnh)</option>
										<option value="0" <?php echo ($cbof_cbot_status == '0') ? 'selected' : ''; ?>>Tạm ngừng từ xa (Chặn vào lệnh)</option>
									</select>
								</div>
							</div>

                            <div class="item form-group">                              
								<label class="col-form-label col-md-2 col-sm-2 label-align">Mã License Key</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" name="txt_clicense_key" value="<?php echo $txt_clicense_key; ?>" required="required" class="form-control qcare-form-input-readonly" readonly placeholder="Mã tự sinh">
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Ngày hết hạn</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="date" name="txt_dlicense_expiry" value="<?php echo $txt_dlicense_expiry; ?>" required="required" class="form-control">
                                </div>
                            </div>

                            <!-- ========================================================================= -->
                            <!-- KHỐI CẤU HÌNH CHO BOT V32 / V33 (Grid Tiêu chuẩn & Bảo vệ sát phiên)      -->
                            <!-- ========================================================================= -->
                            <div id="section_bot_v33" style="<?php echo (isset($cbof_cbot_version) && $cbof_cbot_version == 'Onefxhub_v38') ? 'display: none;' : ''; ?>">
                                
                                <h5 class="qcare-form-section-title section-teal">II. THIẾT LẬP THAM SỐ CHIẾN LƯỢC ROBOT TRADING (V32/V33)</h5>
                                
                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Initial Lot</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.01" min="0.01" name="txt_finitial_lot" value="<?php echo $txt_finitial_lot; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">Lot Multi</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.01" min="1.0" name="txt_flot_multi" value="<?php echo $txt_flot_multi; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">Max Orders</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" min="1" max="50" name="txt_nmax_orders" value="<?php echo $txt_nmax_orders; ?>" class="form-control">
                                    </div>
                                </div>

                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Chế độ TP Mode</label>
                                    <div class="col-md-2 col-sm-2">
                                        <select name="cbof_ntp_mode" id="cbof_ntp_mode" class="form-control">
                                            <option value="0" <?php echo ($cbof_ntp_mode == '0') ? 'selected' : ''; ?>>0: Theo Pip</option>
                                            <option value="1" <?php echo ($cbof_ntp_mode == '1') ? 'selected' : ''; ?>>1: Theo USD ($)</option>
                                        </select>
                                    </div>
                                    
                                    <div id="div_tp_pips" style="display: contents;">
                                        <label class="col-form-label col-md-1 col-sm-1 label-align">TP Pips</label>
                                        <div class="col-md-2 col-sm-2">
                                            <input type="number" step="0.1" name="txt_ftp_pips" value="<?php echo $txt_ftp_pips; ?>" class="form-control">
                                        </div>
                                    </div>
                                    
                                    <div id="div_tp_usd" style="display: contents;">
                                        <label class="col-form-label col-md-1 col-sm-1 label-align">TP USD ($)</label>
                                        <div class="col-md-2 col-sm-2">
                                            <input type="number" step="0.1" name="txt_ftp_usd" value="<?php echo $txt_ftp_usd; ?>" class="form-control">
                                        </div>
                                    </div>
                                </div>

                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">RSI Period</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" min="1" name="txt_nrsi_period" value="<?php echo $txt_nrsi_period; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">RSI TF</label>
                                    <div class="col-md-2 col-sm-2">
                                        <select name="cbof_crsi_tf" class="form-control">
                                            <option value="PERIOD_M1" <?php echo ($cbof_crsi_tf == 'PERIOD_M1') ? 'selected' : ''; ?>>M1</option>
                                            <option value="PERIOD_M5" <?php echo ($cbof_crsi_tf == 'PERIOD_M5') ? 'selected' : ''; ?>>M5</option>
                                            <option value="PERIOD_M15" <?php echo ($cbof_crsi_tf == 'PERIOD_M15') ? 'selected' : ''; ?>>M15</option>
                                            <option value="PERIOD_H1" <?php echo ($cbof_crsi_tf == 'PERIOD_H1') ? 'selected' : ''; ?>>H1</option>
                                        </select>
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">Magic Num</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="text" name="txt_nmagic" value="<?php echo $txt_nmagic; ?>" class="form-control" oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title section-amber">III. KHUNG GIỜ GIAO DỊCH & XÁC NHẬN CHỐT BÃO GIÁ (V32/V33)</h5>
                                
                                <div class="item form-group" style="margin-top: 15px;">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align" style="font-weight: bold;">Sử dụng bộ lọc giờ</label>
                                    <div class="col-md-6 col-sm-6 pt-2">
                                        <label style="cursor: pointer; font-weight: normal; margin-top: 5px;">
                                            <input type="checkbox" name="cbof_cuse_time_filter" value="1" <?php echo ($cbof_cuse_time_filter == '1') ? 'checked' : ''; ?> style="width: 17px; height: 17px; vertical-align: middle; cursor: pointer;">
                                            <span class="text-muted" style="margin-left: 8px; font-size: 13px;">(Tích chọn: Bật lọc theo Phiên / Khung giờ | Bỏ chọn: Chạy 24/7)</span>
                                        </label>
                                    </div>
                                </div>

                                <div style="color: #00bcd4; font-size: 15px; font-weight: bold; border-bottom: 2px solid #00bcd4; padding-bottom: 8px; margin: 20px 0 15px 0;">
                                    <i class="fa fa-clock-o"></i> 4. KHU VỰC SETTING THỜI GIAN GIAO DỊCH
                                </div>

                                <div class="row" style="margin-bottom: 20px;">
                                    <!-- CỘT TRÁI: BOT SESSION -->
                                    <div class="col-md-6 col-sm-6 col-xs-12" style="padding-right: 15px; margin-bottom: 15px;">
                                        <label style="font-weight: bold; color: #2c3e50; font-size: 14px; margin-bottom: 8px; display: block;">Bot Session (Chọn các phiên chạy)</label>
                                        <div style="border: 1px solid #e2e8f0; border-radius: 6px; padding: 18px 20px; background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.02); min-height: 145px;">
                                            <div style="margin-bottom: 14px;">
                                                <label style="font-size: 13.5px; font-weight: 500; color: #333; cursor: pointer; display: block; margin: 0;">
                                                    <input type="checkbox" name="cbof_csession_asia" value="1" <?php echo ($cbof_csession_asia == '1') ? 'checked' : ''; ?> style="width: 17px; height: 17px; margin-right: 10px; vertical-align: middle; cursor: pointer;">
                                                    Sydney - Tokyo (Phiên Á: 05:00 - 14:00)
                                                </label>
                                            </div>
                                            <div style="margin-bottom: 14px;">
                                                <label style="font-size: 13.5px; font-weight: 500; color: #333; cursor: pointer; display: block; margin: 0;">
                                                    <input type="checkbox" name="cbof_csession_london" value="1" <?php echo ($cbof_csession_london == '1') ? 'checked' : ''; ?> style="width: 17px; height: 17px; margin-right: 10px; vertical-align: middle; cursor: pointer;">
                                                    London (Phiên Âu: 14:00 - 23:00)
                                                </label>
                                            </div>
                                            <div style="margin-bottom: 0;">
                                                <label style="font-size: 13.5px; font-weight: 500; color: #333; cursor: pointer; display: block; margin: 0;">
                                                    <input type="checkbox" name="cbof_csession_ny" value="1" <?php echo ($cbof_csession_ny == '1') ? 'checked' : ''; ?> style="width: 17px; height: 17px; margin-right: 10px; vertical-align: middle; cursor: pointer;">
                                                    New York (Phiên Mỹ: 19:00 - 04:00)
                                                </label>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- CỘT PHẢI: TRADE HOUR (ĐÃ ĐƯỢC FORMAT GIAO DIỆN CHUẨN) -->
                                    <div class="col-md-6 col-sm-6 col-xs-12" style="padding-left: 15px; margin-bottom: 15px;">
                                        <label style="font-weight: bold; color: #2c3e50; font-size: 14px; margin-bottom: 8px; display: block;">Trade Hour (Khung giờ giao dịch)</label>
                                        
                                        <!-- Khung 1 -->
                                        <div class="row" style="margin-left: -5px; margin-right: -5px; margin-bottom: 12px;">
                                            <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                                <div style="display: flex; align-items: stretch; width: 100%;">
                                                    <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Bắt Đầu</span>
                                                    <input type="time" name="txt_ctime_start_1" value="<?php echo $txt_ctime_start_1; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff;">
                                                </div>
                                            </div>
                                            <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                                <div style="display: flex; align-items: stretch; width: 100%;">
                                                    <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Kết Thúc</span>
                                                    <input type="time" name="txt_ctime_end_1" value="<?php echo $txt_ctime_end_1; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff;">
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Khung 2 -->
                                        <div class="row" style="margin-left: -5px; margin-right: -5px; margin-bottom: 12px;">
                                            <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                                <div style="display: flex; align-items: stretch; width: 100%;">
                                                    <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Bắt Đầu</span>
                                                    <input type="time" name="txt_ctime_start_2" value="<?php echo $txt_ctime_start_2; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff;">
                                                </div>
                                            </div>
                                            <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                                <div style="display: flex; align-items: stretch; width: 100%;">
                                                    <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Kết Thúc</span>
                                                    <input type="time" name="txt_ctime_end_2" value="<?php echo $txt_ctime_end_2; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff;">
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Khung 3 -->
                                        <div class="row" style="margin-left: -5px; margin-right: -5px; margin-bottom: 0;">
                                            <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                                <div style="display: flex; align-items: stretch; width: 100%;">
                                                    <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Bắt Đầu</span>
                                                    <input type="time" name="txt_ctime_start_3" value="<?php echo $txt_ctime_start_3; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff;">
                                                </div>
                                            </div>
                                            <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                                <div style="display: flex; align-items: stretch; width: 100%;">
                                                    <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Kết Thúc</span>
                                                    <input type="time" name="txt_ctime_end_3" value="<?php echo $txt_ctime_end_3; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff;">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <input type="hidden" name="txt_nstart_hour_local" value="<?php echo $txt_nstart_hour_local; ?>">
                                <input type="hidden" name="txt_nend_hour_local" value="<?php echo $txt_nend_hour_local; ?>">

                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Phút khóa sát phiên</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" min="0" name="txt_nmin_before_close" value="<?php echo $txt_nmin_before_close; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Xác nhận kép từ lệnh</label>
                                    <div class="col-md-4 col-sm-4">
                                        <div class="input-group">
                                            <span class="input-group-addon" style="padding: 6px 12px; font-size: 14px; font-weight: 400; line-height: 24px; color: #555; text-align: center; background-color: #eee; border: 1px solid #ccc; border-radius: 4px; border-top-right-radius: 0; border-bottom-right-radius: 0; border-right: 0;">Từ lệnh thứ N =</span>
                                            <input type="number" min="1" name="txt_nconfirm_from_order" value="<?php echo $txt_nconfirm_from_order; ?>" class="form-control" style="border-top-left-radius: 0; border-bottom-left-radius: 0;">
                                        </div>
                                    </div>
                                </div>

                                <div class="item form-group" style="background: #fff8e1; padding: 10px 0; border-radius: 4px; border: 1px solid #ffe082;">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align" style="color: #b78103; font-weight: bold;">Nhồi lệnh sát phiên</label>
                                    <div class="col-md-1 col-sm-1 pt-2">
                                        <input type="checkbox" name="cbof_callow_grid_near_end" value="1" <?php echo (isset($cbof_callow_grid_near_end) && $cbof_callow_grid_near_end == '1') ? 'checked' : ''; ?> style="transform: scale(1.3);">
                                    </div>
                                    <div class="col-md-8 col-sm-8 pt-2">
                                        <span class="text-muted" style="font-size: 12px; color: #8d6e63;"><i class="fa fa-info-circle"></i> <strong>Tích chọn:</strong> Cho phép Bot tiếp tục mở lệnh Grid khi > 8 lệnh trong 60 phút cuối phiên để kéo TP thoát lệnh nhanh.<br><i class="fa fa-info-circle" style="opacity:0"></i> <strong>Bỏ chọn:</strong> Khóa ngắt mở lệnh mới để bảo vệ an toàn.</span>
                                    </div>
                                </div>

                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Bật chức năng chốt cặp</label>
                                    <div class="col-md-1 col-sm-1 pt-2">
                                        <input type="checkbox" name="cbof_cpair_close_bat_tat" value="1" <?php echo ($cbof_cpair_close_bat_tat == '1') ? 'checked' : ''; ?> style="transform: scale(1.3);">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Áp dụng từ tầng</label>
                                    <div class="col-md-1 col-sm-1">
                                        <input type="number" min="2" name="txt_npair_close_tu_lenh" value="<?php echo $txt_npair_close_tu_lenh; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Lợi nhuận cặp ($)</label>
                                    <div class="col-md-1 col-sm-1">
                                        <input type="number" step="0.1" name="txt_fpair_close_so_usd" value="<?php echo $txt_fpair_close_so_usd; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">Chốt dần về</label>
                                    <div class="col-md-1 col-sm-1 pt-2">
                                        <input type="checkbox" name="cbof_cpair_close_chot_dan_ve" value="1" <?php echo ($cbof_cpair_close_chot_dan_ve == '1') ? 'checked' : ''; ?> style="transform: scale(1.3);">
                                    </div>
                                </div>

                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Basket Trailing (%)</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.1" min="0" name="txt_fbasket_tp_phan_tram" value="<?php echo $txt_fbasket_tp_phan_tram; ?>" class="form-control" placeholder="0: Tắt">
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title" style="background: #73879c; color: #fff;">IV. CẤU HÌNH KHOẢNG CÁCH LƯỚI GRID ĐỘNG (PIPS - V32/V33)</h5>
                                <div class="item form-group" style="background: #f2f5f7; padding: 15px; border-radius: 6px; border: 1px solid #e0e4e6;">
                                    <p class="text-muted" style="margin-left: 10px; font-weight: bold;"><i class="fa fa-info-circle"></i> Điền khoảng cách dịch chuyển của thị trường (Pips) tính từ L1 để kích hoạt tầng lệnh nhồi tiếp theo:</p>
                                    <div class="row" style="margin: 0;">
                                        <?php for($i=1; $i<=25; $i++): ?>
                                            <div class="col-md-2 col-sm-3 col-xs-6" style="margin-bottom: 12px;">
                                                <div class="input-group" style="margin-bottom: 0;">
                                                    <span class="input-group-addon" style="padding:0;line-height: 38px;height: 38px;width: 38px; background: #34495e; color: #fff; border: 1px solid #34495e; font-weight: bold; font-size: 12px;">G<?php echo $i; ?></span>
                                                    <input type="number" min="0" name="step_G<?php echo $i; ?>" value="<?php echo isset($arr_steps['G'.$i]) ? $arr_steps['G'.$i] : ($i * 10); ?>" class="form-control input-sm text-center" style="font-weight: bold; color: #2c3e50;">
                                                </div>
                                            </div>
                                        <?php endfor; ?>
                                    </div>
                                </div>

                            </div>
                            <!-- END SECTION V32 / V33 -->


                            <!-- ========================================================================= -->
                            <!-- KHỐI CẤU HÌNH DÀNH RIÊNG CHO ONEFXHUB V38 (RPA + GLOBAL + T1/T2 + DD LOCK)-->
                            <!-- ========================================================================= -->
                            <div id="section_bot_v38" style="<?php echo (isset($cbof_cbot_version) && $cbof_cbot_version == 'Onefxhub_v38') ? '' : 'display: none;'; ?>">
                                
                                <h5 class="qcare-form-section-title section-teal"><i class="fa fa-cubes"></i> II. VỐN, LOT & CHỐT LỜI LỆNH 1 (L1)</h5>
                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Lot lệnh 1 (L1)</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.01" min="0.01" name="v38_txt_finitial_lot" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_finitial_lot : '0.03'; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">Lot Multi</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.01" min="1.0" name="v38_txt_flot_multi" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_flot_multi : '1.50'; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">Max Orders</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" min="1" max="100" name="v38_txt_nmax_orders" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_nmax_orders : '26'; ?>" class="form-control">
                                    </div>
                                </div>

                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">TP riêng L1 (pip)</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.1" name="v38_txt_ftp_pips" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_ftp_pips : '10.0'; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">%YP lệnh 1</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.1" min="0" name="v38_txt_fbasket_tp_phan_tram" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_fbasket_tp_phan_tram : '0.0'; ?>" class="form-control" placeholder="0: Tắt">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Cộng spread vào TP L1</label>
                                    <div class="col-md-2 col-sm-2 pt-2">
                                        <input type="checkbox" name="cbat_cong_spread_tp" value="1" <?php echo ($cbat_cong_spread_tp == '1') ? 'checked' : ''; ?> style="transform: scale(1.3);">
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title section-blue"><i class="fa fa-shield"></i> III. T1/T2 CỤM LỆNH L2+ (pip, 1 giá = 10 pip)</h5>
                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">T1 kích hoạt / T2 đi tiếp (pip)</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.1" name="fkhoang_doi_sl" value="<?php echo $fkhoang_doi_sl; ?>" class="form-control" placeholder="25.0">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">T1: Khóa BE cụm (pip)</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.1" name="fso_pip_doi_sl" value="<?php echo $fso_pip_doi_sl; ?>" class="form-control" placeholder="15.0">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">T2: Trailing SL theo giá (pip)</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.1" name="fkhoang_trailing_sl" value="<?php echo $fkhoang_trailing_sl; ?>" class="form-control" placeholder="10.0">
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title" style="background: #e74c3c; color: #fff;"><i class="fa fa-lock"></i> IV. DD HEDGE LOCK (BẢO HIỂM CÂN LỆNH NET KHI DD CAO)</h5>
                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Bật DD Hedge Lock</label>
                                    <div class="col-md-1 col-sm-1 pt-2">
                                        <input type="checkbox" name="cbat_cat_dd" value="1" <?php echo ($cbat_cat_dd == '1') ? 'checked' : ''; ?> style="transform: scale(1.3);">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Ngưỡng DD% cân NET</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" step="0.1" min="0" max="100" name="fcat_dd_phan_tram" value="<?php echo $fcat_dd_phan_tram; ?>" class="form-control" placeholder="0: Chưa đặt">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Magic Hedge khóa DD</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="text" name="ndd_hedge_magic" value="<?php echo $ndd_hedge_magic; ?>" class="form-control" oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title section-teal"><i class="fa fa-line-chart"></i> V. TÍN HIỆU RSI VÀO L1 & MAGIC EA</h5>
                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Chu kỳ RSI (phải >= 2)</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" min="2" name="v38_txt_nrsi_period" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_nrsi_period : '5'; ?>" class="form-control">
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">Khung RSI</label>
                                    <div class="col-md-2 col-sm-2">
                                        <select name="v38_cbof_crsi_tf" class="form-control">
                                            <option value="PERIOD_M1" <?php echo ($cbof_crsi_tf == 'PERIOD_M1') ? 'selected' : ''; ?>>M1</option>
                                            <option value="PERIOD_M5" <?php echo ($cbof_crsi_tf == 'PERIOD_M5') ? 'selected' : ''; ?>>M5</option>
                                            <option value="PERIOD_M15" <?php echo ($cbof_crsi_tf == 'PERIOD_M15') ? 'selected' : ''; ?>>M15</option>
                                            <option value="PERIOD_H1" <?php echo ($cbof_crsi_tf == 'PERIOD_H1') ? 'selected' : ''; ?>>H1</option>
                                        </select>
                                    </div>
                                    <label class="col-form-label col-md-1 col-sm-1 label-align">Magic Num</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="text" name="v38_txt_nmagic" value="<?php echo $txt_nmagic; ?>" class="form-control" oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title section-amber"><i class="fa fa-clock-o"></i> VI. GIỜ GIAO DỊCH 3 PHIÊN (LOCAL GMT+7)</h5>
                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Sử dụng bộ lọc phiên</label>
                                    <div class="col-md-3 col-sm-3 pt-2">
                                        <input type="hidden" name="v38_hidden_time_filter_marker" value="1">
                                        <label style="cursor: pointer; font-weight: normal;">
                                            <input type="checkbox" name="v38_cbof_cuse_time_filter" value="1" <?php echo ($cbof_cuse_time_filter == '1') ? 'checked' : ''; ?> style="width: 17px; height: 17px; vertical-align: middle;">
                                            <span class="text-muted" style="margin-left: 8px;">(Bật: theo phiên | Tắt: 24/7)</span>
                                        </label>
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Múi GMT Broker</label>
                                    <div class="col-md-1 col-sm-1">
                                        <input type="number" name="nserver_gmt" value="<?php echo $nserver_gmt; ?>" class="form-control" placeholder="3">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Múi GMT Máy Client</label>
                                    <div class="col-md-1 col-sm-1">
                                        <input type="number" name="nlocal_gmt" value="<?php echo $nlocal_gmt; ?>" class="form-control" placeholder="7">
                                    </div>
                                </div>

                                <div style="display: block; width: 100%; background: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 18px 20px; margin-bottom: 25px; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                                    <div style="display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #edf2f7; padding-bottom: 10px; margin-bottom: 15px;">
                                        <span style="font-weight: 600; color: #2d3748; font-size: 14px;"><i class="fa fa-calendar-check-o text-primary"></i> Cấu hình chi tiết 3 phiên giao dịch</span>
                                        <span style="font-size: 12px; color: #718096;"><i class="fa fa-info-circle"></i> Giờ tính theo Local GMT+7</span>
                                    </div>

                                    <!-- Phiên Á -->
                                    <div style="display: flex; align-items: center; justify-content: flex-start; padding: 10px 15px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; margin-bottom: 12px; min-height: 52px;">
                                        <div style="width: 260px; min-width: 240px; flex-shrink: 0;">
                                            <label style="cursor: pointer; font-weight: 600; margin: 0; color: #1e293b; font-size: 13.5px; display: flex; align-items: center;">
                                                <input type="checkbox" name="cenable_asia" value="1" <?php echo ($cenable_asia == '1') ? 'checked' : ''; ?> style="width: 18px; height: 18px; margin-right: 10px; cursor: pointer;">
                                                Phiên Á <span style="font-weight: normal; color: #64748b; font-size: 12.5px; margin-left: 5px;">(Sydney - Tokyo)</span>
                                            </label>
                                        </div>

                                        <div style="display: flex; align-items: center; margin-right: 35px;">
                                            <span style="font-size: 13px; font-weight: 500; color: #475569; margin-right: 8px; width: 65px;">Bắt đầu:</span>
                                            <div style="display: inline-flex; align-items: center; background: #fff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 2px 6px;">
                                                <input type="number" min="0" max="23" name="nasia_start_hour" value="<?php echo $nasia_start_hour; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="05">
                                                <span style="font-weight: bold; color: #64748b; margin: 0 4px;">:</span>
                                                <input type="number" min="0" max="59" name="nasia_start_minute" value="<?php echo $nasia_start_minute; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="00">
                                            </div>
                                            <span style="font-size: 11.5px; color: #94a3b8; margin-left: 6px;">(giờ : phút)</span>
                                        </div>

                                        <div style="display: flex; align-items: center;">
                                            <span style="font-size: 13px; font-weight: 500; color: #475569; margin-right: 8px; width: 65px;">Kết thúc:</span>
                                            <div style="display: inline-flex; align-items: center; background: #fff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 2px 6px;">
                                                <input type="number" min="0" max="23" name="nasia_end_hour" value="<?php echo $nasia_end_hour; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="14">
                                                <span style="font-weight: bold; color: #64748b; margin: 0 4px;">:</span>
                                                <input type="number" min="0" max="59" name="nasia_end_minute" value="<?php echo $nasia_end_minute; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="00">
                                            </div>
                                            <span style="font-size: 11.5px; color: #94a3b8; margin-left: 6px;">(giờ : phút)</span>
                                        </div>
                                    </div>

                                    <!-- Phiên Âu -->
                                    <div style="display: flex; align-items: center; justify-content: flex-start; padding: 10px 15px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; margin-bottom: 12px; min-height: 52px;">
                                        <div style="width: 260px; min-width: 240px; flex-shrink: 0;">
                                            <label style="cursor: pointer; font-weight: 600; margin: 0; color: #1e293b; font-size: 13.5px; display: flex; align-items: center;">
                                                <input type="checkbox" name="cenable_europe" value="1" <?php echo ($cenable_europe == '1') ? 'checked' : ''; ?> style="width: 18px; height: 18px; margin-right: 10px; cursor: pointer;">
                                                Phiên Âu <span style="font-weight: normal; color: #64748b; font-size: 12.5px; margin-left: 5px;">(London)</span>
                                            </label>
                                        </div>

                                        <div style="display: flex; align-items: center; margin-right: 35px;">
                                            <span style="font-size: 13px; font-weight: 500; color: #475569; margin-right: 8px; width: 65px;">Bắt đầu:</span>
                                            <div style="display: inline-flex; align-items: center; background: #fff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 2px 6px;">
                                                <input type="number" min="0" max="23" name="neurope_start_hour" value="<?php echo $neurope_start_hour; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="14">
                                                <span style="font-weight: bold; color: #64748b; margin: 0 4px;">:</span>
                                                <input type="number" min="0" max="59" name="neurope_start_minute" value="<?php echo $neurope_start_minute; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="00">
                                            </div>
                                            <span style="font-size: 11.5px; color: #94a3b8; margin-left: 6px;">(giờ : phút)</span>
                                        </div>

                                        <div style="display: flex; align-items: center;">
                                            <span style="font-size: 13px; font-weight: 500; color: #475569; margin-right: 8px; width: 65px;">Kết thúc:</span>
                                            <div style="display: inline-flex; align-items: center; background: #fff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 2px 6px;">
                                                <input type="number" min="0" max="23" name="neurope_end_hour" value="<?php echo $neurope_end_hour; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="23">
                                                <span style="font-weight: bold; color: #64748b; margin: 0 4px;">:</span>
                                                <input type="number" min="0" max="59" name="neurope_end_minute" value="<?php echo $neurope_end_minute; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="00">
                                            </div>
                                            <span style="font-size: 11.5px; color: #94a3b8; margin-left: 6px;">(giờ : phút)</span>
                                        </div>
                                    </div>

                                    <!-- Phiên Mỹ -->
                                    <div style="display: flex; align-items: center; justify-content: flex-start; padding: 10px 15px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; margin-bottom: 0; min-height: 52px;">
                                        <div style="width: 260px; min-width: 240px; flex-shrink: 0;">
                                            <label style="cursor: pointer; font-weight: 600; margin: 0; color: #1e293b; font-size: 13.5px; display: flex; align-items: center;">
                                                <input type="checkbox" name="cenable_us" value="1" <?php echo ($cenable_us == '1') ? 'checked' : ''; ?> style="width: 18px; height: 18px; margin-right: 10px; cursor: pointer;">
                                                Phiên Mỹ <span style="font-weight: normal; color: #64748b; font-size: 12.5px; margin-left: 5px;">(New York)</span>
                                            </label>
                                        </div>

                                        <div style="display: flex; align-items: center; margin-right: 35px;">
                                            <span style="font-size: 13px; font-weight: 500; color: #475569; margin-right: 8px; width: 65px;">Bắt đầu:</span>
                                            <div style="display: inline-flex; align-items: center; background: #fff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 2px 6px;">
                                                <input type="number" min="0" max="23" name="nus_start_hour" value="<?php echo $nus_start_hour; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="19">
                                                <span style="font-weight: bold; color: #64748b; margin: 0 4px;">:</span>
                                                <input type="number" min="0" max="59" name="nus_start_minute" value="<?php echo $nus_start_minute; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="00">
                                            </div>
                                            <span style="font-size: 11.5px; color: #94a3b8; margin-left: 6px;">(giờ : phút)</span>
                                        </div>

                                        <div style="display: flex; align-items: center;">
                                            <span style="font-size: 13px; font-weight: 500; color: #475569; margin-right: 8px; width: 65px;">Kết thúc:</span>
                                            <div style="display: inline-flex; align-items: center; background: #fff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 2px 6px;">
                                                <input type="number" min="0" max="23" name="nus_end_hour" value="<?php echo $nus_end_hour; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="04">
                                                <span style="font-weight: bold; color: #64748b; margin: 0 4px;">:</span>
                                                <input type="number" min="0" max="59" name="nus_end_minute" value="<?php echo $nus_end_minute; ?>" class="form-control text-center" style="width: 50px; height: 32px; border: none; padding: 2px; font-weight: 600; font-size: 14px; box-shadow: none;" placeholder="00">
                                            </div>
                                            <span class="badge" style="background: #e67e22; color: #fff; font-size: 11px; margin-left: 10px; padding: 4px 7px; font-weight: 500; border-radius: 4px;">04:00 hôm sau</span>
                                        </div>
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title" style="background: #9b59b6; color: #fff;"><i class="fa fa-hourglass-end"></i> VII. CHỐT PHIÊN VÀ XÁC NHẬN HAI LẦN</h5>
                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Khóa mở L1 trước hết phiên</label>
                                    <div class="col-md-2 col-sm-2">
                                        <div class="input-group">
                                            <input type="number" min="0" name="v38_txt_nmin_before_close" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_nmin_before_close : '60'; ?>" class="form-control">
                                            <span class="input-group-addon" style="line-height:22px;padding:6px 10px;">phút</span>
                                        </div>
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">CloseProtect Max Orders</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" min="1" name="nclose_protect_max_orders" value="<?php echo $nclose_protect_max_orders; ?>" class="form-control" placeholder="8">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Đóng theo % lỗ chu kỳ</label>
                                    <div class="col-md-2 col-sm-2 pt-2">
                                        <input type="checkbox" name="cclose_protect_use_loss_pct" value="1" <?php echo ($cclose_protect_use_loss_pct == '1') ? 'checked' : ''; ?> style="transform: scale(1.3);">
                                    </div>
                                </div>

                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Ngưỡng lỗ % equity chu kỳ</label>
                                    <div class="col-md-2 col-sm-2">
                                        <div class="input-group">
                                            <input type="number" step="0.05" min="0.01" max="10" name="fclose_protect_loss_pct" value="<?php echo $fclose_protect_loss_pct; ?>" class="form-control" placeholder="0.3">
                                            <span class="input-group-addon" style="line-height:22px;padding:6px 10px;">%</span>
                                        </div>
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Bật xác nhận 2 lần</label>
                                    <div class="col-md-1 col-sm-1 pt-2">
                                        <input type="checkbox" name="cenable_double_confirm" value="1" <?php echo ($cenable_double_confirm == '1') ? 'checked' : ''; ?> style="transform: scale(1.3);">
                                    </div>
                                    <label class="col-form-label col-md-2 col-sm-2 label-align">Áp dụng từ lệnh thứ N</label>
                                    <div class="col-md-2 col-sm-2">
                                        <input type="number" min="1" name="v38_txt_nconfirm_from_order" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_nconfirm_from_order : '19'; ?>" class="form-control" placeholder="19">
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title" style="background: #34495e; color: #fff;"><i class="fa fa-sitemap"></i> VIII. KIỂU VÀO LỆNH (ENTRY STRATEGY)</h5>
                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align" style="font-weight: bold; color: #2980b9;">Chiến lược vào lệnh</label>
                                    <div class="col-md-4 col-sm-4">
                                        <select name="nentry_strategy" id="nentry_strategy" class="form-control" style="font-weight: bold;">
                                            <option value="0" <?php echo ($nentry_strategy == 0) ? 'selected' : ''; ?>>0: V26 truyền thống</option>
                                            <option value="1" <?php echo ($nentry_strategy == 1) ? 'selected' : ''; ?>>1: GLOBAL Grid Mode 1 (Nhóm lệnh + Phá biên)</option>
                                        </select>
                                    </div>
                                </div>

                                <div id="div_v38_global_mode" style="background: #ebf5fb; border: 1px solid #aed6f1; border-radius: 6px; padding: 15px; margin-bottom: 20px; <?php echo ($nentry_strategy == 1) ? '' : 'display: none;'; ?>">
                                    <div class="item form-group" style="margin-bottom: 10px;">
                                        <label class="col-form-label col-md-2 col-sm-2 label-align">Số lệnh mỗi nhóm K</label>
                                        <div class="col-md-2 col-sm-2">
                                            <input type="number" min="2" name="nglobal_orders_per_group" value="<?php echo $nglobal_orders_per_group; ?>" class="form-control" placeholder="6">
                                        </div>
                                        <label class="col-form-label col-md-2 col-sm-2 label-align">Khoảng phá vỡ D (USD XAU)</label>
                                        <div class="col-md-2 col-sm-2">
                                            <input type="number" step="0.1" name="fglobal_breakout_distance_usd" value="<?php echo $fglobal_breakout_distance_usd; ?>" class="form-control" placeholder="3.0">
                                        </div>
                                    </div>
                                    <div class="item form-group" style="margin-bottom: 0;">
                                        <label class="col-form-label col-md-2 col-sm-2 label-align">Khoảng cách nội bộ (pip)</label>
                                        <div class="col-md-9 col-sm-9">
                                            <input type="text" name="cglobal_local_distances" value="<?php echo $cglobal_local_distances; ?>" class="form-control" placeholder="4,4,8,8,12,12,16,16,20,20,24,24,28,28,32,32,36,36,40,40,44,44,48,48,52">
                                            <span class="text-muted" style="font-size: 12px;"><i class="fa fa-info-circle"></i> Danh sách bước pip phân tách bằng dấu phẩy cách đều từ anchor nhóm L1..LK</span>
                                        </div>
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title" style="background: #16a085; color: #fff;"><i class="fa fa-retweet"></i> IX. CHẾ ĐỘ PAIRCLOSE (V26 vs V38 RECURSIVE PAIR_A)</h5>
                                <div class="item form-group">
                                    <label class="col-form-label col-md-2 col-sm-2 label-align" style="font-weight: bold; color: #16a085;">Chế độ PairClose</label>
                                    <div class="col-md-4 col-sm-4">
                                        <select name="npairclose_mode" id="npairclose_mode" class="form-control" style="font-weight: bold;">
                                            <option value="1" <?php echo ($npairclose_mode == 1) ? 'selected' : ''; ?>>1: V38 Recursive Pair_A (RPA Rebase Lk*)</option>
                                            <option value="0" <?php echo ($npairclose_mode == 0) ? 'selected' : ''; ?>>0: V26 Legacy PairClose (Chốt cặp 2 lệnh cuối)</option>
                                        </select>
                                    </div>
                                </div>

                                <!-- THIẾT LẬP PAIRCLOSE MODE 0 (V26) -->
                                <div id="div_v38_pc_mode_0" style="background: #e8f8f5; border: 1px solid #a3e4d7; border-radius: 6px; padding: 15px; margin-bottom: 20px; <?php echo ($npairclose_mode == 0) ? '' : 'display: none;'; ?>">
                                    <div class="item form-group" style="margin-bottom: 0;">
                                        <input type="hidden" name="v38_hidden_pair_close_marker" value="1">
                                        <input type="hidden" name="v38_hidden_pair_close_danve_marker" value="1">
                                        <label class="col-form-label col-md-2 col-sm-2 label-align">Bật chốt cặp V26</label>
                                        <div class="col-md-1 col-sm-1 pt-2">
                                            <input type="checkbox" name="v38_cbof_cpair_close_bat_tat" value="1" <?php echo ($cbof_cpair_close_bat_tat == '1') ? 'checked' : ''; ?> style="transform: scale(1.3);">
                                        </div>
                                        <label class="col-form-label col-md-2 col-sm-2 label-align">Áp dụng từ tầng</label>
                                        <div class="col-md-1 col-sm-1">
                                            <input type="number" min="2" name="v38_txt_npair_close_tu_lenh" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_npair_close_tu_lenh : '12'; ?>" class="form-control">
                                        </div>
                                        <label class="col-form-label col-md-2 col-sm-2 label-align">Lãi 2 lệnh cuối ($)</label>
                                        <div class="col-md-1 col-sm-1">
                                            <input type="number" step="0.1" name="v38_txt_fpair_close_so_usd" value="<?php echo ($cbof_cbot_version == 'Onefxhub_v38') ? $txt_fpair_close_so_usd : '2.0'; ?>" class="form-control">
                                        </div>
                                        <label class="col-form-label col-md-1 col-sm-1 label-align">Chốt dần về</label>
                                        <div class="col-md-1 col-sm-1 pt-2">
                                            <input type="checkbox" name="v38_cbof_cpair_close_chot_dan_ve" value="1" <?php echo ($cbof_cpair_close_chot_dan_ve == '1') ? 'checked' : ''; ?> style="transform: scale(1.3);">
                                        </div>
                                    </div>
                                </div>

                                <!-- THIẾT LẬP PAIRCLOSE MODE 1 (RPA) -->
                                <div id="div_v38_pc_mode_1" style="background: #eafaf1; border: 1px solid #a9dfbf; border-radius: 6px; padding: 15px; margin-bottom: 20px; <?php echo ($npairclose_mode == 1) ? '' : 'display: none;'; ?>">
                                    <div class="item form-group" style="margin-bottom: 0;">
                                        <label class="col-form-label col-md-3 col-sm-3 label-align">Grid gốc xét PairClose từ cấp N >=</label>
                                        <div class="col-md-2 col-sm-2">
                                            <input type="number" min="2" name="noriginal_pairclose_start_order" value="<?php echo $noriginal_pairclose_start_order; ?>" class="form-control" placeholder="20">
                                        </div>
                                        <label class="col-form-label col-md-3 col-sm-3 label-align">Target level k của Lk*</label>
                                        <div class="col-md-2 col-sm-2">
                                            <input type="number" min="1" name="nrecursive_rebase_target_level" value="<?php echo $nrecursive_rebase_target_level; ?>" class="form-control" placeholder="15">
                                        </div>
                                    </div>
                                </div>

                                <h5 class="qcare-form-section-title" style="background: #73879c; color: #fff;"><i class="fa fa-th"></i> X. CẤU HÌNH BƯỚC LƯỚI GRID GN (G1 - G25 PIP - V38)</h5>
                                <div class="item form-group" style="background: #f2f5f7; padding: 15px; border-radius: 6px; border: 1px solid #e0e4e6;">
                                    <p class="text-muted" style="margin-left: 10px; font-weight: bold;"><i class="fa fa-info-circle"></i> Bước lưới chuẩn cho V38: GN = khoảng từ L1 tới lệnh N+1 (pip, 4 pip = 0.4 giá):</p>
                                    <div class="row" style="margin: 0;">
                                        <?php for($i=1; $i<=25; $i++): ?>
                                            <div class="col-md-2 col-sm-3 col-xs-6" style="margin-bottom: 12px;">
                                                <div class="input-group" style="margin-bottom: 0;">
                                                    <span class="input-group-addon" style="padding:0;line-height: 38px;height: 38px;width: 38px; background: #2c3e50; color: #fff; border: 1px solid #2c3e50; font-weight: bold; font-size: 12px;">G<?php echo $i; ?></span>
                                                    <input type="number" min="0" step="0.5" name="v38_step_G<?php echo $i; ?>" value="<?php echo isset($arr_steps_v38['G'.$i]) ? $arr_steps_v38['G'.$i] : 10; ?>" class="form-control input-sm text-center" style="font-weight: bold; color: #16a085;">
                                                </div>
                                            </div>
                                        <?php endfor; ?>
                                    </div>
                                </div>

                            </div>
                            <!-- END SECTION V38 -->


                            <div class="ln_solid"></div>
                            <div class="item form-group">
                                <div class="col-md-8 col-sm-8 offset-md-2">
                                    <button type="button" class="btn btn-success qcare-form-btn" name="btn_submit" value="btn_submit" 
                                        onclick="js_SetSubmitButtonClick(this.form, this.name);"><i class="fa fa-save"></i> Lưu cấu hình chiến lược</button>
                                    <button class="btn btn-secondary qcare-form-btn" type="button" name="btn_cancel" 
                                        onclick="location.href='<?php echo $link_cancel; ?>'"><i class="fa fa-chevron-left"></i> Quay về</button>
                                </div>
                            </div>

                            <input name="hidden_nid" type="hidden" value="<?php echo $nid; ?>" />
                            <input name="hidden_event" type="hidden" value="<?php echo $event; ?>" />
                            <input type="hidden" name="hidden_button" value="" />
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function() {
    var botVersionSelect = document.getElementById('cbof_cbot_version');
    var sectionV33 = document.getElementById('section_bot_v33');
    var sectionV38 = document.getElementById('section_bot_v38');

    function toggleBotVersion() {
        if (!botVersionSelect) return;
        if (botVersionSelect.value === 'Onefxhub_v38') {
            if (sectionV33) sectionV33.style.display = 'none';
            if (sectionV38) sectionV38.style.display = 'block';
        } else {
            if (sectionV33) sectionV33.style.display = 'block';
            if (sectionV38) sectionV38.style.display = 'none';
        }
    }

    if (botVersionSelect) {
        botVersionSelect.addEventListener('change', toggleBotVersion);
    }

    // Toggle Global Mode Sub-settings in V38
    var entryStrategySelect = document.getElementById('nentry_strategy');
    var divGlobalMode = document.getElementById('div_v38_global_mode');
    function toggleEntryStrategy() {
        if (!entryStrategySelect || !divGlobalMode) return;
        divGlobalMode.style.display = (entryStrategySelect.value === '1') ? 'block' : 'none';
    }
    if (entryStrategySelect) {
        entryStrategySelect.addEventListener('change', toggleEntryStrategy);
    }

    // Toggle PairClose Modes in V38
    var paircloseModeSelect = document.getElementById('npairclose_mode');
    var divPcMode0 = document.getElementById('div_v38_pc_mode_0');
    var divPcMode1 = document.getElementById('div_v38_pc_mode_1');
    function togglePaircloseMode() {
        if (!paircloseModeSelect) return;
        if (paircloseModeSelect.value === '0') {
            if (divPcMode0) divPcMode0.style.display = 'block';
            if (divPcMode1) divPcMode1.style.display = 'none';
        } else {
            if (divPcMode0) divPcMode0.style.display = 'none';
            if (divPcMode1) divPcMode1.style.display = 'block';
        }
    }
    if (paircloseModeSelect) {
        paircloseModeSelect.addEventListener('change', togglePaircloseMode);
    }
});
</script>


<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function() {
    var botVersionSelect = document.getElementById('cbof_cbot_version');
    var sectionV33 = document.getElementById('section_bot_v33');
    var sectionV38 = document.getElementById('section_bot_v38');

    function toggleBotVersion() {
        if (!botVersionSelect) return;
        if (botVersionSelect.value === 'Onefxhub_v38') {
            if (sectionV33) sectionV33.style.display = 'none';
            if (sectionV38) sectionV38.style.display = 'block';
        } else {
            if (sectionV33) sectionV33.style.display = 'block';
            if (sectionV38) sectionV38.style.display = 'none';
        }
    }

    if (botVersionSelect) {
        botVersionSelect.addEventListener('change', toggleBotVersion);
    }

    // Toggle Global Mode Sub-settings in V38
    var entryStrategySelect = document.getElementById('nentry_strategy');
    var divGlobalMode = document.getElementById('div_v38_global_mode');
    function toggleEntryStrategy() {
        if (!entryStrategySelect || !divGlobalMode) return;
        divGlobalMode.style.display = (entryStrategySelect.value === '1') ? 'block' : 'none';
    }
    if (entryStrategySelect) {
        entryStrategySelect.addEventListener('change', toggleEntryStrategy);
    }

    // Toggle PairClose Modes in V38
    var paircloseModeSelect = document.getElementById('npairclose_mode');
    var divPcMode0 = document.getElementById('div_v38_pc_mode_0');
    var divPcMode1 = document.getElementById('div_v38_pc_mode_1');
    function togglePaircloseMode() {
        if (!paircloseModeSelect) return;
        if (paircloseModeSelect.value === '0') {
            if (divPcMode0) divPcMode0.style.display = 'block';
            if (divPcMode1) divPcMode1.style.display = 'none';
        } else {
            if (divPcMode0) divPcMode0.style.display = 'none';
            if (divPcMode1) divPcMode1.style.display = 'block';
        }
    }
    if (paircloseModeSelect) {
        paircloseModeSelect.addEventListener('change', togglePaircloseMode);
    }
});
</script>