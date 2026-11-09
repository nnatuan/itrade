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

                            <!-- CẬP NHẬT 1: THÊM Ô CHỌN PHIÊN BẢN BOT EA -->
                            <div class="item form-group">
								<label class="col-form-label col-md-2 col-sm-2 label-align" style="color: #26b99a; font-weight: bold;">Phiên bản Bot EA <span class="required">*</span></label>
								<div class="col-md-3 col-sm-3">
									<select name="cbof_cbot_version" id="cbof_cbot_version" class="form-control" style="border: 1px solid #26b99a; font-weight: bold;">
										<option value="RSI6_v33" <?php echo (isset($cbof_cbot_version) && $cbof_cbot_version == 'RSI6_v33') ? 'selected' : ''; ?>>Grid + Bảo vệ sát phiên</option>
										<option value="RSI6_v32" <?php echo (isset($cbof_cbot_version) && $cbof_cbot_version == 'RSI6_v32') ? 'selected' : ''; ?>>Grid tiêu chuẩn</option>
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

                            <h5 class="qcare-form-section-title section-teal">II. THIẾT LẬP THAM SỐ CHIẾN LƯỢC ROBOT TRADING</h5>
                            
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

                            <h5 class="qcare-form-section-title section-amber">III. KHUNG GIỜ GIAO DỊCH & XÁC NHẬN CHỐT BÃO GIÁ</h5>
                            
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

                                <!-- CỘT PHẢI: TRADE HOUR -->
                                <div class="col-md-6 col-sm-6 col-xs-12" style="padding-left: 15px; margin-bottom: 15px;">
                                    <label style="font-weight: bold; color: #2c3e50; font-size: 14px; margin-bottom: 8px; display: block;">Trade Hour (Khung giờ giao dịch)</label>
                                    
                                    <!-- Khung 1 -->
                                    <div class="row" style="margin-bottom: 10px;">
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-right: 5px;">
                                            <div class="input-group" style="margin-bottom: 0; width: 100%; display: table;">
                                                <span class="input-group-addon" style="width: 95px; background: #f8f9fa; color: #495057; font-size: 13px; text-align: center; border: 1px solid #ced4da; border-right: 0;">Giờ Bắt Đầu</span>
                                                <input type="time" name="txt_ctime_start_1" value="<?php echo $txt_ctime_start_1; ?>" class="form-control" style="font-size: 13px; height: 38px; border: 1px solid #ced4da;">
                                    <div class="row" style="margin-left: -5px; margin-right: -5px; margin-bottom: 14px;">
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                            <div style="display: flex; align-items: stretch; width: 100%;">
                                                <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Bắt Đầu</span>
                                                <input type="time" name="txt_ctime_start_1" value="<?php echo $txt_ctime_start_1; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff; box-shadow: inset 0 1px 1px rgba(0,0,0,.075);">
                                            </div>
                                        </div>
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px;">
                                            <div class="input-group" style="margin-bottom: 0; width: 100%; display: table;">
                                                <span class="input-group-addon" style="width: 95px; background: #f8f9fa; color: #495057; font-size: 13px; text-align: center; border: 1px solid #ced4da; border-right: 0;">Giờ Kết Thúc</span>
                                                <input type="time" name="txt_ctime_end_1" value="<?php echo $txt_ctime_end_1; ?>" class="form-control" style="font-size: 13px; height: 38px; border: 1px solid #ced4da;">
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                            <div style="display: flex; align-items: stretch; width: 100%;">
                                                <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Kết Thúc</span>
                                                <input type="time" name="txt_ctime_end_1" value="<?php echo $txt_ctime_end_1; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff; box-shadow: inset 0 1px 1px rgba(0,0,0,.075);">
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Khung 2 -->
                                    <div class="row" style="margin-bottom: 10px;">
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-right: 5px;">
                                            <div class="input-group" style="margin-bottom: 0; width: 100%; display: table;">
                                                <span class="input-group-addon" style="width: 95px; background: #f8f9fa; color: #495057; font-size: 13px; text-align: center; border: 1px solid #ced4da; border-right: 0;">Giờ Bắt Đầu</span>
                                                <input type="time" name="txt_ctime_start_2" value="<?php echo $txt_ctime_start_2; ?>" class="form-control" style="font-size: 13px; height: 38px; border: 1px solid #ced4da;">
                                    <div class="row" style="margin-left: -5px; margin-right: -5px; margin-bottom: 14px;">
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                            <div style="display: flex; align-items: stretch; width: 100%;">
                                                <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Bắt Đầu</span>
                                                <input type="time" name="txt_ctime_start_2" value="<?php echo $txt_ctime_start_2; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff; box-shadow: inset 0 1px 1px rgba(0,0,0,.075);">
                                            </div>
                                        </div>
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px;">
                                            <div class="input-group" style="margin-bottom: 0; width: 100%; display: table;">
                                                <span class="input-group-addon" style="width: 95px; background: #f8f9fa; color: #495057; font-size: 13px; text-align: center; border: 1px solid #ced4da; border-right: 0;">Giờ Kết Thúc</span>
                                                <input type="time" name="txt_ctime_end_2" value="<?php echo $txt_ctime_end_2; ?>" class="form-control" style="font-size: 13px; height: 38px; border: 1px solid #ced4da;">
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                            <div style="display: flex; align-items: stretch; width: 100%;">
                                                <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Kết Thúc</span>
                                                <input type="time" name="txt_ctime_end_2" value="<?php echo $txt_ctime_end_2; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff; box-shadow: inset 0 1px 1px rgba(0,0,0,.075);">
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Khung 3 -->
                                    <div class="row" style="margin-bottom: 0;">
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-right: 5px;">
                                            <div class="input-group" style="margin-bottom: 0; width: 100%; display: table;">
                                                <span class="input-group-addon" style="width: 95px; background: #f8f9fa; color: #495057; font-size: 13px; text-align: center; border: 1px solid #ced4da; border-right: 0;">Giờ Bắt Đầu</span>
                                                <input type="time" name="txt_ctime_start_3" value="<?php echo $txt_ctime_start_3; ?>" class="form-control" style="font-size: 13px; height: 38px; border: 1px solid #ced4da;">
                                    <div class="row" style="margin-left: -5px; margin-right: -5px; margin-bottom: 0;">
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                            <div style="display: flex; align-items: stretch; width: 100%;">
                                                <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Bắt Đầu</span>
                                                <input type="time" name="txt_ctime_start_3" value="<?php echo $txt_ctime_start_3; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff; box-shadow: inset 0 1px 1px rgba(0,0,0,.075);">
                                            </div>
                                        </div>
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px;">
                                            <div class="input-group" style="margin-bottom: 0; width: 100%; display: table;">
                                                <span class="input-group-addon" style="width: 95px; background: #f8f9fa; color: #495057; font-size: 13px; text-align: center; border: 1px solid #ced4da; border-right: 0;">Giờ Kết Thúc</span>
                                                <input type="time" name="txt_ctime_end_3" value="<?php echo $txt_ctime_end_3; ?>" class="form-control" style="font-size: 13px; height: 38px; border: 1px solid #ced4da;">
                                        <div class="col-xs-6 col-sm-6 col-md-6" style="padding-left: 5px; padding-right: 5px;">
                                            <div style="display: flex; align-items: stretch; width: 100%;">
                                                <span style="display: flex; align-items: center; justify-content: center; width: 88px; min-width: 88px; flex-shrink: 0; background: #f8f9fa; color: #495057; font-size: 12.5px; font-weight: 500; border: 1px solid #ced4da; border-right: 0; border-radius: 4px 0 0 4px; padding: 0 4px; text-align: center; white-space: nowrap; user-select: none;">Giờ Kết Thúc</span>
                                                <input type="time" name="txt_ctime_end_3" value="<?php echo $txt_ctime_end_3; ?>" class="form-control" style="flex: 1 1 auto; min-width: 0; width: 100%; height: 38px; border: 1px solid #ced4da; border-radius: 0 4px 4px 0; font-size: 13px; padding: 6px 6px; text-align: center; background-color: #fff; box-shadow: inset 0 1px 1px rgba(0,0,0,.075);">
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

                            <!-- CẬP NHẬT 2: THÊM TÙY CHỌN CHO PHÉP NHỒI LỆNH SÁT PHIÊN KHI CHUỖI GRID > 8 LỆNH -->
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

                            <h5 class="qcare-form-section-title" style="background: #73879c; color: #fff;">IV. CẤU HÌNH KHOẢNG CÁCH LƯỚI GRID ĐỘNG (PIPS)</h5>
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